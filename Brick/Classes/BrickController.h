@class BrickLayer;
@class BrickMenu;
@class BrickIntercom;

typedef NS_ENUM(NSInteger, HelperToolStatus) {
  HelperMissing,
  HelperVersionMismatch,
  HelperReady
};

@interface BrickController : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (readonly) NSStatusItem *statusItem;
@property (readonly) BrickMenu *statusMenu;
@property (readonly) BrickLayer *brickLayer;
@property (readonly) BrickIntercom *brickIntercom;
@property (readonly) NSImage *statusMenuIcon;

- (void) installHelperTool:(NSMenuItem*)sender;
- (void) getHelp:(NSMenuItem*)sender;
- (void) toggleDebugMode:(NSMenuItem*)sender;
- (void) toggleLogin:(NSMenuItem*)sender;

- (void) toggleRule:(NSMenuItem*)sender;

@end
