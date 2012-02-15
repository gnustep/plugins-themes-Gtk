#include <AppKit/AppKit.h>
#include <AppKit/NSBrowser.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGnomeTheme.h"

@implementation GGnomeTheme (NSBrowser)

- (void) drawBrowserRect: (NSRect)rect
		  inView: (NSView *)view
	withScrollerRect: (NSRect)scrollerRect
	      columnSize: (NSSize)columnSize
{
  float scrollerWidth = [NSScroller scrollerWidth];
  NSBrowser *browser = (NSBrowser *)view;
  NSRect bounds = [view bounds];

  // Load the first column if not already done
  if (![browser isLoaded])
    {
      [browser loadColumnZero];
    }

  // Draws titles
  if ([browser isTitled])
    {
      int i;

      for (i = [browser firstVisibleColumn]; 
	   i <= [browser lastVisibleColumn]; 
	   ++i)
        {
          NSRect titleRect = [browser titleFrameOfColumn: i];
          if (NSIntersectsRect (titleRect, rect) == YES)
            {
              [browser drawTitleOfColumn: i
                    inRect: titleRect];
            }
        }
    }

  // Draws scroller border
  // deleted

  if (![browser separatesColumns])
    {
      NSPoint p1,p2;
      int     i, visibleColumns;
      float   hScrollerWidth = [browser hasHorizontalScroller] ? 
	scrollerWidth : 0;
      
      // Columns borders
      [self drawGrayBezel: bounds withClip: rect];
      
      [[NSColor blackColor] set];
      visibleColumns = [browser numberOfVisibleColumns]; 
      for (i = 1; i < visibleColumns; i++)
        {
          p1 = NSMakePoint((columnSize.width * i) + 2 + (i-1), 
                           columnSize.height + hScrollerWidth + 2);
          p2 = NSMakePoint((columnSize.width * i) + 2 + (i-1),
                           hScrollerWidth + 2);
          [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];
        }

      // Horizontal scroller border
      if ([browser hasHorizontalScroller])
        {
          p1 = NSMakePoint(2, hScrollerWidth + 2);
          p2 = NSMakePoint(rect.size.width - 2, hScrollerWidth + 2);
          [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];
        }
    }
  [(GGnomeTheme *)[GSTheme theme] drawDarkBezel: bounds withClip: rect isFlipped: NO];
}

@end
