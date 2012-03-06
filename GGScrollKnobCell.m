#include "GGScrollKnobCell.h"
#include "GGPainter.h"

@implementation GGScrollKnobCell
- (BOOL) isKnob
{
  return knob;
}

- (void) setKnob: (BOOL) value
{
  knob = value;
}

- (BOOL) isHorizontal
{
  return horizontal;
}

- (void) setHorizontal: (BOOL) value
{
  horizontal = value;
}


+ (GGScrollKnobCell *) newWithKnob: (BOOL)is_knob horizontal: (BOOL) is_horizontal
{
  GGScrollKnobCell *cell = [[GGScrollKnobCell alloc] initTextCell: @""];
  [cell setKnob: is_knob];
  [cell setHorizontal: is_horizontal];
  return cell;
}


// Private helper method overridden in subclasses
- (void) _drawBorderAndBackgroundWithFrame: (NSRect)cellFrame
                                    inView: (NSView*)controlView
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: horizontal ? @"GtkHScrollbar" : @"GtkVScrollbar"];

  if (widget == nil)
    {
      [super _drawBorderAndBackgroundWithFrame: cellFrame
					inView: controlView];
      return;
    }

  NSImage *img;

  if ([self isKnob]) {
    img = [painter paintSlider: widget
                      withPart: "slider"
                       andSize: cellFrame
                    usingState: GTK_STATE_NORMAL
                        shadow: GTK_SHADOW_OUT
                         style: widget->style
                   orientation: horizontal ? GTK_ORIENTATION_HORIZONTAL : GTK_ORIENTATION_VERTICAL];

   [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];
  } else {
    img = [painter paintBox: widget
                   withPart: "trough"
                    andSize: cellFrame
                   withClip: NSZeroRect
                 usingState: GTK_STATE_NORMAL
                     shadow: GTK_SHADOW_OUT
                      style: widget->style];

   [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];
  }
}

@end
