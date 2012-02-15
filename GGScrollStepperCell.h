#include <AppKit/AppKit.h>

@interface GGScrollStepperCell : NSButtonCell
{
  BOOL horizontal;
}

- (BOOL) isHorizontal;
- (void) setHorizontal: (BOOL) value;

@end

