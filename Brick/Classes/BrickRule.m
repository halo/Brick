#import "BrickRule.h"

@implementation BrickRule

@synthesize identifier, name, comment, rules, activated;

- (NSString*) pf {
  NSMutableArray *rows = [NSMutableArray new];
  [rows addObject:[NSString stringWithFormat:@"# %@", self.comment]];
  [rows addObject:[self.rules componentsJoinedByString:@"\n"]];
  return [rows componentsJoinedByString:@"\n"];
}

@end
