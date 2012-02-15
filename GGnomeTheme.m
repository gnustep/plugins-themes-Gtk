#include "GGnomeTheme.h"
#include "GGPainter.h"
#include "GGScrollKnobCell.h"
#include "GGScrollStepperCell.h"
#include "GGnomeThemeInitialization.h"

#include <cairo/cairo.h>

static NSImage *_pbc_image[5];

@interface GGnomeTheme (Private)
- (void) drawStepperButton: (NSRect) aRect withArrowType: (GtkArrowType) arrow_type pressed: (BOOL) pressed;
@end

@implementation GGnomeTheme
- (id) initWithBundle: (NSBundle *)bundle
{
  if((self = [super initWithBundle: bundle]) != nil)
    {
      ASSIGN(_pbc_image[0], [NSImage imageNamed: @"common_Nibble"]);
      ASSIGN(_pbc_image[1], [NSImage imageNamed: @"common_3DArrowDown"]);
    }
  return self;
}

- (void) drawButton: (NSRect)frame
                 in: (NSCell*)cell
               view: (NSView*)view
              style: (int)style
              state: (GSThemeControlState)state
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *button = [GGPainter getWidget: @"GtkButton"];

  NSImage *img = [painter paintBox: button
                          withPart: "button"
                           andSize: frame
                          withClip: NSZeroRect
                        usingState: [painter gtkState: state forCell: cell]
                            shadow: GTK_SHADOW_OUT
                             style: button->style];

  [painter drawAndReleaseImage: img inFrame: frame flipped: YES];
}

- (void) drawFocusFrame: (NSRect) frame view: (NSView*) view
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *button = [GGPainter getWidget: @"GtkButton"];
  // NSRect vbounds = [view bounds];

  GTK_WIDGET_SET_FLAGS(button, GTK_HAS_DEFAULT);
  NSImage *img = [painter paintFocus: button
                            withPart: "button"
                             andSize: frame
                          usingState: GTK_STATE_NORMAL
                               style: button->style];

  [painter drawAndReleaseImage: img inFrame: frame flipped: YES];

  GTK_WIDGET_UNSET_FLAGS(button, GTK_HAS_DEFAULT);
}


- (NSRect) drawGrayBezel: (NSRect)border withClip: (NSRect)clip
{  
  /*
  GtkWidget *entry   = [GGPainter getWidget: @"GtkEntry"];
  GGPainter *painter = [GGPainter instance];
  NSImage *img = [painter paintShadow: entry
			     withPart: "entry"
			      andSize: border
			   usingState: GTK_STATE_NORMAL
			       shadow: GTK_SHADOW_IN
				style: entry->style];
  
  [painter drawAndReleaseImage: img inFrame: border flipped: YES];
  return border;
  */
  return [self drawDarkBezel: border withClip: clip];
}

- (NSRect) drawProgressIndicatorBezel: (NSRect)bounds withClip: (NSRect) rect
{
  return [self drawDarkBezel: bounds withClip: rect];
}

- (void) drawProgressIndicatorBarDeterminate: (NSRect)bounds;
{
  GGPainter *painter =  [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkProgressBar"];

  NSImage *img = [[GGPainter instance] paintBox: widget
                                       withPart: "bar"
                                        andSize: bounds
                                       withClip: NSZeroRect
                                     usingState: GTK_STATE_PRELIGHT
                                         shadow: GTK_SHADOW_OUT
                                          style: widget->style];

  [painter drawAndReleaseImage: img inFrame: bounds flipped: YES];
}



/** Draw a dark bezel border */
- (NSRect) drawDarkBezel: (NSRect)border withClip: (NSRect)clip isFlipped: (BOOL)flag
{
  NSRect r = border;
  GGPainter *painter =  [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkFrame"];

  NSImage *img = [painter paintShadow: widget
                             withPart: "frame"
                              andSize: r
                           usingState: GTK_STATE_NORMAL
                               shadow: GTK_SHADOW_IN
                                style: widget->style];
  // [painter drawAndReleaseImage: img inFrame: r withClip: clip];
  [painter drawAndReleaseImage: img inFrame: r flipped: flag];
  return r;
}

- (NSRect) drawDarkBezel: (NSRect)border withClip: (NSRect)clip
{
  return [self drawDarkBezel: border 
		    withClip: clip
		   isFlipped: YES];
}

- (NSRect) drawGroove: (NSRect)border withClip: (NSRect)clip
{
  NSRect r = border;
  GGPainter *painter =  [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkFrame"];

  NSImage *img = [painter paintShadow: widget
                             withPart: "frame"
                              andSize: r
                           usingState: GTK_STATE_NORMAL
                               shadow: GTK_SHADOW_ETCHED_IN
                                style: widget->style];

  [painter drawAndReleaseImage: img inFrame: r withClip: clip];
  // [painter drawAndReleaseImage: img inFrame: r flipped: YES];
  return r;
}

- (void) drawBorderType: (NSBorderType)aType
                  frame: (NSRect)frame
                   view: (NSView*)view
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *entry   = [GGPainter getWidget: @"GtkEntry"];
  NSImage   *img     = nil;

  switch (aType)
    {
    case NSLineBorder:
      [[NSColor controlDarkShadowColor] set];
      NSFrameRect(frame);
      break;
    case NSGrooveBorder:
      [self drawGroove: frame withClip: NSZeroRect];
      break;
    case NSBezelBorder:
      img = [painter paintShadow: entry
                        withPart: "entry"
                         andSize: frame
                      usingState: GTK_STATE_NORMAL
                          shadow: GTK_SHADOW_IN
                           style: entry->style];

      [painter drawAndReleaseImage: img inFrame: frame flipped: YES];
    case NSNoBorder:
    default:
      break;
    }
}

- (float) defaultScrollerWidth
{
  GtkWidget *widget = [GGPainter getWidget: @"GtkHScrollbar"];
  gint slider_width = 16;
  gtk_widget_style_get (GTK_WIDGET (widget), "slider-width", &slider_width, NULL);
  return (float)slider_width;
}

- (NSCell*) cellForScrollerKnob: (BOOL)horizontal
{
  GGScrollKnobCell *cell;
  cell = [GGScrollKnobCell newWithKnob: YES horizontal: horizontal];
  if (cell != nil)
    {
      [cell setButtonType: NSMomentaryChangeButton];
      if (horizontal)
	{
	  [self setName: GSScrollerHorizontalKnob 
		forElement: cell 
		temporary: YES];
	}
      else
	{
	  [self setName: GSScrollerVerticalKnob 
		forElement: cell 
		temporary: YES];
	}
      RELEASE(cell);
    }
  return cell;
}

- (NSCell*) cellForScrollerKnobSlot: (BOOL)horizontal
{
  GGScrollKnobCell *cell;

  cell = [GGScrollKnobCell newWithKnob: NO horizontal: horizontal];

  if (horizontal)
      [self setName: GSScrollerHorizontalSlot forElement: cell temporary: YES];
  else
      [self setName: GSScrollerVerticalSlot forElement: cell temporary: YES];

  RELEASE(cell);
  return cell;
}

- (NSButtonCell*) cellForScrollerArrow: (NSScrollerArrow)arrow
			    horizontal: (BOOL)horizontal
{
  GGScrollStepperCell *cell;
  NSString *name;

  cell = [[GGScrollStepperCell alloc] init];
  [cell setHorizontal: horizontal];
  if (horizontal)
    {
      if (arrow == NSScrollerDecrementArrow)
	{
	  [cell setHighlightsBy:
	    NSChangeBackgroundCellMask | NSContentsCellMask];
	  [cell setImage: [NSImage imageNamed: @"common_ArrowLeft"]];
	  [cell setAlternateImage: [NSImage imageNamed: @"common_ArrowLeftH"]];
	  [cell setImagePosition: NSImageOnly];
          name = GSScrollerLeftArrow;
	}
      else
	{
	  [cell setHighlightsBy:
	    NSChangeBackgroundCellMask | NSContentsCellMask];
	  [cell setImage: [NSImage imageNamed: @"common_ArrowRight"]];
	  [cell setAlternateImage: [NSImage imageNamed: @"common_ArrowRightH"]];
	  [cell setImagePosition: NSImageOnly];
          name = GSScrollerRightArrow;
	}
    }
  else
    {
      if (arrow == NSScrollerDecrementArrow)
	{
	  [cell setHighlightsBy:
	    NSChangeBackgroundCellMask | NSContentsCellMask];
	  [cell setImage: [NSImage imageNamed: @"common_ArrowUp"]];
	  [cell setAlternateImage: [NSImage imageNamed: @"common_ArrowUpH"]];
	  [cell setImagePosition: NSImageOnly];
          name = GSScrollerUpArrow;
	}
      else
	{
	  [cell setHighlightsBy:
	    NSChangeBackgroundCellMask | NSContentsCellMask];
	  [cell setImage: [NSImage imageNamed: @"common_ArrowDown"]];
	  [cell setAlternateImage: [NSImage imageNamed: @"common_ArrowDownH"]];
	  [cell setImagePosition: NSImageOnly];
          name = GSScrollerDownArrow;
	}
    }
  [self setName: name forElement: cell temporary: YES];
  RELEASE(cell);
  return cell;
}


- (void) drawStepperCell: (NSCell*)cell
               withFrame: (NSRect)cellFrame
                  inView: (NSView*)controlView
             highlightUp: (BOOL)highlightUp
           highlightDown: (BOOL)highlightDown
{
  NSRect upRect;
  NSRect downRect;
  NSRect twoButtons;

  upRect = [self stepperUpButtonRectWithFrame: cellFrame];
  downRect = [self stepperDownButtonRectWithFrame: cellFrame];

  twoButtons = downRect;
  twoButtons.origin.y--;
  twoButtons.size.width++;
  twoButtons.size.height = 2 * upRect.size.height + 1;

  {
    GGPainter *painter = [GGPainter instance];

    GtkWidget *widget = [GGPainter getWidget: @"GtkSpinButton"];

    GtkStateType state = GTK_STATE_NORMAL;

    if (![cell isEnabled]) {
      state = GTK_STATE_INSENSITIVE;
    }

    GtkShadowType rc_shadow_type;
    gtk_widget_style_get (GTK_WIDGET (widget), "shadow-type", &rc_shadow_type, NULL);

    NSImage *img = [painter paintBox: widget
                            withPart: "spinbutton"
                             andSize: twoButtons
                            withClip: NSZeroRect
                          usingState: state
                              shadow: rc_shadow_type
                               style: widget->style];

    [painter drawAndReleaseImage: img inFrame: cellFrame flipped: NO];
  }

  if (highlightUp)
    [self drawStepperHighlightUpButton: upRect];
  else
    [self drawStepperUpButton: upRect];

  if (highlightDown)
    [self drawStepperHighlightDownButton: downRect];
  else
    [self drawStepperDownButton: downRect];

}

- (void) drawStepperUpButton: (NSRect) aRect
{
  [self drawStepperButton: aRect withArrowType: GTK_ARROW_UP pressed: NO];
}

- (void) drawStepperDownButton: (NSRect) aRect
{
  [self drawStepperButton: aRect withArrowType: GTK_ARROW_DOWN pressed: NO];
}

- (void) drawStepperHighlightUpButton: (NSRect) aRect
{
  [self drawStepperButton: aRect withArrowType: GTK_ARROW_UP pressed: YES];
}

- (void) drawStepperHighlightDownButton: (NSRect) aRect
{
  [self drawStepperButton: aRect withArrowType: GTK_ARROW_DOWN pressed: YES];
}


- (void) drawBorderAndBackgroundForMenuItemCell: (NSMenuItemCell *)cell
                                      withFrame: (NSRect)cellFrame
                                         inView: (NSView *)controlView
                                          state: (GSThemeControlState)state
                                   isHorizontal: (BOOL)isHorizontal
{
  GGPainter *painter = [GGPainter instance];

  if (isHorizontal)
    {
      NSRect newFrame = cellFrame;
      newFrame.size.height -= 2;
      cellFrame = [cell drawingRectForBounds: cellFrame];
      // [[cell backgroundColor] set];
      // NSRectFill(cellFrame);
      // return;
    }

  // Set cell's background color
  [[cell backgroundColor] set];
  NSRectFill(cellFrame);

  if (state == GSThemeHighlightedState)
    {
      // cellFrame.size.height -= 2;
      GtkWidget *widget = [GGPainter getWidget: @"GtkMenu.GtkMenuItem"];

      GtkShadowType selected_shadow_type;
      gtk_widget_style_get (widget,
                            "selected-shadow-type", &selected_shadow_type,
                            NULL);

      NSImage *img = [painter paintBox: widget
                              withPart: "menuitem"
                               andSize: cellFrame
                              withClip: NSZeroRect
                            usingState: GTK_STATE_PRELIGHT
                                shadow: selected_shadow_type
                                 style: widget->style];

      [painter drawAndReleaseImage: img inFrame: cellFrame flipped: NO];
    }
}

- (NSImage *) arrowImageForMenuItemCell
{
  NSImage *arrow = [NSImage imageNamed: @"NSMenuArrow"];
  return [[GGPainter instance] drawMenuItemArrow: [arrow size]];
}

- (NSColor *) backgroundColorForMenuItemCell: (NSMenuItemCell *)cell
                                       state: (GSThemeControlState)state
{
  GtkStyle *style = [GGPainter getWidget: @"GtkMenu.GtkMenuItem"]->style;
  return [GGPainter fromGdkColor: style->bg[GTK_STATE_NORMAL]];
}


- (void) activate
{
  init_gtk_window();
  init_gtk_widgets();
  setup_icons();
  setup_fonts();

  NSLog (@"Gnome theme initialized");
  [super activate];
}

- (NSColorList *) colors
{
  return setup_palette();
}

- (BOOL) menuShouldShowIcon
{
  return NO;
}
@end

@implementation GGnomeTheme (Private)

- (void) drawStepperButton: (NSRect) aRect withArrowType: (GtkArrowType) arrow_type pressed: (BOOL) pressed
{
  GGPainter *painter =  [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkSpinButton"];

  GtkStateType state_type;
  GtkShadowType shadow_type;

  if (pressed)
    {
      state_type = GTK_STATE_ACTIVE;
      shadow_type = GTK_SHADOW_IN;
    }
  else
    {
      state_type = GTK_STATE_NORMAL;
      shadow_type = GTK_SHADOW_OUT;
    }


  NSRect r = aRect;
  NSImage *img = [painter paintBox: widget
                          withPart: (arrow_type == GTK_ARROW_UP)? "spinbutton_up" : "spinbutton_down"
                           andSize: r
                          withClip: NSZeroRect
                        usingState: state_type
                            shadow: shadow_type
                             style: widget->style];

  [painter drawAndReleaseImage: img inFrame: r flipped: NO];

  r = NSInsetRect(aRect, 3.5, 3.5);

  img = [painter paintArrow: widget
                   withPart: "spinbutton"
                    andSize: r
                 usingState: state_type
                     shadow: shadow_type
                      style: widget->style
                  arrowType: arrow_type
                       fill: YES];

  [painter drawAndReleaseImage: img inFrame: r flipped: NO];
}

- (NSRect) drawColorWellBorder: (NSColorWell*)well
                    withBounds: (NSRect)bounds
                      withClip: (NSRect)clipRect
{
  NSRect aRect = bounds;
  NSRect wellRect;

  if (NSIntersectsRect(aRect, clipRect) == NO)
    {
      return aRect;
    }

  if ([well isBordered])
    {
      /*
       * Draw border.
       */
      GGPainter *painter = [GGPainter instance];

      GtkWidget *button = [GGPainter getWidget: @"GtkButton"];

      GtkStateType state = GTK_STATE_NORMAL;

      if (![well isEnabled]) {
        state = GTK_STATE_INSENSITIVE;
      }

      NSImage *img = [painter paintBox: button
                              withPart: "button"
                               andSize: bounds
                              withClip: NSZeroRect
                            usingState: state
                                shadow: GTK_SHADOW_OUT
                                 style: button->style];

      [painter drawAndReleaseImage: img inFrame: bounds flipped: NO];

      aRect = NSInsetRect(aRect, 2.0, 2.0);

      /*
       * Set an inset rect for the color area
       */
      wellRect = NSInsetRect(bounds, 8.0, 8.0);
    }
  else
    {
      wellRect = bounds;
    }

  aRect = wellRect;

  /*
   * OpenStep 4.2 behavior is to omit the inner border for
   * non-enabled NSColorWell objects.
   */
  if ([well isEnabled])
    {
      /*
       * Draw inner frame.
       */
      [[GSTheme theme] drawGroove: aRect withClip: clipRect];
      aRect = NSInsetRect(aRect, 1.0, 1.0);
    }

  return aRect;
}

@end
