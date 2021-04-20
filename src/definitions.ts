export interface FirebasePushPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
