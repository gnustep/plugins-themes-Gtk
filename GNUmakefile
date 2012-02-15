ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif


include $(GNUSTEP_MAKEFILES)/common.make

MYCFLAGS = -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -D_REENTRANT -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/atk-1.0 -I/usr/include/gconf/2/

ADDITIONAL_OBJCFLAGS = -Wno-import -g $(MYCFLAGS) -O0 # -Wall -O2
ADDITIONAL_CFLAGS = $(MYCFLAGS)

ADDITIONAL_LDFLAGS = -v -L/usr/lib/debug/usr/lib/ -lgtk-x11-2.0 -lgdk-x11-2.0 -latk-1.0 -lpangoft2-1.0 -lgdk_pixbuf-2.0 -lm -lpangocairo-1.0 -lgio-2.0 -lcairo -lpango-1.0 -lfreetype -lfontconfig -lgobject-2.0 -lgmodule-2.0 -lglib-2.0 -lgdk-x11-2.0 -lgdk_pixbuf-2.0 -lm -lpangocairo-1.0 -lgio-2.0 -lpango-1.0 -lcairo -lgobject-2.0 -lgmodule-2.0 -lglib-2.0 -lgconf-2

#
# Main
#
PACKAGE_NAME = Gtk
BUNDLE_NAME = Gtk
BUNDLE_EXTENSION = .theme
VERSION = 1

Gtk_PRINCIPAL_CLASS = GGnomeTheme
Gtk_INSTALL_DIR=$(GNUSTEP_LIBRARY)/Themes
Gtk_RESOURCE_FILES=Resources/gnome_icon_48.png \
Resources/ThemeImages/*

#
# Class files
#
Gtk_OBJC_FILES = \
		GSBrowserTitleCell+Gnome.m \
		NSPopUpButtonCell+Gnome.m \
		NSMenuView+Gnome.m \
		NSSliderCell+Gnome.m \
		NSTableHeaderCell+Gnome.m \
		NSTableHeaderView+Gnome.m \
		NSTableView+Gnome.m \
		NSScrollView+Gnome.m \
		NSScroller+Gnome.m \
		NSTabView+Gnome.m \
		NSBrowser+Gnome.m \
		GGScrollKnobCell.m \
		GGScrollStepperCell.m \
		GGPainter.m \
		GGnomeThemeInitialization.m \
		GGnomeTheme.m

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make
-include ../../etoile.make

-include GNUmakefile.postamble
