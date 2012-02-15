#include <AppKit/AppKit.h>
#include <AppKit/NSScroller.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGPainter.h"
#include "GGnomeTheme.h"

@implementation GGnomeTheme (NSScroller)

/*
 *	draw the scroller
 */
- (void) drawScrollerRect: (NSRect)rect
		   inView: (NSView *)view
		  hitPart: (NSScrollerPart)hitPart
	     isHorizontal: (BOOL) isHorizontal
{
  NSScroller *scroller = (NSScroller *)view;
  NSRect rectForPartIncrementLine;
  NSRect rectForPartDecrementLine;
  NSRect rectForPartKnobSlot;
  NSRect bounds = [view bounds];

  rectForPartIncrementLine = [scroller rectForPart: NSScrollerIncrementLine];
  rectForPartDecrementLine = [scroller rectForPart: NSScrollerDecrementLine];
  rectForPartKnobSlot = [scroller rectForPart: NSScrollerKnobSlot];

  [[[view window] backgroundColor] set];
  NSRectFill (rect);

  ///////////////// BEGIN ADDITION
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: isHorizontal ? 
				 @"GtkHScrollbar" : @"GtkVScrollbar"];

  NSImage *img;
    img = [painter paintBox: widget
                   withPart: "trough"
                    andSize: bounds
                   withClip: NSZeroRect
                 usingState: GTK_STATE_NORMAL
                     shadow: GTK_SHADOW_OUT
                      style: widget->style];

   [painter drawAndReleaseImage: img inFrame: bounds flipped: YES];
  ///////////////// END ADDITION

  if (NSIntersectsRect (rect, rectForPartKnobSlot) == YES)
    {
      [scroller drawKnobSlot];
      [scroller drawKnob];
    }

  if (NSIntersectsRect (rect, rectForPartDecrementLine) == YES)
    {
      [scroller drawArrow: NSScrollerDecrementArrow 
            highlight: hitPart == NSScrollerDecrementLine];
    }
  if (NSIntersectsRect (rect, rectForPartIncrementLine) == YES)
    {
      [scroller drawArrow: NSScrollerIncrementArrow 
            highlight: hitPart == NSScrollerIncrementLine];
    }
}

@end
