#import "BrickLayer.h"

int main(int argc, char **argv) {
  NSLog(@"Booting BrickLayer");

  @autoreleasepool {
    BrickLayer *brickLayer = [BrickLayer new];
    [brickLayer run];
  }
  
  // We should never get here
  return EXIT_FAILURE;
}
