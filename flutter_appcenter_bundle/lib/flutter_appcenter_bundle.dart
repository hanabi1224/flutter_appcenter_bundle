import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _methodChannelName = "com.github.hanabi1224.flutter_appcenter_bundle";
final _methodChannel = MethodChannel(_methodChannelName);

class AppCenter {
  static Future startAsync({
    @required String appSecretAndroid,
    @required String appSecretIOS,
    enableAnalytics = true,
    enableCrashes = true,
    enableDistribute = false,
    usePrivateDistributeTrack = false,
    disableAutomaticCheckForUpdate = false,
  }) async {
    String appsecret;
    if (Platform.isAndroid) {
      appsecret = appSecretAndroid;
    } else if (Platform.isIOS) {
      appsecret = appSecretIOS;
    } else {
      throw UnsupportedError('Current platform is not supported.');
    }

    if (appsecret == null || appsecret.isEmpty) {
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();

    if (disableAutomaticCheckForUpdate) {
      await _disableAutomaticCheckForUpdateAsync();
    }

    await configureAnalyticsAsync(enabled: enableAnalytics);
    await configureCrashesAsync(enabled: enableCrashes);
    await configureDistributeAsync(enabled: enableDistribute);

    await _methodChannel.invokeMethod('start', <String, dynamic>{
      'secret': appsecret.trim(),
      'usePrivateTrack': usePrivateDistributeTrack,
    });
  }

  static Future trackEventAsync(String name,
      [Map<String, String> properties]) async {
    await _methodChannel.invokeMethod('trackEvent', <String, dynamic>{
      'name': name,
      'properties': properties ?? <String, String>{},
    });
  }

  static Future<bool> isAnalyticsEnabledAsync() async {
    return await _methodChannel.invokeMethod('isAnalyticsEnabled');
  }

  static Future<String> getInstallIdAsync() async {
    return await _methodChannel.invokeMethod('getInstallId').then((r) => r as String);
  }

  static Future configureAnalyticsAsync({@required enabled}) async {
    await _methodChannel.invokeMethod('configureAnalytics', enabled);
  }

  static Future<bool> isCrashesEnabledAsync() async {
    return await _methodChannel.invokeMethod('isCrashesEnabled');
  }

  static Future configureCrashesAsync({@required enabled}) async {
    await _methodChannel.invokeMethod('configureCrashes', enabled);
  }

  static Future<bool> isDistributeEnabledAsync() async {
    return await _methodChannel.invokeMethod('isDistributeEnabled');
  }

  static Future configureDistributeAsync({@required enabled}) async {
    await _methodChannel.invokeMethod('configureDistribute', enabled);
  }

  static Future configureDistributeDebugAsync({@required enabled}) async {
    await _methodChannel.invokeMethod('configureDistributeDebug', enabled);
  }

  static Future _disableAutomaticCheckForUpdateAsync() async {
    await _methodChannel.invokeMethod('disableAutomaticCheckForUpdate');
  }

  static Future checkForUpdateAsync() async {
    await _methodChannel.invokeMethod('checkForUpdate');
  }
}
