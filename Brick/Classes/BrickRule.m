#import "BrickRule.h"

@implementation BrickRule

@synthesize identifier, name, comment, rules, activated;

- (NSString*) pf {
  NSMutableArray *rows = [NSMutableArray new];
  //[Log debug:@"Exporting comment %@", self.comment];
  [rows addObject:[NSString stringWithFormat:@"# %@", self.identifier]];
  [rows addObject:[NSString stringWithFormat:@"# %@", self.comment]];
  //[Log debug:@"Exporting rules %@", self.rules];
  [rows addObject:[self.rules componentsJoinedByString:@"\n"]];
  return [rows componentsJoinedByString:@"\n"];
}

- (NSString*) comment {
  if (comment) return comment;
  return @"[Missing Comment]";
}

- (NSArray*) rules {
  if (rules) return rules;
  return @[@"# [Missing Rules]"];
}

@end
