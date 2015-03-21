#import "BrickMenu.h"

#import "BrickController.h"
#import "BrickRule.h"
#import "BrickRules.h"
#import "BrickPreferences.h"
#import "NSBundle+LoginItem.h"

@implementation BrickMenu

@synthesize authorized;
@synthesize authorizeHelperItem, activationItem, topRulesSeparator;
@synthesize topRuleIndex;

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
  if ([BrickRules activated]) {
    self.activationItem.title = @"Deactivate filter";
  } else {
    self.activationItem.title = @"Activate filter";
  }
}

# pragma mark Internal Helpers

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
    [self insertItem:[self menuForRule:rule] atIndex:insertionIndex];
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
  [Log debug:@"Created MenuItem %@", item];

  return item;
}

- (NSInteger) topRuleIndex {
  return [self indexOfItem:self.topRulesSeparator] + 1;
}

- (void) addSuffixItems {
  [self addItem:[NSMenuItem separatorItem]];
  [self addItem:[self helpItem]];
  [self addItem:[self quitItem]];
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

- (NSMenuItem*) helpItem {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Help" action:@selector(getHelp:) keyEquivalent:@""];
  item.target = self.delegate;
  return item;
}

- (NSMenuItem*) quitItem {
  return [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
}

@end
