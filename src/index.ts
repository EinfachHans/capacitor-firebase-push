import { registerPlugin } from '@capacitor/core';

import type { FirebasePushPlugin } from './definitions';

const FirebasePush = registerPlugin<FirebasePushPlugin>('FirebasePush', {
  web: () => import('./web').then(m => new m.FirebasePushWeb()),
});

export * from './definitions';
export { FirebasePush };
