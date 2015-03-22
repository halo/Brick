#import "BrickMenu.h"

#import "BrickController.h"
#import "BrickRule.h"
#import "BrickRules.h"
#import "BrickPreferences.h"
#import "NSBundle+LoginItem.h"
#import "NSBundle+LoginItem.h"

@implementation BrickMenu

@synthesize authorized;
@synthesize authorizeHelperItem, activationItem, topRulesSeparator;
@synthesize topRuleIndex, launchOnLoginItem;
@synthesize preferencesItem, preferencesSubMenu, rememberOnRebootItem, helpItem, quitItem;

# pragma mark Initialization

- (void) load {
  [Log debug:@"Loading default MenuItems..."];
  [self addItem:self.authorizeHelperItem];
  [self addItem:self.activationItem];
  [self addItem:self.topRulesSeparator];
  [self addRules];
  [self addSuffixItems];
}

# pragma mark Refreshing

- (void) authorize {
  [Log debug:@"Menu assumes helper exists..."];
  self.authorized = YES;
  self.authorizeHelperItem.hidden = YES;
  self.activationItem.hidden = NO;
  self.preferencesItem.hidden = NO;
}

- (void) unauthorize {
  [Log debug:@"Menu assumes helper is missing..."];
  self.authorized = NO;
  self.authorizeHelperItem.hidden = NO;
  self.activationItem.hidden = YES;
  self.preferencesItem.hidden = YES;
}

- (void) refresh {
  [self refreshPreferences];
  [self refreshRules];
}

# pragma mark Internal Helpers

- (void) refreshPreferences {
  [Log debug:@"Refreshing preferences menu..."];
  self.rememberOnRebootItem.state = [BrickPreferences rememberingOnReboot];
  self.launchOnLoginItem.state = [[NSBundle mainBundle] isLoginItem];
}

- (void) refreshRules {
  [self removeRules];
  [self addRules];
  if ([BrickRules activated]) {
    self.activationItem.title = @"Deactivate filter";
  } else {
    self.activationItem.title = @"Activate filter";
  }
}

- (void) removeRules {
  for (NSMenuItem *item in self.itemArray) {
    if (item.tag == MenuItemRule) [self removeItem:item];
  }
}

- (void) addRules {
  [Log debug:@"Adding rules..."];
  NSMenuItem *ruleItem;
  NSInteger insertionIndex;
  
  for (BrickRule* rule in [BrickRules all]) {
    if (!rule.name) continue;
    if (ruleItem) {
      insertionIndex = [self indexOfItem:ruleItem] + 1;
    } else {
      insertionIndex = self.topRuleIndex;
    }
    ruleItem = [self menuForRule:rule];
    [self insertItem:ruleItem atIndex:insertionIndex];
  }
}

- (NSMenuItem*) menuForRule:(BrickRule*)rule {
  [Log debug:@"Adding rule: %@, %@, actionable: %i", rule.identifier, rule.name, self.authorized];

  NSMenuItem *item = [NSMenuItem new];
  item.title = rule.name;
  item.representedObject = rule.identifier;
  item.toolTip = rule.comment;
  item.target = self.delegate;
  if (rule.activated) item.state = NSOnState;
  if (self.authorized) item.action = @selector(toggleRule:);
  item.tag = MenuItemRule;
  return item;
}

- (NSInteger) topRuleIndex {
  return [self indexOfItem:self.topRulesSeparator] + 1;
}

- (void) addSuffixItems {
  [self addItem:[NSMenuItem separatorItem]];
  [self addItem:self.preferencesItem];
  [self addItem:self.helpItem];
  [self addItem:self.quitItem];
}

- (NSMenuItem*) activationItem {
  if (activationItem) return activationItem;
  activationItem = [[NSMenuItem alloc] initWithTitle:@"Loading..." action:@selector(toggleActivation:) keyEquivalent:@""];
  activationItem.target = self.delegate;
  activationItem.hidden = YES;
  return activationItem;
}

- (NSMenuItem*) authorizeHelperItem {
  if (authorizeHelperItem) return authorizeHelperItem;
  authorizeHelperItem = [[NSMenuItem alloc] initWithTitle:@"Authorize..." action:@selector(installHelperTool:) keyEquivalent:@""];
  authorizeHelperItem.target = self.delegate;
  return authorizeHelperItem;
}

- (NSMenuItem*) topRulesSeparator {
  if (topRulesSeparator) return topRulesSeparator;
  topRulesSeparator = [NSMenuItem separatorItem];
  return topRulesSeparator;
}

- (NSMenuItem*) preferencesItem {
  if (preferencesItem) return preferencesItem;
  preferencesItem = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:nil keyEquivalent:@""];
  preferencesItem.submenu = self.preferencesSubMenu;
  preferencesItem.hidden = YES;
  return preferencesItem;
}

- (NSMenu*) preferencesSubMenu {
  if (preferencesSubMenu) return preferencesSubMenu;
  preferencesSubMenu = [NSMenu new];
  [preferencesSubMenu addItem:self.rememberOnRebootItem];
  [preferencesSubMenu addItem:self.launchOnLoginItem];
  return preferencesSubMenu;
}

- (NSMenuItem*) rememberOnRebootItem {
  if (rememberOnRebootItem) return rememberOnRebootItem;
  rememberOnRebootItem = [[NSMenuItem alloc] initWithTitle:@"Remember on reboot" action:@selector(toggleRememberOnReboot:) keyEquivalent:@""];
  rememberOnRebootItem.target = self.delegate;
  return rememberOnRebootItem;
}

- (NSMenuItem*) launchOnLoginItem {
  if (launchOnLoginItem) return launchOnLoginItem;
  launchOnLoginItem = [[NSMenuItem alloc] initWithTitle:@"Launch GUI on login" action:@selector(toggleLogin:) keyEquivalent:@""];
  launchOnLoginItem.target = self.delegate;
  return launchOnLoginItem;
}

- (NSMenuItem*) helpItem {
  if (helpItem) return helpItem;
  helpItem = [[NSMenuItem alloc] initWithTitle:@"Help" action:@selector(getHelp:) keyEquivalent:@""];
  helpItem.target = self.delegate;
  return helpItem;
}

- (NSMenuItem*) quitItem {
  if (quitItem) return quitItem;
  quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
  helpItem.target = self.delegate;
  return quitItem;
}

@end
