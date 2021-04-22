/// <reference types="@capacitor/cli" />

import type { PermissionState, PluginListenerHandle } from "@capacitor/core";

export type PresentationOption = 'badge' | 'sound' | 'alert';

declare module '@capacitor/cli' {
  export interface PluginsConfig {
    FirebasePush?: {
      /**
       * This is an array of strings you can combine. Possible values in the array are:
       *   - `badge`: badge count on the app icon is updated (default value)
       *   - `sound`: the device will ring/vibrate when the push notification is received
       *   - `alert`: the push notification is displayed in a native dialog
       *
       * An empty array can be provided if none of the options are desired.
       *
       * Only available for iOS.
       *
       * @since 1.0.0
       * @example ["badge", "sound", "alert"]
       */
      presentationOptions?: PresentationOption[];
    }
  }
}

export interface FirebasePushPlugin {
  checkPermissions(): Promise<PermissionStatus>;

  requestPermissions(): Promise<PermissionStatus>;

  register(): Promise<void>;

  /**
   * Called when a new fcm token is created
   *
   * @since 1.0.0
   */
  addListener(
    eventName: 'token',
    listenerFunc: (result: TokenResult) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
   * Called when a new message is received
   *
   * @since 1.0.0
   */
  addListener(
    eventName: 'message',
    listenerFunc: (message: any) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
   * Remove all native listeners for this plugin.
   *
   * @since 1.0.0
   */
  removeAllListeners(): Promise<void>;
}

/**
 * @since 1.0.0
 */
export interface TokenResult {
  token: string;
}

/**
 * @since 1.0.0
 */
export interface PermissionStatus {
  /**
   * @since 1.0.0
   */
  receive: PermissionState;
}
