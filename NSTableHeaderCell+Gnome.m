#include <AppKit/AppKit.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

@implementation GGnomeTheme (NSTableHeaderCell)
- (NSRect) tableHeaderCellDrawingRectForBounds: (NSRect)theRect
{
  return theRect;
}

- (void) drawTableHeaderCell: (NSTableHeaderCell *)cell
                   withFrame: (NSRect)cellFrame
                      inView: (NSView *)controlView
                       state: (GSThemeControlState)aState
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView.GtkButton"];

  GtkStateType state = GTK_STATE_NORMAL;

  if (![cell isEnabled]) {
    state = GTK_STATE_INSENSITIVE;
  }

  NSImage *img = [painter paintBox: widget
                          withPart: "button"
                           andSize: cellFrame
                          withClip: NSZeroRect
			usingState: (aState == GSThemeHighlightedState) ? 
			  GTK_STATE_ACTIVE : GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: widget->style];

  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];
}

- (void) drawTableCornerView: (NSView *)view withClip: (NSRect)aRect
{
  NSRect cellFrame = aRect;

  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView.GtkButton"];

  // GtkStateType state = GTK_STATE_NORMAL;

  NSImage *img = [painter paintBox: widget
                          withPart: "button"
                           andSize: cellFrame
                          withClip: NSZeroRect
                        usingState: GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: widget->style];

  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];
}
@end
