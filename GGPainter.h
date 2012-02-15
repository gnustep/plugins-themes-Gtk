#ifndef GGPAINTER_H
#define GGPAINTER_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <GNUstepGUI/GSTheme.h>
#include <gtk/gtk.h>

@interface GGPainter : NSObject
{
@private
  GtkWidget *m_window;
  BOOL m_alpha;
}

+ (GGPainter *) instance;

+ (NSMutableDictionary *) widgetMap;
+ (GtkWidget *) getWidget: (NSString *) widgetName;
+ (void) setWidget: (GtkWidget *) widget forKey: (NSString *) key;

+ (NSColor *) fromGdkColor: (GdkColor) gdk_color;
- (NSImage *) fromPixbuf: (GdkPixbuf *) pixbuf;
- (NSImage *) stockIcon: (const gchar *) iconName;
- (NSImage *) stockIcon: (const gchar *) iconName withSize: (GtkIconSize) size;
- (NSImage *) namedIcon: (const gchar *) iconName withSize: (gint) size;

- (void) drawAndReleaseImage: (NSImage *) image inFrame: (NSRect) cellFrame flipped: (BOOL) flipped;
- (void) drawAndReleaseImage: (NSImage *) image inFrame: (NSRect) cellFrame withClip: (NSRect) clip;

- (id) init;

- (GtkStyle *) getWidgetStyle: (GtkWidget *) gtkWidget;
- (GtkStyle *) gtkStyle;
- (GtkStateType) gtkState: (GSThemeControlState) gs_state forCell: (NSCell *) cell;

- (NSString *) uniqueNameForPart: (NSString *) part
			  state: (GtkStateType) state
			 shadow: (GtkShadowType) shadow
			   size: (NSRect) size
			 widget: (GtkWidget *) widget;


- (NSImage *) paintBox: (GtkWidget *) gtkWidget
              withPart: (const gchar *) part
               andSize: (const NSRect) rect
              withClip: (const NSRect) clip
            usingState: (GtkStateType) state
                shadow: (GtkShadowType) shadow
                 style: (GtkStyle *) style;

- (NSImage *) paintFlatBox: (GtkWidget *) gtkWidget
                  withPart: (const gchar *) part
                   andSize: (const NSRect) size
                  withClip: (const NSRect) clip
                usingState: (GtkStateType) state
                    shadow: (GtkShadowType) shadow
                     style: (GtkStyle *) style;

- (NSImage *) paintExtension: (GtkWidget *) gtkWidget
                    withPart: (const gchar *) part
                     andSize: (const NSRect) size
                    withClip: (const NSRect) clip
                  usingState: (GtkStateType) state
                      shadow: (GtkShadowType) shadow
                    position: (GtkPositionType) position
                       style: (GtkStyle *) style;

- (NSImage *) paintShadow: (GtkWidget *) gtkWidget
               withPart: (const gchar *) part
                andSize: (const NSRect) size
             usingState: (GtkStateType) state
                 shadow: (GtkShadowType) shadow
                  style: (GtkStyle *) style;

- (NSImage *) paintHLine: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                   style: (GtkStyle *) style;


- (NSImage *) paintVLine: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                   style: (GtkStyle *) style;

- (NSImage *) paintFocus: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                   style: (GtkStyle *) style;

- (NSImage *) paintOption: (GtkWidget *) gtkWidget
                 withPart: (const gchar *) part
                  andSize: (const NSRect) size
               usingState: (GtkStateType) state
                   shadow: (GtkShadowType) shadow
                    style: (GtkStyle *) style;

- (NSImage *) drawRadioButton: (NSSize)size
                        state: (GtkStateType)state
                       shadow: (GtkShadowType) shadow;

- (NSImage *) drawCheckButton: (NSSize)size
                        state: (GtkStateType)state
                       shadow: (GtkShadowType) shadow;

- (NSImage *) paintSlider: (GtkWidget *) gtkWidget
                 withPart: (const gchar *) part
                  andSize: (const NSRect) size
               usingState: (GtkStateType) state
                   shadow: (GtkShadowType) shadow
                    style: (GtkStyle *) style
              orientation: (GtkOrientation) orientation;

- (NSImage *) drawVerticalSlider: (NSSize)size
                           state: (GtkStateType)state
                          shadow: (GtkShadowType) shadow;

- (NSImage *) drawHorizontalSlider: (NSSize)size
                             state: (GtkStateType)state
                            shadow: (GtkShadowType) shadow;

- (NSImage *) paintArrow: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                  shadow: (GtkShadowType) shadow
                   style: (GtkStyle *) style
               arrowType: (GtkArrowType) type
                    fill: (BOOL) fill;

- (NSImage *) paintExpander: (GtkWidget *) gtkWidget
                   withPart: (const gchar *) part
                    andSize: (const NSRect) size
                 usingState: (GtkStateType) state
              expanderStyle: (GtkExpanderStyle) style;

- (NSImage *) drawScrollbarArrow: (NSSize) size
                            type: (GtkArrowType) type
                          shadow: (GtkShadowType) shadow;

- (NSImage *) drawMenuItemArrow: (NSSize) size;

- (NSImage *) drawPopUpButtonArrow: (NSSize) size;

- (NSImage *) drawTreeViewExpander: (NSSize) size withExpanderStyle: (GtkExpanderStyle) style;
@end

#endif // GGPAINTER_H
