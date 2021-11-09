# Capacitor Firebase Push

![Maintenance](https://img.shields.io/maintenance/yes/2021)
[![npm](https://img.shields.io/npm/v/capacitor-firebase-push)](https://www.npmjs.com/package/capacitor-firebase-push)

👉🏼 **Note**: this Plugin is developed for Capacitor V3

This Plugin it used for Firebase Push Messages. It **does** support Data (silent) notifications!

<!-- DONATE -->
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG_global.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LMX5TSQVMNMU6&source=url)

This and other Open-Source Cordova Plugins are developed in my free time.
To help ensure this plugin is kept updated, new features are added and bugfixes are implemented quickly, please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance.
Please consider donating if you're using this plugin in an app that makes you money, if you're being paid to make the app, if you're asking for new features or priority bug fixes.
<!-- END DONATE -->

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Content**

- [Install](#install)
- [Shutout](#shutout)
- [Setup](#setup)
  - [Android](#android)
  - [iOS](#ios)
- [Config](#config)
  - [Push notification appearance in foreground](#push-notification-appearance-in-foreground)
- [API](#api)
  - [checkPermissions()](#checkpermissions)
  - [requestPermissions()](#requestpermissions)
  - [register()](#register)
  - [unregister()](#unregister)
  - [getBadgeNumber()](#getbadgenumber)
  - [setBadgeNumber(...)](#setbadgenumber)
  - [getDeliveredNotifications()](#getdeliverednotifications)
  - [removeDeliveredNotifications(...)](#removedeliverednotifications)
  - [removeAllDeliveredNotifications()](#removealldeliverednotifications)
  - [addListener('token', ...)](#addlistenertoken-)
  - [addListener('message', ...)](#addlistenermessage-)
  - [removeAllListeners()](#removealllisteners)
  - [Interfaces](#interfaces)
  - [Type Aliases](#type-aliases)
- [Changelog](#changelog)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Install

```bash
npm install capacitor-firebase-push
npx cap sync
```

## Shutout

❤️

This Plugin was created to match every requirement I had for my app. These Plugins helped my a lot to create this one:
- [cordova-plugin-firebase-x](https://github.com/dpa99c/cordova-plugin-firebasex)
- [@capacitor/push-notifications](https://github.com/ionic-team/capacitor-plugins/tree/main/push-notifications)
- [@capacitor-community/fcm](https://github.com/capacitor-community/fcm)

## Setup

### Android

Just follow the Android Setup Guide [here](https://capacitorjs.com/docs/v3/guides/push-notifications-firebase#android)

#### Variables

This plugin will use the following project variables (defined in your app's variables.gradle file):

- `$firebaseMessagingVersion` version of **com.google.firebase:firebase-messaging** (default: `21.1.0)

#### Push Notifications icon

On Android, the Push Notifications icon with the appropriate name should be added to the AndroidManifest.xml file:

```xml
<meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@mipmap/push_icon_name" />
```

If no icon is specified Android will use the application icon, but push icon should be white pixels on a transparent backdrop. As the application icon is not usually like that, it will show a white square or circle. So it's recommended to provide the separate icon for Push Notifications.

Android Studio has an icon generator you can use to create your Push Notifications icon.

### iOS

Start setting up your iOS Project like described here: https://capacitorjs.com/docs/v3/guides/push-notifications-firebase#integrating-firebase-with-our-native-ios-app

**Stop** before the `Add the Firebase SDK via CocoaPods` Part - we don't need that one.

After you updated the project (`npx cap update ios`), you have to add the following Initialization Code to your **AppDelegate.swift**:

1. Add the Firebase Import:

   ```swift
   import Firebase
   ```

2. Add the following two functions:

   ```swift
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token(completion: { (token, error) in
            if let error = error {
                NotificationCenter.default.post(name: .capacitorDidFailToRegisterForRemoteNotifications, object: error)
            } else if let token = token {
                NotificationCenter.default.post(name: .capacitorDidRegisterForRemoteNotifications, object: token)
            }
        })
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationCenter.default.post(name: Notification.Name.init("didReceiveRemoteNotification"), object: completionHandler, userInfo: userInfo)
    }
   ```

## Config

### Push notification appearance in foreground

On iOS you can configure the way the push notifications are displayed when the app is in foreground by providing the `presentationOptions in your **capacitor.config.ts** as an Array of Strings you can combine.

Possible values are:

- `badge`: badge count on the app icon is updated (default value)
- `sound`: the device will ring/vibrate when the push notification is received
- `alert`: the push notification is displayed in a native dialog

An empty Array can be provided if none of the previous options are desired. pushNotificationReceived event will still be fired with the push notification information.

```ts
plugins: {
  FirebasePush: {
    presentationOptions: ["badge", "sound", "alert"]
  }
}
```

These fields can be overwritten if you pass `create_notification: true` in the data Part of the notification.

## API

<docgen-index>

* [`checkPermissions()`](#checkpermissions)
* [`requestPermissions()`](#requestpermissions)
* [`register()`](#register)
* [`unregister()`](#unregister)
* [`getBadgeNumber()`](#getbadgenumber)
* [`setBadgeNumber(...)`](#setbadgenumber)
* [`getDeliveredNotifications()`](#getdeliverednotifications)
* [`removeDeliveredNotifications(...)`](#removedeliverednotifications)
* [`removeAllDeliveredNotifications()`](#removealldeliverednotifications)
* [`addListener('token', ...)`](#addlistenertoken-)
* [`addListener('message', ...)`](#addlistenermessage-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### checkPermissions()

```typescript
checkPermissions() => Promise<PermissionStatus>
```

Check permission to receive push notifications.

Will always return "granted" on Android

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

**Since:** 1.0.0

--------------------


### requestPermissions()

```typescript
requestPermissions() => Promise<PermissionStatus>
```

Request permission to receive push notifications.

Will always return "granted" on Android

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

**Since:** 1.0.0

--------------------


### register()

```typescript
register() => Promise<void>
```

Register the app to receive push notifications.

**Since:** 1.0.0

--------------------


### unregister()

```typescript
unregister() => Promise<void>
```

Should be called to unregister the Firebase Instance. For example if a User logs out.

**Since:** 1.1.0

--------------------


### getBadgeNumber()

```typescript
getBadgeNumber() => Promise<BadgeCount>
```

Get icon badge Value

Only available on iOS

**Returns:** <code>Promise&lt;<a href="#badgecount">BadgeCount</a>&gt;</code>

**Since:** 1.2.0

--------------------


### setBadgeNumber(...)

```typescript
setBadgeNumber(options: BadgeCount) => Promise<void>
```

Set icon badge Value

Only available on iOS

| Param         | Type                                              |
| ------------- | ------------------------------------------------- |
| **`options`** | <code><a href="#badgecount">BadgeCount</a></code> |

**Since:** 1.2.0

--------------------


### getDeliveredNotifications()

```typescript
getDeliveredNotifications() => Promise<NotificationsResult>
```

Get notifications in Notification Center

**Returns:** <code>Promise&lt;<a href="#notificationsresult">NotificationsResult</a>&gt;</code>

**Since:** 1.2.0

--------------------


### removeDeliveredNotifications(...)

```typescript
removeDeliveredNotifications(options: NotificationsIds) => Promise<void>
```

Remove notifications from the notifications screen based on the id

| Param         | Type                                                          |
| ------------- | ------------------------------------------------------------- |
| **`options`** | <code><a href="#notificationsids">NotificationsIds</a></code> |

**Since:** 1.2.0

--------------------


### removeAllDeliveredNotifications()

```typescript
removeAllDeliveredNotifications() => Promise<void>
```

Remove all notifications from the notifications screen

**Since:** 1.2.0

--------------------


### addListener('token', ...)

```typescript
addListener(eventName: 'token', listenerFunc: (result: TokenResult) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Called when a new fcm token is created

| Param              | Type                                                                     |
| ------------------ | ------------------------------------------------------------------------ |
| **`eventName`**    | <code>'token'</code>                                                     |
| **`listenerFunc`** | <code>(result: <a href="#tokenresult">TokenResult</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

**Since:** 1.0.0

--------------------


### addListener('message', ...)

```typescript
addListener(eventName: 'message', listenerFunc: (message: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Called when a new message is received

| Param              | Type                                   |
| ------------------ | -------------------------------------- |
| **`eventName`**    | <code>'message'</code>                 |
| **`listenerFunc`** | <code>(message: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

**Since:** 1.0.0

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

Remove all native listeners for this plugin.

**Since:** 1.0.0

--------------------


### Interfaces


#### PermissionStatus

| Prop          | Type                                                        | Since |
| ------------- | ----------------------------------------------------------- | ----- |
| **`receive`** | <code><a href="#permissionstate">PermissionState</a></code> | 1.0.0 |


#### BadgeCount

| Prop        | Type                | Since |
| ----------- | ------------------- | ----- |
| **`count`** | <code>number</code> | 1.2.0 |


#### NotificationsResult

| Prop                | Type               | Since |
| ------------------- | ------------------ | ----- |
| **`notifications`** | <code>any[]</code> | 1.2.0 |


#### NotificationsIds

| Prop      | Type                  | Since |
| --------- | --------------------- | ----- |
| **`ids`** | <code>string[]</code> | 1.2.0 |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### TokenResult

| Prop        | Type                |
| ----------- | ------------------- |
| **`token`** | <code>string</code> |


### Type Aliases


#### PermissionState

<code>'prompt' | 'prompt-with-rationale' | 'granted' | 'denied'</code>

</docgen-api>

## Changelog

The full Changelog is available [here](CHANGELOG.md)
