#import "BrickLogger.h"

#import "BrickPreferences.h"

@implementation BrickLogger

+ (void) debug:(NSString*)string, ... {
  if (![BrickPreferences debugMode]) return;
  va_list arguments;
  
  NSAssert(string != nil, @"Log message is nil"); // any thread
  
  va_start(arguments, string);
  NSString *message = [[NSString alloc] initWithFormat:string arguments:arguments];
  NSLog(@"%@", message);
  va_end(arguments);
}

@end
