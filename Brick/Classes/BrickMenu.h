typedef NS_ENUM(NSInteger, MenuItemKind) {
  MenuItemAuthorize,
  MenuItemActivate,
  MenuItemRule,
};

@interface BrickMenu : NSMenu

@property (readonly) NSMenuItem* activationItem;
@property (readonly) NSMenuItem* authorizeHelperItem;

@property (atomic) BOOL authorized;

- (void) load;

- (void) refreshAssumingUnauthorized;
- (void) refreshAssumingAuthorized;

@end
