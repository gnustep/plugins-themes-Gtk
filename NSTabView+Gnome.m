#include <AppKit/AppKit.h>
#include <AppKit/NSTabView.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGPainter.h"
#include "GGnomeTheme.h"

@implementation GGnomeTheme (NSTabView)
// Drawing.
- (void) drawTabViewRect: (NSRect)rect
		  inView: (NSView *)view
	       withItems: (NSArray *)items
	    selectedItem: (NSTabViewItem *)selected
{
  NSGraphicsContext *ctxt = GSCurrentContext();
  int               howMany = [items count];
  int               i;
  int               previousState = 0;
  NSRect            bounds = [view bounds];
  NSRect            aRect = [view bounds];
  NSColor           *backgroundColour = [[view window] backgroundColor];
  BOOL              truncate = [(NSTabView *)view allowsTruncatedLabels];
  NSTabViewType     type = [(NSTabView *)view tabViewType];
  NSTabView *tabView = (NSTabView *)view;
  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkNotebook"];
  NSImage   *img = nil;
  // NSColor           *lineColour = [NSColor highlightColor];

  // Make sure some tab is selected
  if (!selected && howMany > 0)
    [tabView selectFirstTabViewItem: nil];

  DPSgsave(ctxt);

  switch (type)
    {
      default:
      case NSTopTabsBezelBorder: 
        aRect.size.height -= 16;
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
	// [self drawButton: aRect withClip: rect];
        break;

      case NSBottomTabsBezelBorder: 
        aRect.size.height -= 16;
        aRect.origin.y += 16;
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
        aRect.origin.y -= 16;
	// [self drawButton: aRect withClip: rect];
        break;

      case NSLeftTabsBezelBorder: 
        aRect.size.width -= 18;
        aRect.origin.x += 18;
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
	// [self drawButton: aRect withClip: rect];
        break;

      case NSRightTabsBezelBorder: 
        aRect.size.width -= 18;
	img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
	// [self drawButton: aRect withClip: rect];
        break;

      case NSNoTabsBezelBorder: 
        img = [painter paintBox: widget
                       withPart: "notebook"
                        andSize: aRect
                       withClip: rect
                     usingState: GTK_STATE_NORMAL
                         shadow: GTK_SHADOW_OUT
                          style: widget->style];

        [painter drawAndReleaseImage: img inFrame: aRect flipped: NO];
	// [self drawButton: aRect withClip: rect];
        break;

      case NSNoTabsLineBorder: 
        [[NSColor controlDarkShadowColor] set];
        NSFrameRect(aRect);
        break;

      case NSNoTabsNoBorder: 
        break;
    }

  NSPoint iP;
  GtkPositionType position;
  float labelYCorrection;
  if (type == NSBottomTabsBezelBorder)
    {
      iP.x = bounds.origin.x;
      iP.y = bounds.origin.y;
      position = GTK_POS_TOP; // sic!
      labelYCorrection = 1.0;
    }   
  else if (type == NSTopTabsBezelBorder)
    {
      iP.x = bounds.origin.x;
      iP.y = bounds.size.height - 16;
      position = GTK_POS_BOTTOM; // sic!
      labelYCorrection = -2.0;
    }

  if ((type != NSNoTabsBezelBorder) &&
      (type != NSNoTabsLineBorder) &&
      (type != NSNoTabsNoBorder))
    {
      for (i = 0; i < howMany; i++) 
	{
	  NSRect r;
	  NSRect fRect;
	  NSTabViewItem *anItem = [items objectAtIndex: i];
	  NSTabState itemState = [anItem tabState];
	  NSSize s = [anItem sizeOfLabel: truncate];
	  
	  r.origin.x = iP.x + 3; // move it over slightly to align better.
	  r.origin.y = iP.y;
	  r.size.width = s.width + 16;
	  r.size.height = 15;

	  fRect = r;
	  
	  if (itemState == NSSelectedTab)
	    {
	      // Undraw the line that separates the tab from its view.
	      if (type == NSBottomTabsBezelBorder)
		fRect.origin.y += 1;
	      else if (type == NSTopTabsBezelBorder)
		fRect.origin.y -= 1;
	      
	      fRect.size.height += 1;
	    }
	  [backgroundColour set];
	  NSRectFill(fRect);
	  
	  if (itemState == NSSelectedTab) 
	    {
	      img = [painter paintExtension: widget
                                   withPart: "tab"
                                    andSize: r
                                   withClip: NSZeroRect
                                 usingState: GTK_STATE_NORMAL
                                     shadow: GTK_SHADOW_OUT
                                   position: position
                                      style: widget->style];
	      iP.x += r.size.width;
	    }
	  else if (itemState == NSBackgroundTab)
	    {
	      img = [painter paintExtension: widget
                                   withPart: "tab"
                                    andSize: r
                                   withClip: NSZeroRect
                                 usingState: GTK_STATE_ACTIVE
                                     shadow: GTK_SHADOW_OUT
                                   position: position
                                      style: widget->style];
	      iP.x += r.size.width - 4;
	    } 
	  else
	    NSLog(@"Unhandled case.\n");
	  
	  if (itemState == NSSelectedTab && i == howMany -1)
	    r.size.width += 4;
	  
	  [painter drawAndReleaseImage: img inFrame: r flipped: NO];
          
	  // Label
	  [anItem drawLabel: truncate inRect: NSMakeRect(r.origin.x + (r.size.width - s.width)/2, r.origin.y + labelYCorrection, s.width, s.height)];
          
	  previousState = itemState;
	}
    }
  // FIXME: Missing drawing code for other cases

  DPSgrestore(ctxt);
}
@end
