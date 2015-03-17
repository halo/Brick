#import "BrickMenu.h"

#import "BrickController.h"
#import "BrickPF.h"
#import "BrickRule.h"
#import "BrickRules.h"
#import "BrickPreferences.h"
#import "NSBundle+LoginItem.h"

@implementation BrickMenu

- (void) refresh {
  [self removeAllItems];
  [self addItem:[self aktivationItem]];
  [self addRulesActionable:YES];
  [self addSuffixItems];
}

- (void) helperMissing {
  [self removeAllItems];
  [self addItem:[self authorizeHelperItem]];
  [self addRulesActionable:NO];
  [self addSuffixItems];
}

# pragma mark Internal Helpers

- (void) addRulesActionable:(BOOL)actionable {
  [Log debug:@"Adding rules..."];
  [self addItem:[NSMenuItem separatorItem]];
  [self addItem: [[NSMenuItem alloc] initWithTitle:@"Allow outgoing" action:nil keyEquivalent:@""]];
  for (BrickRule* rule in [BrickRules all]) {
    if (!rule.name) continue;
    [self addItem:[self menuForRule:rule actionable:actionable]];
  }
}

- (NSMenuItem*) menuForRule:(BrickRule*)rule actionable:(BOOL)actionable {
  [Log debug:@"Adding rule: %@", rule];
  [Log debug:@"Name: %@", rule.name];

  NSMenuItem *item = [NSMenuItem new];
  item.title = rule.name;
  item.representedObject = rule.identifier;
  item.toolTip = rule.comment;
  item.target = self.delegate;
  if (rule.activated) item.state = NSOnState;
  if (actionable) item.action = @selector(toggleRule:);
  [Log debug:@"Created MenuItem %@", item];

  return item;
}

- (void) addSuffixItems {
  [self addItem:[NSMenuItem separatorItem]];
  [self addItem:[self helpItem]];
  [self addItem:[self quitItem]];
}

- (NSMenuItem*) aktivationItem {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Activate" action:@selector(toggleActivation:) keyEquivalent:@""];
  item.target = self.delegate;
  return item;
}

- (NSMenuItem*) authorizeHelperItem {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Authorize..." action:@selector(installHelperTool:) keyEquivalent:@""];
  item.target = self.delegate;
  return item;
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
