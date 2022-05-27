#import "FlutterAppcenterBundlePlugin.h"
#if __has_include(<flutter_appcenter_bundle/flutter_appcenter_bundle-Swift.h>)
#import <flutter_appcenter_bundle/flutter_appcenter_bundle-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_appcenter_bundle-Swift.h"
#endif

@implementation FlutterAppcenterBundlePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAppcenterBundlePlugin registerWithRegistrar:registrar];
}
@end
