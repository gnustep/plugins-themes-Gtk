/****************************************************************************
**
** Parts Copyright (C) 2007-2008 Trolltech ASA. All rights reserved.
** Objective C parts (C) 2009 Hans Baier
**
** Parts of this file are derived from the QGtkStyle project on Trolltech Labs.
**
** This file may be used under the terms of the GNU General Public
** License version 2.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of
** this file.  Please review the following information to ensure GNU
** General Public Licensing requirements will be met:
** http://www.trolltech.com/products/qt/opensource.html
**
** If you are unsure which license is appropriate for your use, please
** review the following information:
** http://www.trolltech.com/products/qt/licensing.html or contact the
** sales department at sales@trolltech.com.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#include "GGnomeThemeInitialization.h"
#include "GGnomeTheme.h"
#include "GGPainter.h"

BOOL hasRgbaColormap = NO;

static int displayDepth  =  -1;

NSString *getGConfString(NSString *value)
{
  NSString *retVal;

  g_type_init();
  GConfClient* client = gconf_client_get_default();
  GError *err = 0;
  char *str = gconf_client_get_string(client, [value UTF8String], &err);
  if (!err) {
    retVal = [NSString stringWithUTF8String: str];
    g_free(str);
  }
  g_object_unref(client);
  if (err)
    g_error_free (err);

  return retVal;
}

NSString *getThemeName()
{
  return getGConfString(@"/desktop/gnome/interface/gtk_theme");
}

NSString *getDefaultFontName()
{
  return getGConfString(@"/desktop/gnome/interface/font_name");
}

NSString *getMonospaceFontName()
{
  return getGConfString(@"/desktop/gnome/interface/monospace_font_name");
}

typedef int (*x11ErrorHandler)(Display*, XErrorEvent*);

void init_gtk_window()
{
  static NSString *themeName = nil;
  
  if ( [GGPainter getWidget: @"GtkWindow"] == (GtkWidget *)nil && [themeName length] == 0) {
    NSLog (@"initializing GtkWindow");
    themeName = getThemeName();

    x11ErrorHandler gs_x_errhandler = XSetErrorHandler(0);
    gtk_init (NULL, NULL);
    GdkScreen *screen;
    GdkColormap *cmap;
    screen = gdk_screen_get_default();
    cmap = gdk_screen_get_rgba_colormap (screen);

    // Enable this to get cairo performance improvements
    // currently disabled due to painting glitches
    if (cmap) {
      hasRgbaColormap = YES;
      gdk_screen_set_default_colormap (screen, cmap);
    }
    XSetErrorHandler(gs_x_errhandler);

    GtkWidget* gtkWindow = gtk_window_new(GTK_WINDOW_POPUP);
    gtk_widget_realize(gtkWindow);
    if (displayDepth == -1)
      displayDepth = gdk_drawable_get_depth(gtkWindow->window);

    [GGPainter setWidget: gtkWindow forKey: @"GtkWindow"];
    NSLog (@"initializing GtkWindow finished ==========");
  }
}

void setup_gtk_widget(GtkWidget* widget)
{
    if (GTK_IS_WIDGET(widget)) {
        static GtkWidget* protoLayout = 0;

        if (!protoLayout) {
            protoLayout = gtk_fixed_new();
            gtk_container_add((GtkContainer*)[GGPainter getWidget: @"GtkWindow"], protoLayout);
        }

        assert(protoLayout);

        gtk_container_add((GtkContainer*)(protoLayout), widget);
        gtk_widget_realize(widget);
    }
}

void add_widget(GtkWidget *widget);

void init_gtk_widgets()
{
  if ( [GGPainter getWidget: @"GtkButton"] == (GtkWidget *)nil) {
    add_widget(gtk_button_new());
    add_widget(gtk_hbutton_box_new());
    add_widget(gtk_check_button_new());
    add_widget(gtk_radio_button_new(NULL));
    add_widget(gtk_combo_box_new());
    //    add_widget(gtk_combo_box_entry_new());
    add_widget(gtk_entry_new());
    add_widget(gtk_frame_new(NULL));
    //    add_widget(gtk_expander_new(""));
    //    add_widget(gtk_statusbar_new());
    add_widget(gtk_hscale_new((GtkAdjustment*)(gtk_adjustment_new(1, 0, 1, 0, 0, 0))));
    add_widget(gtk_hscrollbar_new(NULL));
    add_widget(gtk_progress_bar_new());
    add_widget(gtk_notebook_new());
    add_widget(gtk_spin_button_new((GtkAdjustment*)
                                   (gtk_adjustment_new(1, 0, 1, 0, 0, 0)), 0.1, 3));

    GtkWidget *gtkTreeView = gtk_tree_view_new();
    gtk_tree_view_append_column((GtkTreeView*)gtkTreeView, gtk_tree_view_column_new());
    gtk_tree_view_append_column((GtkTreeView*)gtkTreeView, gtk_tree_view_column_new());
    gtk_tree_view_append_column((GtkTreeView*)gtkTreeView, gtk_tree_view_column_new());
    add_widget(gtkTreeView);

    GtkWidget *gtkMenuBar = gtk_menu_bar_new();
    setup_gtk_widget(gtkMenuBar);

    GtkWidget *gtkMenuBarItem = gtk_menu_item_new();
    gtk_menu_shell_append((GtkMenuShell*)(gtkMenuBar), gtkMenuBarItem);
    gtk_widget_realize(gtkMenuBarItem);

    // Create menu
    GtkWidget *gtkMenu = gtk_menu_new();
    gtk_menu_item_set_submenu((GtkMenuItem*)(gtkMenuBarItem), gtkMenu);
    gtk_widget_realize(gtkMenu);

    GtkWidget *gtkMenuItem = gtk_menu_item_new();
    gtk_menu_shell_append((GtkMenuShell*)gtkMenu, gtkMenuItem);
    gtk_widget_realize(gtkMenuItem);

    GtkWidget *gtkCheckMenuItem = gtk_check_menu_item_new();
    gtk_menu_shell_append((GtkMenuShell*)gtkMenu, gtkCheckMenuItem);
    gtk_widget_realize(gtkCheckMenuItem);

    GtkWidget *gtkMenuSeparator = gtk_separator_menu_item_new();
    gtk_menu_shell_append((GtkMenuShell*)gtkMenu, gtkMenuSeparator);

    add_widget(gtkMenuBar);
    add_widget(gtkMenu);

    /*
    GtkWidget *toolbar = gtk_toolbar_new();
    gtk_toolbar_insert((GtkToolbar*)toolbar, gtk_separator_tool_item_new(), -1);
    add_widget(toolbar);
    */
    add_widget(gtk_vscale_new((GtkAdjustment*)(gtk_adjustment_new(1, 0, 1, 0, 0, 0))));
    add_widget(gtk_vscrollbar_new(NULL));
  }
    NSLog(@"Widget Map initialized: %@", [[GGPainter widgetMap] description]);
}

void gtkStyleSetCallback(GtkWidget* widget, GtkStyle* style, void* foo)
{
  static NSString *oldTheme = @"gs_not_set";

  init_gtk_widgets();
  
  if ( ![oldTheme isEqualToString: getThemeName()] ) {
    oldTheme = getThemeName();
    //TODO care about widget palette stuff here
  }
}

NSString *classPath(GtkWidget *widget)
{
  char* class_path;
  gtk_widget_path (widget, NULL, &class_path, NULL);
  NSString *path = [NSString stringWithUTF8String: class_path];
  
  // Remove the prefixes
  path = [path stringByReplacingString: @"GtkWindow." withString: @""];
  path = [path stringByReplacingString: @"GtkFixed." withString: @""];
  
  return path;
}

void add_widget_to_map(GtkWidget *widget)
{
  if (GTK_IS_WIDGET(widget)) {
    gtk_widget_realize(widget);
    NSLog(@"registering widget: %@", classPath(widget));
    [GGPainter setWidget: widget forKey: classPath(widget)];
  }
}

void add_all_sub_widgets(GtkWidget *widget, gpointer v)
{
  add_widget_to_map(widget);
  if (GTK_CHECK_TYPE ((widget), gtk_container_get_type()))
    gtk_container_forall((GtkContainer*)widget, add_all_sub_widgets, NULL);
}

void add_widget(GtkWidget *widget)
{
  if (widget) {
    setup_gtk_widget(widget);
    add_all_sub_widgets(widget, 0);
    g_signal_connect(widget, "style-set", G_CALLBACK(gtkStyleSetCallback), NULL);
  }
}

NSSize scale_size(NSSize orig, gfloat factor)
{
  return NSMakeSize(orig.width * factor, orig.height * factor);
}

void replace_icon(NSString *icon_name, NSImage *new_image)
{
  NSImage *img = [NSImage imageNamed: icon_name];
  [img setName: [@"kick_" stringByAppendingString: icon_name]];
  [new_image setName: icon_name];
} 

void setup_icons()
{
  GGPainter *painter = [GGPainter instance];
  [[painter stockIcon: GTK_STOCK_HOME] setName: @"common_Home"];
  // [[painter namedIcon: "gdu-mount"   withSize: 22] setName: @"common_Mount"];
  // [[painter namedIcon: "gdu-unmount" withSize: 22] setName: @"common_Unmount"];
  [[painter stockIcon: GTK_STOCK_OK] setName: @"common_ret"];
  [[painter stockIcon: GTK_STOCK_CLOSE withSize: GTK_ICON_SIZE_MENU] setName: @"common_Close"];
  [[painter stockIcon: GTK_STOCK_CLOSE withSize: GTK_ICON_SIZE_MENU] setName: @"common_CloseH"];

  [[painter namedIcon: "folder" withSize: 48] setName: @"common_Folder"];
  [[painter namedIcon: "folder_home" withSize: 48] setName: @"common_HomeDirectory"];

  // radio button theme images
  NSImage *img = [NSImage imageNamed: @"NSHighlightedRadioButton"];
  [[painter drawRadioButton: [img size] state: GTK_STATE_NORMAL shadow: GTK_SHADOW_IN] setName: @"common_RadioOn"];
  [[painter drawRadioButton: [img size] state: GTK_STATE_NORMAL shadow: GTK_SHADOW_OUT] setName: @"common_RadioOff"];
  [[painter namedIcon: "unknown" withSize: 48] setName: @"common_Unknown"];
  [[painter namedIcon: "exec" withSize: 48] setName: @"common_UnknownTool"];
  [[painter namedIcon: "computer" withSize: 48] setName: @"common_Root_PC"];

  // check button theme images
  img = [NSImage imageNamed: @"NSSwitch"];
  [[painter drawCheckButton: [img size] state: GTK_STATE_NORMAL shadow: GTK_SHADOW_IN] setName: @"common_SwitchOn"];
  [[painter drawCheckButton: [img size] state: GTK_STATE_NORMAL shadow: GTK_SHADOW_OUT] setName: @"common_SwitchOff"];

  NSString *icon_name = nil;
  
  img = [NSImage imageNamed: @"common_SliderVert"];
  [img setName: @"kick_SliderVert"];
  img = [painter drawHorizontalSlider: [img size] state: GTK_STATE_NORMAL shadow: GTK_SHADOW_OUT];
  [img setName: @"common_SliderHoriz"];

  img = [NSImage imageNamed: @"common_SliderHoriz"];
  [img setName: @"kick_SliderVert"];
  img = [painter drawVerticalSlider: [img size] state: GTK_STATE_NORMAL shadow: GTK_SHADOW_OUT];
  [img setName: @"common_SliderVert"];

  gfloat arrow_scaling = 0.91;
  icon_name = @"common_ArrowLeft";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_LEFT shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_ArrowLeftH";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_LEFT shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_ArrowRight";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_RIGHT shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_ArrowRightH";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_RIGHT shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_ArrowUp";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_UP shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_ArrowUpH";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_UP shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_ArrowDown";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_DOWN shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_ArrowDownH";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: scale_size([img size], arrow_scaling) type: GTK_ARROW_DOWN shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_Nibble";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawPopUpButtonArrow: [img size]]);

  icon_name = @"common_3DArrowDown";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawPopUpButtonArrow: [img size]]);

  icon_name = @"common_3DArrowRight";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: [img size] type: GTK_ARROW_RIGHT shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_3DArrowRightH";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: [img size] type: GTK_ARROW_RIGHT shadow: GTK_SHADOW_IN]);

  icon_name = @"NSMenuArrow";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawScrollbarArrow: [img size] type: GTK_ARROW_RIGHT shadow: GTK_SHADOW_NONE]);

  icon_name = @"common_outlineCollapsed";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawTreeViewExpander: [img size] withExpanderStyle: GTK_EXPANDER_COLLAPSED]);

  icon_name = @"common_outlineExpanded";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawTreeViewExpander: [img size] withExpanderStyle: GTK_EXPANDER_EXPANDED]);

  icon_name = @"common_outlineExpanded";
  img = [NSImage imageNamed: icon_name];
  replace_icon(icon_name, [painter drawTreeViewExpander: [img size] withExpanderStyle: GTK_EXPANDER_EXPANDED]);

  img = [NSImage imageNamed: @"common_outlineUnexpandable"];
  /*
  [img lockFocus];
  [[NSColor colorWithCalibratedWhite: 1.0 alpha: 0.0] set];
  NSRectFill(NSMakeRect(0, 0, [img size].width, [img size].height));
  [img unlockFocus];
  */
}

NSColorList *setup_palette()
{
  GtkStyle *windowstyle = [GGPainter getWidget: @"GtkWindow"]->style;

  NSColorList *systemcolors = [[NSColorList alloc] initWithName: @"System" 
						   fromFile: nil];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->bg[GTK_STATE_NORMAL]] forKey: @"controlBackgroundColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->mid[GTK_STATE_NORMAL]] forKey: @"controlColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->bg[GTK_STATE_SELECTED]] forKey: @"selectedControlColor"];
  //*
  // [systemcolors setColor: [NSColor redColor] forKey: @"controlColor"];
  // [systemcolors setColor: [NSColor greenColor] forKey: @"controlBackgroundColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->text[GTK_STATE_SELECTED]] forKey: @"selectedControlTextColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->fg[GTK_STATE_PRELIGHT]] forKey: @"controlHighlightColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->light[GTK_STATE_PRELIGHT]] forKey: @"controlLightHighlightColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->mid[GTK_STATE_NORMAL]] forKey: @"controlShadowColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->dark[GTK_STATE_NORMAL]] forKey: @"controlDarkShadowColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->text[GTK_STATE_NORMAL]] forKey: @"controlTextColor"];
  //*/
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->text[GTK_STATE_INSENSITIVE]] forKey: @"disabledControlTextColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->bg[GTK_STATE_NORMAL]] forKey: @"windowBackgroundColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->fg[GTK_STATE_NORMAL]] forKey: @"windowFrameColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: windowstyle->fg[GTK_STATE_INSENSITIVE]] forKey: @"windowFrameTextColor"];
  [systemcolors setColor: [GGPainter fromGdkColor: [GGPainter getWidget: @"GtkHScrollbar"]->style->bg[GTK_STATE_NORMAL]] forKey: @"scrollBarColor"];

  // Fill in the rest of them...
  [systemcolors setColor: [NSColor whiteColor]
		forKey: @"textBackgroundColor"];
  [systemcolors setColor: [NSColor blackColor]
		forKey: @"textColor"];

  return systemcolors;
}

NSFont *fontFromNameAndSize(NSString *nameAndSize)
{
  NSString *fontName = nil;
  NSString *fontSize = nil;
  NSScanner *scanner = [NSScanner scannerWithString: nameAndSize];
  [scanner scanUpToCharactersFromSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]
			  intoString: &fontName];
  [scanner scanCharactersFromSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]
		      intoString: NULL];
  [scanner scanUpToCharactersFromSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]
			  intoString: &fontSize];
  float fSize = [fontSize floatValue] + 3; // not sure why this is needed.  GS seems to be rendering fonts smaller than GNOME.
  NSFont *font = [NSFont fontWithName: fontName
				 size: fSize];
  
  if(font == nil)
    {
      if([fontName isEqualToString: @"Sans"])
	{
	  font = [NSFont fontWithName: @"Liberation Sans"
				 size: fSize];
	}
      if([fontName isEqualToString: @"Monospace"])
	{
	  font = [NSFont fontWithName: @"Liberation Mono"
				 size: fSize];
	}
    }

  return font;
}

void setup_fonts()
{
  NSString *defaultFontNameAndSize = getDefaultFontName();
  NSString *monoFontNameAndSize = getMonospaceFontName();
  NSFont *defaultFont = fontFromNameAndSize(defaultFontNameAndSize);
  if(defaultFont != nil)
    {
      [NSFont setUserFont: defaultFont];
    }
  NSFont *fixedFont = fontFromNameAndSize(monoFontNameAndSize);
  if(fixedFont != nil)
    {
      [NSFont setUserFixedPitchFont:fixedFont];
    }
}
