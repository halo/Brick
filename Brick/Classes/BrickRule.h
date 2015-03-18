@interface BrickRule : NSObject

@property (strong) NSString* identifier;
@property (strong) NSString* name;
@property (strong) NSString* comment;
@property (strong) NSArray* rules;
@property (atomic) BOOL activated;
@property (readonly) NSString* pf;

@end
