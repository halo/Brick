@interface BrickRules : NSObject

# pragma mark Public Getters

+ (NSArray*) all;
+ (NSString*) pf;
+ (BOOL) activated;
+ (NSString*) anchorFilePath;

# pragma mark Public Setters

+ (void) toggleRuleWithIdentifier:(NSString*)identifier;

@end
