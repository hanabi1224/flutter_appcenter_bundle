import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _methodChannelName = "com.github.hanabi1224.flutter_appcenter_bundle";
final _methodChannel = MethodChannel(_methodChannelName);

class AppCenter {
  static var _started = false;
  static Future startAsync({
    @required String appSecretAndroid,
    @required String appSecretIOS,
    enableAnalytics = true,
    enableCrashes = true,
    enableDistribute = false,
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
    await _methodChannel.invokeMethod('start', appsecret.trim());
    _started = true;

    if (!enableAnalytics) {
      await configureAnalyticsAsync(enabled: enableAnalytics);
    }
    if (!enableCrashes) {
      await configureCrashesAsync(enabled: enableCrashes);
    }
    if (!enableDistribute) {
      await configureDistributeAsync(enabled: enableDistribute);
    }
  }

  static Future trackEventAsync(String name,
      [Map<String, String> properties]) async {
    await _methodChannel.invokeMethod('trackEvent', <String, dynamic>{
      'name': name,
      'properties': properties ?? <String, String>{},
    });
  }

  static Future<bool> isAnalyticsEnabledAsync() async {
    if (!_started) {
      return false;
    }
    return await _methodChannel.invokeMethod('isAnalyticsEnabled');
  }

  static Future configureAnalyticsAsync({@required enabled}) async {
    if (!_started) {
      return;
    }
    await _methodChannel.invokeMethod('configureAnalytics', enabled);
  }

  static Future<bool> isCrashesEnabledAsync() async {
    if (!_started) {
      return false;
    }
    return await _methodChannel.invokeMethod('isCrashesEnabled');
  }

  static Future configureCrashesAsync({@required enabled}) async {
    if (!_started) {
      return;
    }
    await _methodChannel.invokeMethod('configureCrashes', enabled);
  }

  static Future<bool> isDistributeEnabledAsync() async {
    if (!_started) {
      return false;
    }
    return await _methodChannel.invokeMethod('isDistributeEnabled');
  }

  static Future configureDistributeAsync({@required enabled}) async {
    if (!_started) {
      return;
    }
    await _methodChannel.invokeMethod('configureDistribute', enabled);
  }

  static Future configureDistributeDebugAsync({@required enabled}) async {
    if (!_started) {
      return;
    }
    await _methodChannel.invokeMethod('configureDistributeDebug', enabled);
  }
}
