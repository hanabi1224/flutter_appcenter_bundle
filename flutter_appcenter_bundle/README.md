# AppCenter Plugin for flutter
[![pub package](https://img.shields.io/pub/v/flutter_appcenter_bundle.svg)](https://pub.dev/packages/flutter_appcenter_bundle)
[![Build status](https://img.shields.io/cirrus/github/hanabi1224/flutter_appcenter_bundle/master)](https://cirrus-ci.com/github/hanabi1224/flutter_appcenter_bundle)
======

This plugin currently bundles appcenter analytics, crashes and distribute. 

## Getting Started

To get started, go to [AppCenter](https://appcenter.ms/apps) and register your apps.

For detailed AppCenter API reference, go to https://aka.ms/appcenterdocs

## Build

Appcenter distribute has an [issue](https://docs.microsoft.com/en-us/appcenter/sdk/distribute/android#remove-in-app-updates-for-google-play-builds) with pulishing apps to google play.
To workaround

use ```flutter build --flavor googlePlay``` to build for googlePlay and ```flutter build --flavor appCenter``` for appCenter.

```flutter build apk``` command will build both under build/app/outputs/flutter-apk by adding below section to android/app/build.gradle

```gradle
android {
  ...

  flavorDimensions "distribute"
  productFlavors {
      appCenter {
          dimension "distribute"
      }

      googlePlay {
          dimension "distribute"
      }
  }

  // This is likely needed, see https://github.com/flutter/flutter/issues/58247
  lintOptions {
      disable 'InvalidPackage'
      checkReleaseBuilds false
  }
}
```

Already having flavor settings and want to merge? Checkout example project. Please note that flavor dimensions are orthogonal. You may just want to reuse distribute flavor for the best build performance. Check out [this article](https://riptutorial.com/android-gradle/example/20559/using-flavor-dimension) for details.
```gradle
android {
  flavorDimensions "dummy", "distribute"
  productFlavors {
      dummyFoo {
          dimension "dummy"
      }
      dummyBar {
          dimension "dummy"
      }
      appCenter {
          dimension "distribute"
      }

      googlePlay {
          dimension "distribute"
      }
  }
}
```

**Try example project first when troubleshooting your local build issue.**

## Usage

### Basic usage

```dart
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

await AppCenter.startAsync(
    appSecretAndroid: '******',
    appSecretIOS: '******',
    enableAnalytics: true, // Defaults to true
    enableCrashes: true, // Defaults to true
    enableDistribute: true, // Defaults to false
    usePrivateDistributeTrack: false, // Defaults to false
    disableAutomaticCheckForUpdate: false, // Defaults to false
  );
  
AppCenter.trackEventAsync('my event', <String, String> {
  'prop1': 'prop1',
  'prop2': 'prop2',
});
```

### Turn feature on / off at runtime

```dart
await AppCenter.configureAnalyticsAsync(enabled: true);

await AppCenter.configureCrashesAsync(enabled: true);

await AppCenter.configureDistributeAsync(enabled: true);

await AppCenter.configureDistributeDebugAsync(enabled: true); // Android Only

await AppCenter.checkForUpdateAsync(); // Manually check for update
```

## Troubleshooting

+  iOS: [!] CocoaPods could not find compatible versions for pod "AppCenter"

   Manually delete podfile.lock and rebuild, this is a common issue when upgrading iOS native dependencies.

+  Android build issue

   Always check if example project builds first
   If it does not build, please report an issue
   If it builds, check the gradle setup
   Checkpoints:
    + Gradle version in gradle-wrapper.properties
    + Kotlin version in build.gradle
    + compileSdkVersion in build.gradle
    + com.android.tools.build:gradle version in build.gradle
    + lintOptions (in example) See [issue](https://github.com/flutter/flutter/issues/58247)
  
      ```Execution failed for task ':app:lintVitalAppCenterRelease'```
    + build.gradle script (in example)
    + settings.gradle (in example)

+  jcenter retirement
   
   Replace jcenter since it will [be retired](https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/) on 1st of May, 2021.
   ```gradle
   repositories {
        google()
        // jcenter()
        mavenCentral()
        gradlePluginPortal()
    }
   ```
