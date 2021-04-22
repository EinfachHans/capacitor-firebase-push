import Foundation
import Capacitor

import FirebaseMessaging
import FirebaseInstallations
import FirebaseCore

@objc(FirebasePushPlugin)
public class FirebasePushPlugin: CAPPlugin, MessagingDelegate {
    private var notificationDelegateHandler = FirebasePushNotificationsHandler()
    private var savedRegisterCall: CAPPluginCall? = nil;
    public var registered: Bool = false;
    
    override public func load() {
        if(FirebaseApp.app() == nil) {
            FirebaseApp.configure();
        }
        Messaging.messaging().delegate = self;
        self.notificationDelegateHandler.plugin = self;
        self.bridge?.notificationRouter.pushNotificationHandler = self.notificationDelegateHandler;
        self.bridge?.notificationRouter.localNotificationHandler = self.notificationDelegateHandler;
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRegisterWithToken(notification:)), name: Notification.Name.capacitorDidRegisterForRemoteNotifications, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFailToRegisterWithToken(notification:)), name: Notification.Name.capacitorDidFailToRegisterForRemoteNotifications, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveRemoteNotification(notification:)), name: Notification.Name.init("didReceiveRemoteNotification"), object: nil)
    }
    
    @objc func register(_ call: CAPPluginCall) {
        if(self.savedRegisterCall != nil || self.registered) {
            return
        }
        self.savedRegisterCall = call;
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    @objc func unregister(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            Installations.installations().delete { error in
              if let error = error {
                call.reject(error.localizedDescription)
                return
              }
                call.resolve()
            }
        }
    }
    
    @objc func didRegisterWithToken(notification: NSNotification) {
        if(self.savedRegisterCall == nil) {
            return;
        }
        let deviceToken = notification.object as! String
        notifyListeners("token", data: [
            "token": deviceToken
        ])
        self.registered = true;
        self.notificationDelegateHandler.sendStacked()
        self.savedRegisterCall?.resolve()
    }
    
    @objc func didFailToRegisterWithToken(notification: NSNotification) {
        let error = notification.object as! Error
        self.savedRegisterCall?.reject(error.localizedDescription)
        self.savedRegisterCall = nil
    }
    
    @objc public func didReceiveRemoteNotification(notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        let completionHandler = notification.object as! (UIBackgroundFetchResult) -> Void
        self.notificationDelegateHandler.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }

    @objc override public func checkPermissions(_ call: CAPPluginCall) {
        self.notificationDelegateHandler.checkPermissions { status in
            var result: PushNotificationsPermissions = .prompt
            
            switch status {
            case .notDetermined:
                result = .prompt
            case .denied:
                result = .denied
            case .ephemeral, .authorized, .provisional:
                result = .granted
            @unknown default:
                result = .prompt
            }
            
            call.resolve(["receive": result.rawValue])
        }
    }
    
    @objc override public func requestPermissions(_ call: CAPPluginCall) {
        self.notificationDelegateHandler.requestPermissions(settingsButton: false, with: { granted, error in
            guard error == nil else {
                if let err = error {
                    call.reject(err.localizedDescription)
                    return
                }
                
                call.reject("unknown error in permissions request")
                return
            }
            
            var result: PushNotificationsPermissions = .denied
            
            if granted {
                result = .granted
            }
            
            call.resolve(["receive": result.rawValue])
        })
    }
}

enum PushNotificationsPermissions: String {
    case prompt
    case denied
    case granted
}
