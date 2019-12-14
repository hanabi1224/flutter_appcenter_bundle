import Flutter
import UIKit

public class SwiftFlutterAppcenterBundlePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_appcenter_bundle", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterAppcenterBundlePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
