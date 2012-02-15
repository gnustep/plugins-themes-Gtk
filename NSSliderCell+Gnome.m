#include <AppKit/AppKit.h>
#include <AppKit/NSProgressIndicator.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"


@implementation GGnomeTheme (NSSliderCell) 
 - (void) drawBarInside: (NSRect)rect 
		 inCell: (NSCell *)cell
		flipped: (BOOL)flipped
 {

  [[NSColor windowBackgroundColor] drawSwatchInRect: rect];

   BOOL horizontal = (rect.size.width > rect.size.height);

   GGPainter *painter = [GGPainter instance];
   GtkWidget *widget = [GGPainter getWidget: horizontal ? @"GtkHScale" : @"GtkVScale"];

   NSImage *img = [painter paintBox: widget
                           withPart: "trough"
                            andSize: rect
                           withClip: NSZeroRect
                         usingState: [cell isEnabled] ? GTK_STATE_NORMAL : GTK_STATE_INSENSITIVE
                             shadow: GTK_SHADOW_IN
                              style: widget->style];

   [painter drawAndReleaseImage: img inFrame: rect flipped: YES];
}

- (void) drawKnobInCell: (NSCell *)cell
{
  NSSliderCell *sliderCell = (NSSliderCell *)cell;
  NSView *controlView = [cell controlView];

  [sliderCell setBordered: NO];
  [sliderCell setBezeled: NO];

  NSRect knobRect = [sliderCell knobRectFlipped: [controlView isFlipped]];
  
  BOOL horizontal = (knobRect.size.width > knobRect.size.height);
  
  if (horizontal)
    knobRect.origin.y += 1;
  else
    knobRect.origin.x += 1;
  
  [sliderCell drawKnob: knobRect];
}
@end
