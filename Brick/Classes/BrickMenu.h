typedef NS_ENUM(NSInteger, MenuItemKind) {
  MenuItemDefault,
  MenuItemRule,
};

@interface BrickMenu : NSMenu

@property (readonly) NSMenuItem* activationItem;
@property (readonly) NSMenuItem* authorizeHelperItem;
@property (readonly) NSMenuItem* topRulesSeparator;
@property (readonly) NSMenuItem* rememberOnRebootItem;
@property (readonly) NSMenuItem* launchOnLoginItem;
@property (readonly) NSMenuItem* preferencesItem;
@property (readonly) NSMenu* preferencesSubMenu;
@property (readonly) NSMenuItem* helpItem;
@property (readonly) NSMenuItem* quitItem;
@property (readonly) NSInteger topRuleIndex;
@property (atomic) BOOL authorized;

# pragma mark Initialization

- (void) load;

# pragma mark Refreshing

- (void) authorize;
- (void) unauthorize;
- (void) refresh;

@end
