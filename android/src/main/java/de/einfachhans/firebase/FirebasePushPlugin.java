package de.einfachhans.firebase;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.getcapacitor.Bridge;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginHandle;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;

import java.util.ArrayList;
import java.util.Map;
import java.util.Random;
import java.util.Set;

@CapacitorPlugin(name = "FirebasePush", permissions = @Permission(strings = {}, alias = "receive"))
public class FirebasePushPlugin extends Plugin {

    private static final String TAG = "FirebasePushPlugin";
    public static Bridge staticBridge = null;

    private static boolean registered = false;
    private static ArrayList<Bundle> notificationStack = null;

    @Override
    public void load() {
        staticBridge = this.bridge;
    }

    @PluginMethod
    public void register(PluginCall call) {
        FirebaseApp.initializeApp(this.getContext());
        registered = true;
        this.sendStacked();
        call.resolve();

        FirebaseMessaging.getInstance().getToken().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                this.sendToken(task.getResult());
            }
        });
    }

    public void sendToken(String token) {
        JSObject data = new JSObject();
        data.put("token", token);
        notifyListeners("token", data, true);
    }

    public void sendRemoteMessage(RemoteMessage message) {
        String messageType = "data";
        String title = null;
        String body = null;
        String id = null;
        String sound = null;
        String vibrate = null;
        String color = null;
        String icon = null;
        String channelId = null;

        Map<String, String> data = message.getData();

        if (message.getNotification() != null) {
            messageType = "notification";
            id = message.getMessageId();
            RemoteMessage.Notification notification = message.getNotification();
            title = notification.getTitle();
            body = notification.getBody();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                channelId = notification.getChannelId();
            }
            sound = notification.getSound();
            color = notification.getColor();
            icon = notification.getIcon();
        }

        if (TextUtils.isEmpty(id)) {
            Random rand = new Random();
            int n = rand.nextInt(50) + 1;
            id = Integer.toString(n);
        }

        Log.d(TAG, "sendMessage(): messageType=" + messageType + "; id=" + id + "; title=" + title + "; body=" + body + "; sound=" + sound + "; vibrate=" + vibrate + "; color=" + color + "; icon=" + icon + "; channel=" + channelId + "; data=" + data.toString());
        Bundle bundle = new Bundle();
        for (String key : data.keySet()) {
            bundle.putString(key, data.get(key));
        }
        bundle.putString("messageType", messageType);
        this.putKVInBundle("google.message_id", id, bundle);
        this.putKVInBundle("title", title, bundle);
        this.putKVInBundle("body", body, bundle);
        this.putKVInBundle("sound", sound, bundle);
        this.putKVInBundle("vibrate", vibrate, bundle);
        this.putKVInBundle("color", color, bundle);
        this.putKVInBundle("icon", icon, bundle);
        this.putKVInBundle("channel_id", channelId, bundle);
        this.putKVInBundle("from", message.getFrom(), bundle);
        this.putKVInBundle("collapse_key", message.getCollapseKey(), bundle);
        this.putKVInBundle("google.sent_time", String.valueOf(message.getSentTime()), bundle);
        this.putKVInBundle("google.ttl", String.valueOf(message.getTtl()), bundle);

        if (!registered) {
            if (FirebasePushPlugin.notificationStack == null) {
                FirebasePushPlugin.notificationStack = new ArrayList<>();
            }
            notificationStack.add(bundle);
            return;
        }

        this.sendRemoteBundle(bundle);
    }

    private void sendRemoteBundle(Bundle bundle) {
        JSObject json = new JSObject();
        Set<String> keys = bundle.keySet();
        for (String key : keys) {
            json.put(key, bundle.get(key));
        }
        notifyListeners("message", json, true);
    }

    public static void onNewToken(String newToken) {
        FirebasePushPlugin pushPlugin = FirebasePushPlugin.getInstance();
        if (pushPlugin != null) {
            pushPlugin.sendToken(newToken);
        }
    }

    public static void onNewRemoteMessage(RemoteMessage message) {
        FirebasePushPlugin pushPlugin = FirebasePushPlugin.getInstance();
        if (pushPlugin != null) {
            pushPlugin.sendRemoteMessage(message);
        }
    }

    @Override
    public void handleOnNewIntent(Intent intent) {
        final Bundle data = intent.getExtras();
        if (data != null && data.containsKey("google.message_id")) {
            data.putString("messageType", "notification");
            data.putString("tap", "background");
            Log.d(TAG, "Notification message on new intent: " + data.toString());
            this.sendRemoteBundle(data);
        }
    }

    private void sendStacked() {
        if (FirebasePushPlugin.notificationStack != null) {
            for (Bundle bundle : FirebasePushPlugin.notificationStack) {
                this.sendRemoteBundle(bundle);
            }
            FirebasePushPlugin.notificationStack.clear();
        }
    }

    public static FirebasePushPlugin getInstance() {
        if (staticBridge != null && staticBridge.getWebView() != null) {
            PluginHandle handle = staticBridge.getPlugin("FirebasePush");
            if (handle == null) {
                return null;
            }
            return (FirebasePushPlugin) handle.getInstance();
        }
        return null;
    }

    private void putKVInBundle(String k, String v, Bundle o) {
        if (v != null && !o.containsKey(k)) {
            o.putString(k, v);
        }
    }
}
