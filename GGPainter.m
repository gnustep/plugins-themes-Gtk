#include "GGPainter.h"

// static BOOL usePixmapCache = YES;

extern BOOL hasRgbaColormap;

void gdkrect_to_nsrect (GdkRectangle* gdkrect, NSRect* nsrect)
{
  nsrect->origin.x = gdkrect->x; // - nsrect->size.height;
  nsrect->origin.y = gdkrect->y;
  nsrect->size.width = gdkrect->width;
  nsrect->size.height = gdkrect->height;
}

void nsrect_to_gdkrect (NSRect* nsrect, GdkRectangle* gdkrect)
{
  gdkrect->x      = nsrect->origin.x + gdkrect->height;
  gdkrect->y      = nsrect->origin.y;
  gdkrect->width  = nsrect->size.width;
  gdkrect->height = nsrect->size.height;
}

#undef GTK_OBJECT_FLAGS
#define GTK_OBJECT_FLAGS(obj)(((GtkObject*)(obj))->flags)

#if GS_WORDS_BIGENDIAN
#   define GS_RED 3
#   define GS_GREEN 2
#   define GS_BLUE 1
#   define GS_ALPHA 0
#else
#   define GS_RED 0
#   define GS_GREEN 1
#   define GS_BLUE 2
#   define GS_ALPHA 3
#endif

#define GTK_RED   2
#define GTK_GREEN 1
#define GTK_BLUE  0
#define GTK_ALPHA 3

static inline void reorder_color_bytes(guchar *data, int width, int height, gboolean alpha) {
  int i;
  for (i = 0; i < width * height * (alpha ? 4 : 3); i += (alpha ? 4 : 3)) {
    unsigned char r, g, b;
    r = data[i + GTK_RED];
    g = data[i + GTK_GREEN];
    b = data[i + GTK_BLUE];
    data[i + GS_RED] = r;
    data[i + GS_GREEN] = g;
    data[i + GS_BLUE] = b;
  }
}

static inline GdkPixmap *init_pixmap_and_cairo_for_rect(GtkWidget *m_window, NSRect rect, GtkStyle **style, cairo_t **cr, cairo_public cairo_surface_t **pixmap_surface)
{
  GdkPixmap *pixmap = gdk_pixmap_new(GDK_DRAWABLE(m_window->window), rect.size.width, rect.size.height, -1);
  if (!pixmap)
    return NULL;
  *style = gtk_style_attach (*style, m_window->window);

  *cr = gdk_cairo_create (pixmap);
  cairo_set_operator(*cr, CAIRO_OPERATOR_SOURCE);
  cairo_set_source_rgba(*cr, 0, 0, 0, 0);
  cairo_paint(*cr);
  *pixmap_surface= cairo_get_target(*cr);
  cairo_surface_flush(*pixmap_surface);
  return pixmap;
}

static inline NSImage *create_ns_image_from_pixmap(BOOL m_alpha, NSRect rect, GdkPixmap *pixmap, cairo_t *cr, cairo_public cairo_surface_t *pixmap_surface)
{
  cairo_surface_t *result_surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, rect.size.width, rect.size.height);
  cairo_t *cr_result = cairo_create (result_surface);
  cairo_set_source_surface(cr_result, pixmap_surface, 0, 0);
  cairo_paint(cr_result);
  cairo_destroy(cr);
  cairo_destroy(cr_result);

  unsigned char *data = cairo_image_surface_get_data (result_surface);
  reorder_color_bytes(data, rect.size.width, rect.size.height, m_alpha);
  NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] init];
  [bitmap initWithBitmapDataPlanes: (unsigned char **) &data
                        pixelsWide: rect.size.width
                        pixelsHigh: rect.size.height
                     bitsPerSample: 8
                   samplesPerPixel: (m_alpha ? 4 : 3)
                          hasAlpha: m_alpha ? YES : NO
                          isPlanar: NO
                    colorSpaceName: NSCalibratedRGBColorSpace
                       bytesPerRow: 0
                      bitsPerPixel: 0
   ];
  NSImage *cache = [[NSImage alloc] init];
  [cache addRepresentation: bitmap];

  gdk_drawable_unref(pixmap);

  return cache;
}

@implementation GGPainter

+ (GGPainter *) instance
{
  static GGPainter *theInstance = nil;

  // @synchronized(self) 
    {
    if (theInstance == nil) {
      theInstance = [[GGPainter alloc] init];
      [theInstance retain];
    }
  }

  return theInstance;
}

+ (NSMutableDictionary *) widgetMap
{
  static NSMutableDictionary *gtkWidgetMap = nil;

  // @synchronized(self) 
    {
    if (gtkWidgetMap == nil) {
      gtkWidgetMap = [NSMutableDictionary dictionaryWithCapacity: 20];
      [gtkWidgetMap retain];
    }
  }

  return gtkWidgetMap;
}

+ (GtkWidget *) getWidget: (NSString *) widgetName
{
  NSValue *result = [[GGPainter widgetMap] objectForKey: widgetName];

  if (result != nil)
    return [result pointerValue];
  else
    return (GtkWidget *)nil;
}

+ (void) setWidget: (GtkWidget *) widget forKey: (NSString *) key
{
  [[GGPainter widgetMap] setValue: [NSValue valueWithPointer: widget] forKey: key];
}

#define COLOR_COMPONENT(gdkcolor, component) (((float)gdkcolor.component)/(float)65535)

+ (NSColor *) fromGdkColor: (GdkColor) gdk_color
{
  return [NSColor colorWithCalibratedRed: COLOR_COMPONENT(gdk_color, red)
                                   green: COLOR_COMPONENT(gdk_color, green)
                                    blue: COLOR_COMPONENT(gdk_color, blue)
                                   alpha: 1.0];
}

- (NSImage *) stockIcon: (const gchar *) iconName
{
  return [self stockIcon: iconName withSize: GTK_ICON_SIZE_SMALL_TOOLBAR];
}

- (NSImage *) stockIcon: (const gchar *) iconName withSize: (GtkIconSize) size
{
    GtkStyle *style = [self gtkStyle];
    GtkIconSet* iconSet = gtk_style_lookup_icon_set (style, iconName);
    GdkPixbuf* icon = gtk_icon_set_render_icon(iconSet,
                                               style,
                                               GTK_TEXT_DIR_LTR,
                                               GTK_STATE_NORMAL,
                                               size,
                                               NULL,
                                               "button");

    NSImage *converted = [self fromPixbuf: icon];

    gdk_pixbuf_unref(icon);

    return converted;
}

- (NSImage *) namedIcon: (const gchar *) iconName withSize: (gint) size
{
  // GtkStyle *style = [self gtkStyle];
  GtkIconTheme *icon_theme = gtk_icon_theme_get_default();
  assert(icon_theme);
  GdkPixbuf* icon = gtk_icon_theme_load_icon(icon_theme, iconName, size, 0, NULL);
  NSImage *converted = nil;
  if(icon)
    {
      //assert(icon);
      converted = [self fromPixbuf: icon];
      gdk_pixbuf_unref(icon);
    }
  else
    {
      NSLog(@"Failed to look up theme-based icon for iconName %s, using default.",iconName);
    }
  
  return converted;
}

- (void) drawAndReleaseImage: (NSImage *) image 
		     inFrame: (NSRect) cellFrame 
		     flipped: (BOOL) flipped
{
  if (flipped) {
    [NSGraphicsContext saveGraphicsState];
    NSAffineTransform *t = [NSAffineTransform transform];

    // by scaling Y negatively, we effectively flip the image:
    [t scaleXBy:1.0 yBy:-1.0];
    [t concat];
    [image drawInRect: NSMakeRect(cellFrame.origin.x, 
				  -( cellFrame.origin.y + 
				     cellFrame.size.height ), 
				  cellFrame.size.width, 
				  cellFrame.size.height)
             fromRect: NSMakeRect(0, 0, cellFrame.size.width, cellFrame.size.height)
            operation: NSCompositeSourceOver
             fraction: 1.0];
    [NSGraphicsContext restoreGraphicsState];
  } else {
    [image drawInRect: cellFrame
             fromRect: NSMakeRect(0, 0, cellFrame.size.width, cellFrame.size.height)
            operation: NSCompositeSourceOver
             fraction: 1.0];
  }

  RELEASE(image);
}

- (void) drawAndReleaseImage: (NSImage *) image inFrame: (NSRect) cellFrame withClip: (NSRect) clip
{
  [NSGraphicsContext saveGraphicsState];
  NSRectClip(clip);

  [self drawAndReleaseImage: image inFrame: cellFrame flipped: NO];

  [NSGraphicsContext restoreGraphicsState];
}


- (NSImage *) fromPixbuf: (GdkPixbuf *) pixbuf
{
    cairo_surface_t *result_surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, gdk_pixbuf_get_width(pixbuf), gdk_pixbuf_get_height(pixbuf));
    cairo_t *cr_result = cairo_create (result_surface);
    gdk_cairo_set_source_pixbuf(cr_result, pixbuf, 0, 0);
    cairo_paint(cr_result);
    cairo_destroy(cr_result);
    unsigned char *data = cairo_image_surface_get_data (result_surface);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] init];

    int width =  gdk_pixbuf_get_width(pixbuf);
    int height =  gdk_pixbuf_get_height(pixbuf);
    gboolean alpha = gdk_pixbuf_get_has_alpha(pixbuf);

    reorder_color_bytes(data, width, height, alpha);

    [bitmap initWithBitmapDataPlanes: (unsigned char **) &data
                          pixelsWide: width
                          pixelsHigh: height
                       bitsPerSample: 8
                     samplesPerPixel: (alpha ? 4 : 3)
                            hasAlpha: alpha ? YES : NO
                            isPlanar: NO
                      colorSpaceName: NSCalibratedRGBColorSpace
                         bytesPerRow: 0
                        bitsPerPixel: 0
     ];
    NSImage *converted = [[NSImage alloc] init];
    [converted addRepresentation: bitmap];
    return converted;
}

- (id) init
{
  if ((self = [super init]))
    {
      m_alpha    = YES;
      m_window   = GTK_WIDGET([GGPainter getWidget: @"GtkWindow"]);
    }

  return self;
}

- (GtkStateType) gtkState: (GSThemeControlState) gs_state forCell: (NSCell *) cell
{
  GtkStateType gtk_state = GTK_STATE_NORMAL;

  if ([cell isEnabled]) {
    if (gs_state == GSThemeNormalState)
      gtk_state = GTK_STATE_NORMAL;
    else if (gs_state == GSThemeHighlightedState)
      gtk_state = GTK_STATE_PRELIGHT;
    else if (gs_state == GSThemeSelectedState)
      gtk_state = GTK_STATE_ACTIVE;
  } else
    gtk_state = GTK_STATE_INSENSITIVE;
  return gtk_state;
}

- (GtkStyle *) getWidgetStyle: (GtkWidget *) gtkWidget
{
    assert(gtkWidget);
    GtkStyle* style = gtkWidget->style;
    assert(style);
    return style;
}

- (GtkStyle *) gtkStyle
{
  return [self getWidgetStyle: [GGPainter getWidget: @"GtkWindow"]];
}

- (NSString *) uniqueNameForPart: (NSString *) key
			  state: (GtkStateType) state
			 shadow: (GtkShadowType) shadow
			   size: (NSRect) size
			 widget: (GtkWidget *) widget
{
  // Note the widget arg should ideally use the widget path, though would compromise performance
  NSString *tmp = [NSString stringWithFormat: @"%@-%u-%u-%ux%u-%qx", key, state, shadow,
			    size.size.width, size.size.height, widget];
  return tmp;
}


#define PAINT_FUNCTION_BODY(contents) \
    NSRect rect = size;                                                 \
    cairo_t *cr;                                                        \
    cairo_public cairo_surface_t *pixmap_surface;                        \
    GdkPixmap *pixmap = init_pixmap_and_cairo_for_rect(m_window, rect, &style, &cr, &pixmap_surface); \
    \
    contents; \
     \
    return create_ns_image_from_pixmap(m_alpha, rect, pixmap, cr, pixmap_surface); \


- (NSImage *) paintBox: (GtkWidget *) gtkWidget
              withPart: (const gchar *) part
               andSize: (const NSRect) size
              withClip: (const NSRect) clip
            usingState: (GtkStateType) state
                shadow: (GtkShadowType) shadow
                 style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(
    GdkRectangle gdk_clip;
    nsrect_to_gdkrect((NSRect *)&clip, &gdk_clip);

    gtk_paint_box (style,
                   pixmap,
                   state,
                   shadow,
                   NSEqualRects(clip, NSZeroRect) ? NULL : &gdk_clip,
                   gtkWidget,
                   part,
                   0, 0,
                   rect.size.width,
                   rect.size.height);

    )// PAINT_FUNCTION_BODY
}

- (NSImage *) paintFlatBox: (GtkWidget *) gtkWidget
                  withPart: (const gchar *) part
                   andSize: (const NSRect) size
                  withClip: (const NSRect) clip
                usingState: (GtkStateType) state
                    shadow: (GtkShadowType) shadow
                     style: (GtkStyle *) style
{
PAINT_FUNCTION_BODY(
                    GdkRectangle gdk_clip;
                    nsrect_to_gdkrect((NSRect *)&clip, &gdk_clip);
                    
                    gtk_paint_flat_box (style,
                                        pixmap,
                                        state,
                                        shadow,
                                        NSEqualRects(clip, NSZeroRect) ? NULL : &gdk_clip,
                                        gtkWidget,
                                        part,
                                        0, 0,
                                        rect.size.width,
                                        rect.size.height);
                    )
}

- (NSImage *) paintExtension: (GtkWidget *) gtkWidget
                    withPart: (const gchar *) part
                     andSize: (const NSRect) size
                    withClip: (const NSRect) clip
                  usingState: (GtkStateType) state
                      shadow: (GtkShadowType) shadow
                    position: (GtkPositionType) position
                       style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(
    GdkRectangle gdk_clip;
    nsrect_to_gdkrect((NSRect *)&clip, &gdk_clip);

    gtk_paint_extension (style,
                         pixmap,
                         state,
                         shadow,
                         NSEqualRects(clip, NSZeroRect) ? NULL : &gdk_clip,
                         gtkWidget,
                         (gchar *)part,
                         0, 0,
                         rect.size.width,
                         rect.size.height,
                         position);

    )// PAINT_FUNCTION_BODY
}

- (NSImage *) paintShadow: (GtkWidget *) gtkWidget
               withPart: (const gchar *) part
                andSize: (const NSRect) size
             usingState: (GtkStateType) state
                 shadow: (GtkShadowType) shadow
                  style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(gtk_paint_shadow (style,
                                      pixmap,
                                      state,
                                      shadow,
                                      NULL,
                                      gtkWidget,
                                      part,
                                      0, 0,
                                      rect.size.width,
                                      rect.size.height))
}

- (NSImage *) paintHLine: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                   style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(gtk_paint_hline (style,
                                       pixmap,
                                       state,
                                       NULL,
                                       gtkWidget,
                                       part,
                                       0,
                                       rect.size.width,
                                       0))
}

- (NSImage *) paintVLine: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                   style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(gtk_paint_vline (style,
                                       pixmap,
                                       state,
                                       NULL,
                                       gtkWidget,
                                       part,
                                       0,
                                       rect.size.height,
                                       0))
}


- (NSImage *) paintFocus: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                   style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(gtk_paint_focus (style,
                                       pixmap,
                                       state,
                                       NULL,
                                       gtkWidget,
                                       part,
                                       0, 0,
                                       rect.size.width,
                                       rect.size.height))
}

- (NSImage *) paintOption: (GtkWidget *) gtkWidget
                 withPart: (const gchar *) part
                  andSize: (const NSRect) size
               usingState: (GtkStateType) state
                   shadow: (GtkShadowType) shadow
                    style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(gtk_paint_option (style,
                                        pixmap,
                                        state,
                                        shadow,
                                        NULL,
                                        gtkWidget,
                                        part,
                                        0, 0,
                                        rect.size.width,
                                        rect.size.height))
}

- (NSImage *) drawRadioButton: (NSSize)size
                        state: (GtkStateType)state
                       shadow: (GtkShadowType) shadow
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *button = [GGPainter getWidget: @"GtkRadioButton"];
  // GtkStyle *gtk_style = [painter gtkStyle];

  NSImage *img = [painter paintOption: button
                             withPart: "button"
                              andSize: NSMakeRect(0, 0, size.height, size.width)
                           usingState: state
                               shadow: shadow
                                style: button->style];

  return img;
}

- (NSImage *) paintCheck: (GtkWidget *) gtkWidget
                 withPart: (const gchar *) part
                  andSize: (const NSRect) size
               usingState: (GtkStateType) state
                   shadow: (GtkShadowType) shadow
                    style: (GtkStyle *) style
{
  PAINT_FUNCTION_BODY(gtk_paint_check (style,
                                       pixmap,
                                       state,
                                       shadow,
                                       NULL,
                                       gtkWidget,
                                       part,
                                       0, 0,
                                       rect.size.width,
                                       rect.size.height))
}

- (NSImage *) drawCheckButton: (NSSize)size
                        state: (GtkStateType)state
                       shadow: (GtkShadowType) shadow
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *button = [GGPainter getWidget: @"GtkCheckButton"];
  // GtkStyle *gtk_style = [painter gtkStyle];


  NSImage *img = [painter paintCheck: button
                            withPart: "checkbutton"
                             andSize: NSMakeRect(0, 0, size.height, size.width)
                          usingState: state
                              shadow: shadow
                               style: button->style];

  return img;
}

- (NSImage *) paintSlider: (GtkWidget *) gtkWidget
                 withPart: (const gchar *) part
                  andSize: (const NSRect) size
               usingState: (GtkStateType) state
                   shadow: (GtkShadowType) shadow
                    style: (GtkStyle *) style
              orientation: (GtkOrientation) orientation
{
  PAINT_FUNCTION_BODY(gtk_paint_slider (style,
                                        pixmap,
                                        state,
                                        shadow,
                                        NULL,
                                        gtkWidget,
                                        part,
                                        0, 0,
                                        rect.size.width,
                                        rect.size.height,
                                        orientation))
}



- (NSImage *) drawVerticalSlider: (NSSize)size
                           state: (GtkStateType)state
                          shadow: (GtkShadowType) shadow
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkVScale"];
  // GtkStyle *gtk_style = [painter gtkStyle];


  NSImage *img = [painter paintSlider: widget
                             withPart: "vscale"
                              andSize: NSMakeRect(0, 0, size.height, size.width)
                           usingState: state
                               shadow: shadow
                                style: widget->style
                          orientation: GTK_ORIENTATION_VERTICAL];

  return img;
}

- (NSImage *) drawHorizontalSlider: (NSSize)size
                             state: (GtkStateType)state
                            shadow: (GtkShadowType) shadow
{
  GGPainter *painter = [GGPainter instance];

   GtkWidget *widget = [GGPainter getWidget: @"GtkHScale"];

   NSImage *img = [painter paintSlider: widget
                              withPart: "hscale"
                               andSize: NSMakeRect(0, 0, size.height, size.width)
                            usingState: state
                                shadow: shadow
                                 style: widget->style
                           orientation: GTK_ORIENTATION_HORIZONTAL];

   return img;
}

- (NSImage *) paintArrow: (GtkWidget *) gtkWidget
                withPart: (const gchar *) part
                 andSize: (const NSRect) size
              usingState: (GtkStateType) state
                  shadow: (GtkShadowType) shadow
                   style: (GtkStyle *) style
               arrowType: (GtkArrowType) type
                    fill: (BOOL) fill
{
  PAINT_FUNCTION_BODY(gtk_paint_arrow (style,
                                       pixmap,
                                       state,
                                       shadow,
                                       NULL,
                                       gtkWidget,
                                       part,
                                       type,
                                       fill,
                                       0, 0,
                                       rect.size.width,
                                       rect.size.height))
}

- (NSImage *) paintExpander: (GtkWidget *) gtkWidget
                   withPart: (const gchar *) part
                    andSize: (const NSRect) size
                 usingState: (GtkStateType) state
              expanderStyle: (GtkExpanderStyle) expanderStyle
{
  GtkStyle *style = gtkWidget->style;
  PAINT_FUNCTION_BODY(gtk_paint_expander ( style,
                                           pixmap,
                                           state,
                                           NULL,
                                           gtkWidget,
                                           part,
                                           size.origin.x + size.size.width / 2,
                                           size.origin.y + size.size.height / 2,
                                           expanderStyle))
}



- (NSImage *) drawScrollbarArrow: (NSSize) size
                            type: (GtkArrowType) type
                          shadow: (GtkShadowType) shadow
{
  GGPainter *painter = [GGPainter instance];

  BOOL horizontal = (type != GTK_ARROW_UP || GTK_ARROW_DOWN);

  GtkWidget *widget = [GGPainter getWidget: horizontal ? @"GtkHScrollbar" : @"GtkVScrollbar"];

  NSImage *arrow = [painter paintArrow: widget
                              withPart: horizontal ? "hscrollbar" : "vscrollbar"
                               andSize: NSMakeRect(0, 0, size.height, size.width)
                            usingState: GTK_STATE_NORMAL
                                shadow: shadow
                                 style: widget->style
                             arrowType: type
                                  fill: YES];

 return arrow;
}

- (NSImage *) drawMenuItemArrow: (NSSize) size
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: @"GtkMenu.GtkMenuItem"];

  NSImage *arrow = [painter paintArrow: widget
                              withPart: "menuitem"
                               andSize: NSMakeRect(0, 0, size.height, size.width)
                            usingState: GTK_STATE_NORMAL
                                shadow: GTK_SHADOW_OUT
                                 style: widget->style
                             arrowType: GTK_ARROW_RIGHT
                                  fill: YES];

 return arrow;
}

- (NSImage *) drawPopUpButtonArrow: (NSSize) size
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: @"GtkComboBox.GtkToggleButton.GtkHBox.GtkArrow"];

  NSImage *arrow = [painter paintArrow: widget
                              withPart: "arrow"
                               andSize: NSMakeRect(0, 0, size.height, size.width)
                            usingState: GTK_STATE_NORMAL
                                shadow: GTK_SHADOW_NONE
                                 style: widget->style
                             arrowType: GTK_ARROW_DOWN
                                  fill: YES];

 return arrow;
}

- (NSImage *) drawTreeViewExpander: (NSSize) size withExpanderStyle: (GtkExpanderStyle) style
{
  GGPainter *painter = [GGPainter instance];

  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView"];

  return [painter paintExpander: widget
                       withPart: "treeview"
                        andSize: NSMakeRect(0, widget->style->ythickness, size.width, size.height)
                     usingState: GTK_STATE_NORMAL
                  expanderStyle: style];
}

@end
