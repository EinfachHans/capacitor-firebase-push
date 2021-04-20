import { WebPlugin } from '@capacitor/core';

import type { FirebasePushPlugin } from './definitions';

export class FirebasePushWeb extends WebPlugin implements FirebasePushPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
