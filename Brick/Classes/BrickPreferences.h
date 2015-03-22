@interface BrickPreferences : NSObject

# pragma mark Initialization

+ (void) loadDefaults;

# pragma mark Public Getters

+ (BOOL) debugMode;
+ (BOOL) rememberingOnReboot;
+ (NSString*) preferencesFilePath;
+ (NSString*) defaultsFilePath;
+ (NSString*) launchDaemonFilePath;

# pragma mark Public Setters

+ (void) toggleDebugMode;

@end
