import { registerPlugin } from '@capacitor/core';

import type { FirebasePushPlugin } from './definitions';

const FirebasePush = registerPlugin<FirebasePushPlugin>('FirebasePush');

export * from './definitions';
export { FirebasePush };
