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

#include <gtk/gtk.h>
#include <gconf/gconf-client.h>
#include <X11/Xlib.h>
#include <unistd.h>
#include <gdk/gdkx.h>
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

NSString *getGConfString(NSString *value);
NSString *getThemeName();
NSString *getDefaultFontName();
NSString *getMonospaceFontName();

void init_gtk_window();
void setup_gtk_widget(GtkWidget* widget);
void add_widget(GtkWidget *widget);;
void init_gtk_widgets();
void gtkStyleSetCallback(GtkWidget* widget, GtkStyle* style, void* foo);
NSString *classPath(GtkWidget *widget);
void add_widget_to_map(GtkWidget *widget);
void add_all_sub_widgets(GtkWidget *widget, gpointer v);
void add_widget(GtkWidget *widget);
NSSize scale_size(NSSize orig, gfloat factor);
void replace_icon(NSString *icon_name, NSImage *new_image);
void setup_icons();
NSColorList *setup_palette();
void setup_fonts();
