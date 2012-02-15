#include <AppKit/AppKit.h>
#include <AppKit/NSProgressIndicator.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

// NOTE: Get the alternate images working later.
static NSImage *_pbc_image[5];

@interface NSPopUpButtonCell (GnomeTheme)
- (NSImage *) _currentArrowImage;
@end

@implementation GGnomeTheme (NSPopUpButtonCell)

- (NSImage *) _currentArrowImageForTheme: (NSPopUpButtonCell *)cell
{
  if ([cell pullsDown])
    {
      if ([cell arrowPosition] == NSPopUpNoArrow)
        {
          return nil;
        }

      if ([cell preferredEdge] == NSMinYEdge)
        {
          return _pbc_image[1];
        }
      else if ([cell preferredEdge] == NSMaxXEdge)
        {
          return _pbc_image[2];
        }
      else if ([cell preferredEdge] == NSMaxYEdge)
        {
          return _pbc_image[3];
        }
      else if ([cell preferredEdge] == NSMinXEdge)
        {
          return _pbc_image[4];
        }
      else
        {
          return _pbc_image[1];
        }
    }
  else
    {
      return _pbc_image[0];
    }
}

/*
 * This drawing uses the same code that is used to draw cells in the menu.
 */
- (void) drawPopUpButtonCellInteriorWithFrame: (NSRect)cellFrame
				     withCell: (NSCell *)cell
				       inView: (NSView *)controlView
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *button = [GGPainter getWidget: @"GtkComboBox.GtkToggleButton"];

  NSImage *img = [painter paintBox: button
                          withPart: "button"
                           andSize: cellFrame
                          withClip: NSZeroRect
                        usingState: GTK_STATE_NORMAL
                            shadow: GTK_SHADOW_OUT
                             style: button->style];

  [painter drawAndReleaseImage: img inFrame: cellFrame flipped: YES];

  GtkWidget *widget = [GGPainter getWidget: @"GtkComboBox.GtkToggleButton.GtkHBox.GtkVSeparator"];

  img = [painter paintVLine: widget
                   withPart: "vseparator"
                    andSize: cellFrame
                 usingState: GTK_STATE_NORMAL
                      style: widget->style];

  NSSize arrowSize = [[(NSPopUpButtonCell *)cell _currentArrowImage] size]; //ForTheme: (NSPopUpButtonCell *)cell] size];

  [img drawInRect: NSMakeRect(cellFrame.size.width - 2*arrowSize.width - 2*widget->style->xthickness, cellFrame.size.height - widget->style->ythickness, 3, cellFrame.size.height - 2*widget->style->ythickness)
         fromRect: NSMakeRect(0, 0, 3, cellFrame.size.height)
        operation: NSCompositeSourceOver
         fraction: 1.0];

  RELEASE(img);
}
@end
