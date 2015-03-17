@interface BrickIntercom : NSObject

@property (atomic, strong, readwrite) NSXPCConnection *helperToolConnection;

- (BOOL) installHelperTool;
- (void) getVersionWithReply:(void(^)(NSString*))block;

- (void) setRules:(NSString*)rules withReply:(void(^)(BOOL))block;
- (void) removeAllRulesWithReply:(void(^)(BOOL success))block;
- (void) activateOnStartupWithReply:(void(^)(BOOL success))block;
- (void) deactivateOnStartupWithReply:(void(^)(BOOL success))block;

@end
