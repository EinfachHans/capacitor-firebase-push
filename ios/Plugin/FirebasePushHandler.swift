import Capacitor
import UserNotifications

import FirebaseMessaging

public class FirebasePushNotificationsHandler: NSObject, NotificationHandlerProtocol {
    
    public var plugin: FirebasePushPlugin?;
    
    private var notificationStack: NSMutableArray?;
    
    // Tells the app that a remote notification arrived that indicates there is data to be fetched.
    // Called when a message arrives in the foreground and remote notifications permission has been granted
    public func didReceiveRemoteNotification(userInfo: NSDictionary, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let mutableUserInfo = userInfo.mutableCopy() as! NSMutableDictionary
        Messaging.messaging().appDidReceiveMessage(userInfo as! [AnyHashable : Any])
        let aps = mutableUserInfo.object(forKey: "aps") as! NSDictionary
        var contentAvailable = false
        let state = UIApplication.shared.applicationState;
        if(aps.object(forKey: "alert") != nil) {
            contentAvailable = aps.object(forKey: "content-available") as? String == "1";
            mutableUserInfo.setValue("notification", forKey: "messageType");
            if(state == .background && !contentAvailable) {
                mutableUserInfo.setValue("background", forKey: "tap")
            }
        } else {
            mutableUserInfo.setValue("data", forKey: "messageType");
        }
        print("didReceiveRemoteNotification:", mutableUserInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        if(state == .background || !contentAvailable) {
            self.sendNotification(userInfo: mutableUserInfo)
        }
    }
    
    public func willPresent(notification: UNNotification) -> UNNotificationPresentationOptions {
        // Check if Local Notification from Local Notification Plugin
        if(notification.request.trigger == nil || !(notification.request.trigger! is UNPushNotificationTrigger)) {
            return [.alert, .sound, .badge];
        }
        let userInfo = notification.request.content.userInfo;
        let mutableUserInfo = (userInfo as NSDictionary).mutableCopy() as! NSMutableDictionary;
        Messaging.messaging().appDidReceiveMessage(userInfo);
        
        let messageType = mutableUserInfo.object(forKey: "messageType") as? String
        if(messageType != "data") {
            mutableUserInfo.setValue("notification", forKey: "messageType")
        }
        
        print("willPresentNotification:", mutableUserInfo)
        
        let aps = mutableUserInfo.object(forKey: "aps") as! NSDictionary
        let contentAvailable = aps.object(forKey: "content-available") as? String == "1";
        if(contentAvailable) {
            print("willPresentNotification: aborting as content-available:1 so system notification will be shown")
            return [];
        }
        
        let createNotification = mutableUserInfo.object(forKey: "create_notification") as? String ?? "false"
        var result: UNNotificationPresentationOptions = [];
        
        var useAlert: Bool = false;
        var useBadge: Bool = false;
        var useSound: Bool = false;
        
        // Defaults
        if let optionsArray = self.plugin?.getConfigValue("presentationOptions") as? [String] {
            
            optionsArray.forEach { option in
                switch option {
                case "alert":
                    useAlert = true;
                case "badge":
                    useBadge = true;
                case "sound":
                    useSound = true;
                default:
                    print("Unrecogizned presentation option: \(option)")
                }
            }
        }
        
        if(createNotification == "true") {
            if(aps.object(forKey: "alert") != nil && !useAlert) {
                useAlert = true;
            }
            if(aps.object(forKey: "badge") != nil && !useBadge) {
                useBadge = true;
            }
            if(aps.object(forKey: "sound") != nil && !useSound) {
                useSound = true;
            }
        }
        
        if(useAlert) {
            result.insert(.alert)
        }
        if(useBadge) {
            result.insert(.badge)
        }
        if(useSound) {
            result.insert(.sound)
        }
        
        if(messageType != "data") {
            self.sendNotification(userInfo: mutableUserInfo)
        }
        
        return result;
    }
    
    public func didReceive(response: UNNotificationResponse) {
        let notification = response.notification;
        // Check if Local Notification from Local Notification Plugin
        if(notification.request.trigger == nil || !(notification.request.trigger! is UNPushNotificationTrigger)) {
            return;
        }
        
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        let mutableUserInfo = (userInfo as NSDictionary).mutableCopy() as! NSMutableDictionary
        
        let tap: String?
        if(UIApplication.shared.applicationState == .active) {
            tap = "foreground"
        } else {
            tap = "background"
        }
        mutableUserInfo.setValue(tap, forKey: "tap")
        
        if(mutableUserInfo.object(forKey: "messageType") == nil) {
            mutableUserInfo.setValue("notification", forKey: "messageType")
        }
        
        print("didReceiveNotificationResponse:", mutableUserInfo)
        
        self.sendNotification(userInfo: mutableUserInfo)
    }
    
    func sendNotification(userInfo: NSDictionary) {
        if(self.plugin!.registered) {
            self.plugin?.notifyListeners("message", data: (userInfo as! [String : Any]))
        } else {
            if(self.notificationStack == nil) {
                self.notificationStack = NSMutableArray.init();
            }
            self.notificationStack!.add(userInfo)
            
            if(self.notificationStack!.count >= 20) {
                self.notificationStack!.removeLastObject()
            }
        }
    }
    
    func sendStacked() {
        if(self.notificationStack != nil && self.notificationStack!.count > 0) {
            for userInfo in self.notificationStack! {
                self.sendNotification(userInfo: userInfo as! NSDictionary)
            }
            self.notificationStack?.removeAllObjects()
        }
    }
    
    public func requestPermissions(settingsButton: Bool, with completion: ((Bool, Error?) -> Void)? = nil) {
        var options: UNAuthorizationOptions = [.alert, .sound, .badge];
        if(settingsButton) {
            options.insert(.providesAppNotificationSettings)
        }
        UNUserNotificationCenter.current().requestAuthorization(options:options) { granted, error in
            completion?(granted, error)
        }
    }
    
    public func checkPermissions(with completion: ((UNAuthorizationStatus) -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion?(settings.authorizationStatus)
        }
    }
}
