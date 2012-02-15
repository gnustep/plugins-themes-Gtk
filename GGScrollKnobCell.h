#include <AppKit/AppKit.h>

@interface GGScrollKnobCell : NSButtonCell
{
  BOOL knob;
  BOOL horizontal;
}

- (BOOL) isKnob;
- (void) setKnob: (BOOL) value;

- (BOOL) isHorizontal;
- (void) setHorizontal: (BOOL) value;


+ (GGScrollKnobCell *) newWithKnob: (BOOL)is_knob horizontal: (BOOL) horizontal;
@end
