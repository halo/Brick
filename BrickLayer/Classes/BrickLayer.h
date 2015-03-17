#define kBrickLayerIdentifier @"com.funkensturm.BrickLayer"

@protocol BrickLayerProtocol

@required

- (void) connectWithEndpointReply:(void(^)(NSXPCListenerEndpoint *endpoint))reply;

- (void) getVersionWithReply:(void(^)(NSString *version)) reply;
- (void) setRules:(NSString*)rules withReply:(void(^)(BOOL success))reply;
- (void) removeAllRulesWithReply:(void(^)(BOOL success))reply;
- (void) activateOnStartupWithReply:(void(^)(BOOL success))reply;
- (void) deactivateOnStartupWithReply:(void(^)(BOOL success))reply;

@end

@interface BrickLayer : NSObject

- (id) init;
- (void) run;

@end
