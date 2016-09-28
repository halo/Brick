#import "BrickController.h"

#import "BrickIntercom.h"
#import "BrickMenu.h"
#import "BrickLayer.h"
#import "BrickRules.h"
#import "BrickPreferences.h"
#import "NSBundle+LoginItem.h"

@implementation BrickController

@synthesize statusItem, brickMenu;
@synthesize brickIntercom;

# pragma mark Initialization

- (void) awakeFromNib {
  [Log debug:@"Awoke from NIB"];
  [BrickPreferences loadDefaults];
  self.statusItem.menu = self.brickMenu;
  [self refresh];
  [self addObservers];
}

- (void) addObservers {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
}

# pragma mark Callbacks

- (void) menuWillOpen:(NSMenu*)menu {
  [Log debug:@"Menu will open..."];
  [self refresh];
}

- (void) applicationWillTerminate:(NSNotification*)notification {
  [Log debug:@"applicationWillTerminate..."];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

# pragma mark Actions

- (void) installHelperTool:(NSMenuItem*)sender {
  [self.brickIntercom installHelperTool];
  [self refresh];
}

- (void) toggleActivation:(NSMenuItem*)sender {
  if ([BrickRules activated]) {
    [self deactivate];
  } else {
    [self activate];
  }
}

- (void) toggleRule:(NSMenuItem*)sender {
  NSString *identifier = sender.representedObject;
  [BrickRules toggleRuleWithIdentifier:identifier];
  [self activate];
}

- (void) getHelp:(NSMenuItem*)sender {
  NSString *description = [NSString stringWithFormat:@"For now, I refer to https://github.com/halo/Brick\n\nYou are currently running version %@ \n\nYour preferences are stored in %@\n\nYou can find the default preferences in %@\n\nOnce activated, the pf anchor is located at %@\n\nWhen remember on reboot is activated, the launchDaemon is located at %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey], [BrickPreferences preferencesFilePath], [BrickPreferences defaultsFilePath], [BrickRules anchorFilePath], [BrickPreferences launchDaemonFilePath]];
  NSAlert *alert = [NSAlert alertWithMessageText:@"Help!" defaultButton:@"Thanks" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", description];
  [alert runModal];
}

- (void) toggleDebugMode:(NSMenuItem*)sender {

}

- (void) toggleRememberOnReboot:(NSMenuItem*)sender {
  if ([BrickPreferences rememberingOnReboot]) {
    [Log debug:@"Deleting launchdaemon..."];
    [self.brickIntercom deactivateOnStartup];
  } else {
    [Log debug:@"Creating launchdaemon..."];
    [self.brickIntercom activateOnStartup];
  }
}

- (void) toggleLogin:(NSMenuItem*)sender {
  if ([[NSBundle mainBundle] isLoginItem]) {
    [[NSBundle mainBundle] removeFromLoginItems];
  } else {
    [[NSBundle mainBundle] addToLoginItems];
  }
}

# pragma mark Internal Helpers

- (void) refresh {
  [Log debug:@"Refreshing..."];
  [self refreshMenuIcon];
  [self.brickMenu refresh];
  [self refreshHelperStatus];
}

- (void) refreshHelperStatus {
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

- (void) refreshFromTimer:sender {
  [self refresh];
}

- (void) refreshSoon {
  [Log debug:@"Refreshing soon..."];
  [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(refreshFromTimer:) userInfo:nil repeats:NO];
}

- (void) refreshMenuIcon {
  statusItem.button.image = self.statusMenuIcon;
  statusItem.button.alternateImage = self.statusMenuIcon;
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

- (void) activate {
  [self.brickIntercom setRules:[BrickRules pf]];
  [self refreshSoon];
}

- (void) deactivate {
  [self.brickIntercom removeAllRules];
  [self refreshSoon];
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
