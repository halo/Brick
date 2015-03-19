#import "BrickMenu.h"

#import "BrickController.h"
#import "BrickRule.h"
#import "BrickRules.h"
#import "BrickPreferences.h"
#import "NSBundle+LoginItem.h"

@implementation BrickMenu

@synthesize authorized;
@synthesize authorizeHelperItem, activationItem;

# pragma mark Initialization

- (void) load {
  [self addItem:[self authorizeHelperItem]];
  [self addItem:[self activationItem]];
  [self addItem:[NSMenuItem separatorItem]];
  [self addItem: [[NSMenuItem alloc] initWithTitle:@"Allow outgoing" action:nil keyEquivalent:@""]];
  [self addRules];
  [self addSuffixItems];
}

# pragma mark Refreshing

- (void) authorize {
  [Log debug:@"Menu assumes helper exists..."];
  self.authorized = YES;
  self.authorizeHelperItem.hidden = YES;
  self.activationItem.hidden = NO;
}

- (void) unauthorize {
  [Log debug:@"Menu assumes helper is missing..."];
  self.authorized = NO;
  self.authorizeHelperItem.hidden = NO;
  self.activationItem.hidden = YES;
}

- (void) refreshRules {
  [self removeRules];
  [self addRules];
}

# pragma mark Internal Helpers

- (void) removeRules {
  NSMenuItem* item;
  while ((item = [self itemWithTag:MenuItemRule])) {
    [self removeItem:item];
  }
}

- (void) addRules {
  [Log debug:@"Adding rules..."];
  for (BrickRule* rule in [BrickRules all]) {
    if (!rule.name) continue;
    [self addItem:[self menuForRule:rule]];
  }
}

- (NSMenuItem*) menuForRule:(BrickRule*)rule {
  [Log debug:@"Adding rule: %@", rule];
  [Log debug:@"Name: %@", rule.name];

  NSMenuItem *item = [NSMenuItem new];
  item.title = rule.name;
  item.representedObject = rule.identifier;
  item.toolTip = rule.comment;
  item.target = self.delegate;
  if (rule.activated) item.state = NSOnState;
  if (self.authorized) item.action = @selector(toggleRule:);
  item.tag = MenuItemRule;
  [Log debug:@"Created MenuItem %@", item];

  return item;
}

- (void) addSuffixItems {
  [self addItem:[NSMenuItem separatorItem]];
  [self addItem:[self helpItem]];
  [self addItem:[self quitItem]];
}

- (NSMenuItem*) activationItem {
  if (activationItem) return activationItem;
  activationItem = [[NSMenuItem alloc] initWithTitle:@"Activate" action:@selector(toggleActivation:) keyEquivalent:@""];
  activationItem.target = self.delegate;
  activationItem.tag = MenuItemActivate;
  activationItem.hidden = YES;
  return activationItem;
}

- (NSMenuItem*) authorizeHelperItem {
  if (authorizeHelperItem) return authorizeHelperItem;
  authorizeHelperItem = [[NSMenuItem alloc] initWithTitle:@"Authorize..." action:@selector(installHelperTool:) keyEquivalent:@""];
  authorizeHelperItem.target = self.delegate;
  authorizeHelperItem.tag = MenuItemAuthorize;
  return authorizeHelperItem;
}

- (NSMenuItem*) helpItem {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Help" action:@selector(getHelp:) keyEquivalent:@""];
  item.target = self.delegate;
  return item;
}

- (NSMenuItem*) quitItem {
  return [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
}

@end
