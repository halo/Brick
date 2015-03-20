@interface BrickRule : NSObject

@property (strong) NSString* identifier;
@property (strong) NSString* name;
@property (nonatomic) NSString* comment;
@property (nonatomic) NSArray* rules;
@property (atomic) BOOL activated;
@property (readonly) NSString* pf;

@end
