#import "BrickRules.h"

#import "BrickRule.h"

const NSString *FactoryIdentifiersFlag = @"rules.factory";
const NSString *UserIdentifiersFlag = @"rules.user";
const NSString *RulePrefix = @"rule";
const NSString *RuleActivatedSuffix = @"activated";
const NSString *RuleNameSuffix = @"name";
const NSString *RuleCommentSuffix = @"comment";
const NSString *RuleRulesSuffix = @"rules";

// Duplicated in BrickLayer
const NSString *PFAnchorPath = @"/etc/pf.anchors/com.funkensturm.Brick";

@implementation BrickRules

# pragma mark Public Getters

+ (NSArray*) all {
  NSMutableArray *result = [NSMutableArray new];
  for (NSString *identifier in [self identifiers]) {
    [result addObject:[self findByIdentifier:identifier]];
  }
  return (NSArray*)result;
}

+ (NSString*) pf {
  NSMutableArray *result = [NSMutableArray new];
  // By default we block everything
  [result addObject:[[self blockOutgoingRule] pf]];
  // Then our custom rules
  for (BrickRule *rule in [self all]) {
    if (!rule.activated) continue;
    [result addObject:rule.pf];
  }
  // Lastly, we need to make sure the rules end with a newline to make pf not complain about syntax errors
  [result addObject:@""];
  return [result componentsJoinedByString:@"\n\n"];
}

+ (BOOL) activated {
  return [[NSFileManager defaultManager] fileExistsAtPath:[self anchorFilePath]];
}

+ (NSString*) anchorFilePath {
  return (NSString*)PFAnchorPath;
}

# pragma mark Public Setters

+ (void) toggleRuleWithIdentifier:(NSString*)identifier {
  [Log debug:@"Toggling rule <%@> activation...", identifier];
  BrickRule *rule = [self findByIdentifier:identifier];
  if (rule.activated) {
    [self deactivateRuleWithIdentifier:rule.identifier];
  } else {
    [self activateRuleWithIdentifier:rule.identifier];
  }
}

# pragma mark Internal Getters

+ (BrickRule*) findByIdentifier:(NSString*)identifier {
  [Log debug:@"Loading rule <%@>", identifier];
  BrickRule *rule = [BrickRule new];
  rule.identifier = identifier;
  rule.name = [[self backend] stringForKey:[self nameKey:identifier]];
  rule.activated = [[self backend] boolForKey:[self activatedKey:identifier]];
  rule.comment = [[self backend] stringForKey:[self commentKey:identifier]];
  rule.rules = [[self backend] arrayForKey:[self rulesKey:identifier]];
  return rule;
}

+ (BrickRule*) blockOutgoingRule {
  return [self findByIdentifier:@"blockout"];
}

+ (NSArray*) identifiers {
  NSMutableArray *result = [NSMutableArray new];
  [result addObjectsFromArray:[[self backend] arrayForKey:(NSString*)FactoryIdentifiersFlag]];
  [result addObjectsFromArray:[[self backend] arrayForKey:(NSString*)UserIdentifiersFlag]];
  return (NSArray*)result;
}

+ (NSString*) activatedKey:(NSString*)identifier {
  return  [NSString stringWithFormat:@"%@.%@.%@", RulePrefix, identifier, RuleActivatedSuffix];
}

+ (NSString*) nameKey:(NSString*)identifier {
  return  [NSString stringWithFormat:@"%@.%@.%@", RulePrefix, identifier, RuleNameSuffix];
}

+ (NSString*) commentKey:(NSString*)identifier {
  return  [NSString stringWithFormat:@"%@.%@.%@", RulePrefix, identifier, RuleCommentSuffix];
}

+ (NSString*) rulesKey:(NSString*)identifier {
  return  [NSString stringWithFormat:@"%@.%@.%@", RulePrefix, identifier, RuleRulesSuffix];
}

+ (NSUserDefaults*) backend {
  return [NSUserDefaults standardUserDefaults];
}

# pragma mark Internal Setters

+ (void) activateRuleWithIdentifier:(NSString*)identifier {
  [Log debug:@"Activating rule <%@>...", identifier];
  [[self backend] setBool:YES forKey:[self activatedKey:identifier]];
}

+ (void) deactivateRuleWithIdentifier:(NSString*)identifier {
  [Log debug:@"Deactivating rule <%@>...", identifier];
  [[self backend] setBool:NO forKey:[self activatedKey:identifier]];
}

@end
