## 3.2.0+2

- Fix pub.dev package score

## 3.2.0+1

- Upgrade native AppCenter SDK to 3.2.x (Change Logs: [Android](https://github.com/microsoft/appcenter-sdk-android/releases/tag/3.2.1) / [IOS](https://github.com/microsoft/appcenter-sdk-apple/releases/tag/3.2.0))

## 3.1.1+1

- Upgrade native IOS AppCenter SDK to [3.1.1](https://github.com/microsoft/appcenter-sdk-apple/releases/tag/3.1.1)

## 3.1.0+1

- Upgrade native AppCenter SDK to 3.1.0 (Change Logs: [Android](https://github.com/microsoft/appcenter-sdk-android/releases/tag/3.1.0) / [IOS](https://github.com/microsoft/appcenter-sdk-apple/releases/tag/3.1.0))
- [Feature] Add a **disableAutomaticCheckForUpdate** parameter to **AppCenter.startAsync** function.
- [Feature] Add a **checkForUpdateAsync** API to manually check for update.

## 3.0.0+1

- Upgrade native AppCenter SDK to 3.0.0 (Change Logs: [Android](https://github.com/microsoft/appcenter-sdk-android/releases/tag/3.0.0) / [IOS](https://github.com/microsoft/appcenter-sdk-apple/releases/tag/3.0.0))
- Upgrade package version to 3.0.0 as well to match native SDK version
- Add optional usePrivateDistributeTrack parameter to AppCenter.start method to support new private update track introduced in native SDK 3.0.0

## 1.1.0+1

- (Breaking) Upgrade pubspec.yaml to use (plugin platform)[https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms] (This drops support for flutter prior to 1.10)

## 1.0.0+4

- Make Android flutter SDK dependency debugCompileOnly. ([Issue](https://github.com/hanabi1224/flutter_appcenter_bundle/issues/5))

## 1.0.0+3

- Initial release with Android & IOS support.
- Bundles AppCenter Analytics, Crashes and Distribute alltogether.
