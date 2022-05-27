import Foundation
import Flutter
import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute

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

            MSAppCenter.start(secret, withServices:[
                MSAnalytics.self,
                MSCrashes.self,
                MSDistribute.self,
            ])
        case "trackEvent":
            trackEvent(call: call, result: result)
            return
        case "isDistributeEnabled":
            result(MSDistribute.isEnabled())
            return
        case "getInstallId":
            result(MSAppCenter.installId().uuidString)
            return
        case "configureDistribute":
            MSDistribute.setEnabled(call.arguments as! Bool)
        case "configureDistributeDebug":
            result(nil)
            return
        case "disableAutomaticCheckForUpdate":
            MSDistribute.disableAutomaticCheckForUpdate()
        case "checkForUpdate":
            MSDistribute.checkForUpdate()
        case "isCrashesEnabled":
            result(MSCrashes.isEnabled())
            return
        case "configureCrashes":
            MSCrashes.setEnabled(call.arguments as! Bool)
        case "isAnalyticsEnabled":
            result(MSAnalytics.isEnabled())
            return
        case "configureAnalytics":
            MSAnalytics.setEnabled(call.arguments as! Bool)
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
