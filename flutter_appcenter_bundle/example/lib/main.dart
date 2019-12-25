import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppCenter.startAsync(
    appSecretAndroid: '49361c2e-b788-4bc2-a33d-838b04b3e06b',
    appSecretIOS: '2da3d93f-6b3f-48f9-920f-2d63ae3cd25a',
    enableDistribute: false,
  );
  await AppCenter.configureDistributeDebugAsync(enabled: false);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PackageInfo _packageInfo;
  bool _isCrashesEnabled;
  bool _isAnalyticsEnabled;
  bool _isDistributeEnabled;

  @override
  void initState() {
    super.initState();
    AppCenter.trackEventAsync('_MyAppState.initState');
    PackageInfo.fromPlatform().then((v) {
      setState(() {
        _packageInfo = v;
      });
    });
    AppCenter.isCrashesEnabledAsync().then((v) {
      setState(() {
        _isCrashesEnabled = v;
      });
    });
    AppCenter.isAnalyticsEnabledAsync().then((v) {
      setState(() {
        _isAnalyticsEnabled = v;
      });
    });
    AppCenter.isDistributeEnabledAsync().then((v) {
      setState(() {
        _isDistributeEnabled = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
            padding: EdgeInsets.all(20),
            child: _packageInfo == null
                ? RefreshProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('App name:\n${_packageInfo.appName}'),
                      Text(''),
                      Text('Package name:\n${_packageInfo.packageName}'),
                      Text(''),
                      Text('Version:\n${_packageInfo.version}'),
                      Text(''),
                      Text('Build:\n${_packageInfo.buildNumber}'),
                      Text(''),
                      Text('IsCrashesEnabled: $_isCrashesEnabled'),
                      Text('IsAnalyticsEnabled: $_isAnalyticsEnabled'),
                      Text('IsDistributeEnabled: $_isDistributeEnabled'),
                    ],
                  )),
      ),
    );
  }
}
