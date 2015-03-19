#import "BrickController.h"

#import "BrickIntercom.h"
#import "BrickMenu.h"
#import "BrickLayer.h"
#import "BrickRules.h"
#import "BrickPF.h"
#import "BrickPreferences.h"

@implementation BrickController

@synthesize statusItem, statusMenu;
@synthesize brickIntercom;

# pragma mark Initialization

- (void) awakeFromNib {
  [Log debug:@"Awoke from NIB"];
  self.statusItem.menu = self.statusMenu;
  [BrickPreferences loadDefaults];
  [self.statusMenu load];
}

# pragma mark Callbacks

- (void) menuWillOpen:(NSMenu*)menu {
  [Log debug:@"Menu will open..."];
  [self refresh];
}

# pragma mark Actions

- (void) toggleActivation:(NSMenuItem*)sender {
  
}

- (void) toggleRule:(NSMenuItem*)sender {
  NSString *identifier = sender.representedObject;
  [BrickRules toggleRuleWithIdentifier:identifier];
  [self update];
}

- (void) installHelperTool:(NSMenuItem*)sender {
  [self.brickIntercom installHelperTool];
  [self.statusMenu refreshAssumingAuthorized];
}

- (void) getHelp:(NSMenuItem*)sender {
  
}

- (void) toggleDebugMode:(NSMenuItem*)sender {
  
}

- (void) toggleLogin:(NSMenuItem*)sender {
  
}

# pragma mark Internal Helpers

- (void) refresh {
  [Log debug:@"Checking for helper..."];
  [self usingHelperTool:^(NSInteger helperStatus, NSString *helperVersion) {
    if (helperStatus == HelperReady) {
      [Log debug:@"Yes, the helper is up and running."];
      [self.statusMenu refreshAssumingAuthorized];
    } else {
      [Log debug:@"Nopes, the helper is missing."];
      [self.statusMenu refreshAssumingUnauthorized];
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

- (BrickMenu*) statusMenu {
  if (statusMenu) return statusMenu;
  statusMenu = [BrickMenu new];
  statusMenu.delegate = self;
  return statusMenu;
}

- (BrickIntercom*) brickIntercom {
  if (brickIntercom) return brickIntercom;
  brickIntercom = [BrickIntercom new];
  return brickIntercom;
}

- (NSStatusItem*) statusItem {
  if (statusItem) return statusItem;
  
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
  
  self.statusItem.button.image = self.statusMenuIcon;
  self.statusItem.button.alternateImage = self.statusMenuIcon;
  self.statusItem.highlightMode = YES;
  
  statusItem.button.accessibilityTitle = @"Brick";
  //statusItem.button.appearsDisabled = YES;
  return statusItem;
}

- (NSImage*) statusMenuIcon {
  NSImage *icon;
  if ([BrickPF rulesActivated]) {
    icon = [NSImage imageNamed:@"MenuIconSatelliteOff"];
  } else {
    icon = [NSImage imageNamed:@"MenuIconSatelliteOn"];
  }
  [icon setTemplate:YES]; // Allows the correct highlighting of the icon when the menu is clicked.
  return icon;
}

@end
