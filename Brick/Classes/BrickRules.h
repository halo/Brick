@interface BrickRules : NSObject

# pragma mark Public Getters

+ (NSArray*) all;
+ (NSString*) pf;
+ (BOOL) activated;

# pragma mark Public Setters

+ (void) toggleRuleWithIdentifier:(NSString*)identifier;

@end
