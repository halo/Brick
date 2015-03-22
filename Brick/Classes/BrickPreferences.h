@interface BrickPreferences : NSObject

# pragma mark Initialization

+ (void) loadDefaults;

# pragma mark Public Getters

+ (BOOL) debugMode;
+ (BOOL) rememberingOnReboot;
+ (NSString*) preferencesFilePath;

# pragma mark Public Setters

+ (void) toggleDebugMode;

@end
