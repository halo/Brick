@interface BrickPreferences : NSObject

+ (void) loadDefaults;
+ (BOOL) debugMode;
+ (void) toggleDebugMode;

@end
