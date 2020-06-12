#import "DisableScreenshotsPlugin.h"
#if __has_include(<disable_screenshots/disable_screenshots-Swift.h>)
#import <disable_screenshots/disable_screenshots-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "disable_screenshots-Swift.h"
#endif

@implementation DisableScreenshotsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDisableScreenshotsPlugin registerWithRegistrar:registrar];
}
@end
