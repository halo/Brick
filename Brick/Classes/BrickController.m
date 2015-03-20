#import "BrickController.h"

#import "BrickIntercom.h"
#import "BrickMenu.h"
#import "BrickLayer.h"
#import "BrickRules.h"
#import "BrickPreferences.h"

@implementation BrickController

@synthesize statusItem, brickMenu;
@synthesize brickIntercom;

# pragma mark Initialization

- (void) awakeFromNib {
  [Log debug:@"Awoke from NIB"];
  [BrickPreferences loadDefaults];
  self.statusItem.menu = self.brickMenu;
}

# pragma mark Callbacks

- (void) menuWillOpen:(NSMenu*)menu {
  [Log debug:@"Menu will open..."];
  [self refresh];
}

# pragma mark Actions

- (void) installHelperTool:(NSMenuItem*)sender {
  [self.brickIntercom installHelperTool];
  [self refresh];
}

- (void) toggleActivation:(NSMenuItem*)sender {
  if ([BrickRules activated]) {
    [self.brickIntercom removeAllRules];
  } else {
    [self.brickIntercom setRules:[BrickRules pf]];
  }
}

- (void) toggleRule:(NSMenuItem*)sender {
  NSString *identifier = sender.representedObject;
  [BrickRules toggleRuleWithIdentifier:identifier];
  [self update];
}

- (void) getHelp:(NSMenuItem*)sender {
  
}

- (void) toggleDebugMode:(NSMenuItem*)sender {
  
}

- (void) toggleLogin:(NSMenuItem*)sender {
  
}

# pragma mark Internal Helpers

- (void) refresh {
  [self.brickMenu refreshRules];
  [Log debug:@"Checking for helper..."];
  [self usingHelperTool:^(NSInteger helperStatus, NSString *helperVersion) {
    if (helperStatus == HelperReady) {
      [Log debug:@"Yes, the helper is up and running."];
      [self.brickMenu authorize];
    } else {
      [Log debug:@"Nopes, the helper is missing."];
      [self.brickMenu unauthorize];
    }
  }];
}

- (void) update {
  
}

- (void) usingHelperTool:(void(^)(NSInteger, NSString*))block {
  [self.brickIntercom getVersionWithReply:^(NSString *helperVersion) {
    if (helperVersion == nil) {
      [Log debug:@"Helper Tool probably not installed!"];
      block(HelperMissing, nil);
    } else if ([helperVersion isEqualToString:self.requiredHelperVersion]) {
      [Log debug:@"Yeah, this is the Helper I want."];
      block(HelperReady, nil);
    } else {
      [Log debug:@"Helper Tool mismatch! I want %@ but Helper is at %@", self.requiredHelperVersion, helperVersion];
      block(HelperVersionMismatch, helperVersion);
    }
  }];
}

# pragma mark Internal Getters

- (NSString*) requiredHelperVersion {
  return @"0.0.1";
}

- (BrickMenu*) brickMenu {
  if (brickMenu) return brickMenu;
  brickMenu = [BrickMenu new];
  brickMenu.delegate = self;
  [brickMenu load];
  return brickMenu;
}

- (BrickIntercom*) brickIntercom {
  if (brickIntercom) return brickIntercom;
  brickIntercom = [BrickIntercom new];
  return brickIntercom;
}

- (NSStatusItem*) statusItem {
  if (statusItem) return statusItem;
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
  statusItem.button.image = self.statusMenuIcon;
  statusItem.button.alternateImage = self.statusMenuIcon;
  statusItem.highlightMode = YES;
  statusItem.button.accessibilityTitle = @"Brick";
  return statusItem;
}

- (NSImage*) statusMenuIcon {
  NSImage *icon;
  if ([BrickRules activated]) {
    icon = [NSImage imageNamed:@"MenuIconSatelliteOff"];
  } else {
    icon = [NSImage imageNamed:@"MenuIconSatelliteOn"];
  }
  // Allows the correct highlighting of the icon when the menu is clicked.
  [icon setTemplate:YES];
  return icon;
}

@end
