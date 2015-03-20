#import "BrickLayer.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>

@interface BrickLayer () <NSXPCListenerDelegate, BrickLayerProtocol>

@property (atomic, strong, readwrite) NSXPCListener *listener;

@end

const NSString *pfctlExecutable = @"/sbin/pfctl";
const NSString *launchctlExecutable = @"/bin/launchctl";
const NSString *launchdLabel = @"com.funkensturm.Brick";
const NSString *launchDaemonPlistPath = @"/Library/LaunchDaemons/com.funkensturm.Brick.plist";
const NSString *PFAnchorName = @"com.apple/249.Brick";
const NSString *PFAnchorPath = @"/etc/pf.anchors/com.funkensturm.Brick";

@implementation BrickLayer

- (id) init {
  self = [super init];
  if (self != nil) {
    self->_listener = [[NSXPCListener alloc] initWithMachServiceName:kBrickLayerIdentifier];
    self->_listener.delegate = self;
  }
  return self;
}

- (void) run {
  [self.listener resume];            // Tell the XPC listener to start processing requests.
  [[NSRunLoop currentRunLoop] run];  // Run the run loop to infinity and beyond.
}

- (BOOL) listener:(NSXPCListener*)listener shouldAcceptNewConnection:(NSXPCConnection*)newConnection {
  #pragma unused(listener)
  NSAssert(listener == self.listener, @"NSXPCListener is not my instance variable", listener, self.listener);
  NSAssert(newConnection != nil, @"XPC connection is nil", newConnection);
  
  newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(BrickLayerProtocol)];
  newConnection.exportedObject = self;
  [newConnection resume];
  return YES;
}

#pragma mark BrickLayerProtocol implementation

- (void) connectWithEndpointReply:(void (^)(NSXPCListenerEndpoint*))reply {
  reply([self.listener endpoint]);
}

- (void) getVersionWithReply:(void(^)(NSString *version))reply {
  reply([[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]);
}

- (void) setRules:(NSString*)rules withReply:(void(^)(BOOL success))reply {
  if (![rules writeToFile:(NSString*)PFAnchorPath atomically:YES encoding:NSUTF8StringEncoding error:nil]) reply(NO);
  if (![self pfctlWithArguments:@[@"-a", PFAnchorName, @"-f", PFAnchorPath]]) reply(NO);
  reply(YES);
}

- (void) removeAllRulesWithReply:(void(^)(BOOL success))reply {
  BOOL success = [self pfctlWithArguments:@[@"-a", PFAnchorName, @"-F"]];
  [self deleteFile:(NSString*)PFAnchorPath];
  reply(success);
}

- (void) activateOnStartupWithReply:(void(^)(BOOL success))reply {
  BOOL success = [self createFile:(NSString*)launchDaemonPlistPath withContent:[self launchDaemonPlistContent]];
  reply(success);
}

- (void) deactivateOnStartupWithReply:(void(^)(BOOL success))reply {
  BOOL success = [self deleteFile:(NSString*)launchDaemonPlistPath];
  reply(success);
}

#pragma mark Internal Helpers

- (BOOL) pfctlWithArguments:(NSArray*)arguments {
  return [self runCommand:(NSString*)pfctlExecutable withArguments:arguments usingSudo:YES];
}

- (BOOL) launchctlWithArguments:(NSArray*)arguments {
  return [self runCommand:(NSString*)launchctlExecutable withArguments:arguments usingSudo:NO];
}

- (BOOL) runCommand:(NSString*)executable withArguments:(NSArray*)arguments usingSudo:(BOOL)sudo {
  if (sudo) {
    return [self runCommand:@"/usr/bin/sudo" withArguments:[@[executable] arrayByAddingObjectsFromArray:arguments]];
  } else {
    return [self runCommand:executable withArguments:arguments];
  }
}

- (BOOL) runCommand:(NSString*)executable withArguments:(NSArray*)arguments {
  NSTask *task = [NSTask new];
  [task setLaunchPath: executable];
  [task setArguments: arguments];
  [task launch];
  [task waitUntilExit];
  BOOL success = [task terminationReason] == NSTaskTerminationReasonExit;
  return (success);
}

- (BOOL) createFile:(NSString*)path withContent:(NSString*)content {
  return [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL) deleteFile:(NSString*)path {
  return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (NSString*) launchDaemonPlistContent {
  NSDictionary *plistDictionary = @{
    @"Disabled": @NO,
    @"Label": launchdLabel,
    @"Program": @"/sbin/pfctl",
    @"ProgramArguments": @[@"/sbin/pfctl", @"-a", PFAnchorName, @"-f", PFAnchorPath],
    @"RunAtLoad": @YES,
  };
  NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plistDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
  return [[NSString alloc] initWithData:plistData encoding:NSUTF8StringEncoding];
}

@end
