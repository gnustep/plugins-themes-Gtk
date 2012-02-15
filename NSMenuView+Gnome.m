#include <AppKit/AppKit.h>
#include <AppKit/NSProgressIndicator.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

@implementation GGnomeTheme (NSMenuView)

- (void) drawMenuRect: (NSRect)rect
	       inView: (NSView *)view
	 isHorizontal: (BOOL)horizontal
	    itemCells: (NSArray *)itemCells
{
  int         i = 0;
  int         howMany = [itemCells count];
  NSMenuView *menuView = (NSMenuView *)view;
  NSRect      bounds = [view bounds];

  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkMenu"];

  NSImage *img = [painter paintBox: widget
                          withPart: "menu"
                           andSize: bounds
                          withClip: NSZeroRect
                        usingState: GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: widget->style];
  [painter drawAndReleaseImage: img inFrame: bounds flipped: NO];

  // Draw the menu cells.
  for (i = 0; i < howMany; i++)
    {
      NSRect aRect;
      NSMenuItemCell *aCell;

      aRect = [menuView rectOfItemAtIndex: i];
      aRect.size.width -= 1;
      if(!horizontal && i == howMany - 1)
	{
	  aRect.origin.y += 2;
	}

      if (NSIntersectsRect(rect, aRect) == YES)
        {
          aCell = [menuView menuItemCellForItemAtIndex: i];
          [aCell drawWithFrame: aRect inView: menuView];
        }
    }
}

@end

