@interface BrickIntercom : NSObject

@property (atomic, strong, readwrite) NSXPCConnection *helperToolConnection;

- (BOOL) installHelperTool;
- (void) getVersionWithReply:(void(^)(NSString*))block;

- (void) setRules:(NSString*)rules;
- (void) removeAllRules;
- (void) activateOnStartup;
- (void) deactivateOnStartup;

@end
