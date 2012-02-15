#include <AppKit/AppKit.h>
#include <AppKit/NSProgressIndicator.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

@implementation GGnomeTheme (GSBrowserTitleCell)
- (void) drawBrowserHeaderCell: (NSCell *)cell
		     withFrame: (NSRect)cellFrame
			inView: (NSView *)controlView
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
                        usingState: GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: widget->style];


  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: NO];
}
@end
