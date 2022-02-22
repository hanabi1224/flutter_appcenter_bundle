import Foundation
import Flutter
import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute

typealias MSAppCenter = AppCenter
typealias MSAnalytics = Analytics
typealias MSCrashes = Crashes
typealias MSDistribute = Distribute

public class SwiftFlutterAppcenterBundlePlugin: NSObject, FlutterPlugin {
    static let methodChannelName = "com.github.hanabi1224.flutter_appcenter_bundle";
    static let instance = SwiftFlutterAppcenterBundlePlugin();

    public static func register(binaryMessenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: binaryMessenger)
        methodChannel.setMethodCallHandler(instance.methodChannelHandler);
        return methodChannel;
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        register(binaryMessenger: registrar.messenger());
    }

    public func methodChannelHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint(call.method)
        switch call.method {
        case "start":
            guard let args:[String: Any] = (call.arguments as? [String: Any]) else {
                result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (start)") )
                return
            }

            let secret = args["secret"] as! String
            let usePrivateTrack = args["usePrivateTrack"] as! Bool
            if (usePrivateTrack) {
                MSDistribute.updateTrack = .private
            }

            MSAppCenter.start(withAppSecret: secret, services:[
                MSAnalytics.self,
                MSCrashes.self,
                MSDistribute.self,
            ])
        case "trackEvent":
            trackEvent(call: call, result: result)
            return
        case "trackError":
            let args: [String: Any]? = (call.arguments as? [String: Any])
            Crashes.trackError(
                NSError(domain: Bundle.main.bundleIdentifier ?? "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: args?["message"] ?? ""]),
                properties: args?["properties"] as? [String: String],
                attachments: nil
            )
            return
        case "isDistributeEnabled":
            result(MSDistribute.enabled)
            return
        case "getInstallId":
            result(MSAppCenter.installId.uuidString)
        case "configureDistribute":
            MSDistribute.enabled = call.arguments as! Bool
        case "configureDistributeDebug":
            result(nil)
            return
        case "disableAutomaticCheckForUpdate":
            MSDistribute.disableAutomaticCheckForUpdate()
        case "checkForUpdate":
            MSDistribute.checkForUpdate()
            return
        case "isCrashesEnabled":
            result(MSCrashes.enabled)
        case "configureCrashes":
            MSCrashes.enabled = call.arguments as! Bool
            return
        case "isAnalyticsEnabled":
            result(MSAnalytics.enabled)
        case "configureAnalytics":
            MSAnalytics.enabled = call.arguments as! Bool
        default:
            result(FlutterMethodNotImplemented);
            return
        }

        result(nil);
    }

    private func trackEvent(call: FlutterMethodCall, result: FlutterResult) {
        guard let args:[String: Any] = (call.arguments as? [String: Any]) else {
            result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (trackEvent)") )
            return
        }

        let name = args["name"] as? String
        let properties = args["properties"] as? [String: String]
        if(name != nil) {
            MSAnalytics.trackEvent(name!, withProperties: properties)
        }

        result(nil)
    }
}
