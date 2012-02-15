#include "GGScrollStepperCell.h"
#include "GGPainter.h"

@implementation GGScrollStepperCell
- (BOOL) isHorizontal
{
  return horizontal;
}

- (void) setHorizontal: (BOOL) value
{
  horizontal = value;
}

- (GGScrollStepperCell *) newWithKnob: (BOOL)is_knob horizontal: (BOOL) is_horizontal
{
  GGScrollStepperCell *cell = [[GGScrollStepperCell alloc] initTextCell: @""];
  [cell setHorizontal: is_horizontal];
  return cell;
}


// Private helper method overridden in subclasses
- (void) _drawBorderAndBackgroundWithFrame: (NSRect)cellFrame
                                    inView: (NSView*)controlView
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: horizontal ? @"GtkHScrollbar" : @"GtkVScrollbar"];
  NSImage *img;
  // GtkRange *range = GTK_RANGE(widget);

  img = [painter paintBox: widget
		 withPart: horizontal ? "hscrollbar" : "vscrollbar"
		 andSize: cellFrame
		 withClip: NSZeroRect
                 usingState: _cell.is_highlighted ? GTK_STATE_ACTIVE : GTK_STATE_NORMAL
		 shadow: _cell.is_highlighted ? GTK_SHADOW_IN : GTK_SHADOW_OUT
		 style: widget->style];


  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];
}
@end
