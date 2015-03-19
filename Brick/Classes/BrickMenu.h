typedef NS_ENUM(NSInteger, MenuItemKind) {
  MenuItemAuthorize,
  MenuItemActivate,
  MenuItemRule,
};

@interface BrickMenu : NSMenu

@property (readonly) NSMenuItem* activationItem;
@property (readonly) NSMenuItem* authorizeHelperItem;
@property (atomic) BOOL authorized;

# pragma mark Initialization

- (void) load;

# pragma mark Refreshing

- (void) authorize;
- (void) unauthorize;
- (void) refreshRules;

@end
