ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif
ifeq ($(GNUSTEP_MAKEFILES),)
 $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif


include $(GNUSTEP_MAKEFILES)/common.make

MYCFLAGS = $(shell pkg-config --cflags glib-2.0 gtk+-2.0 gconf-2.0)

ADDITIONAL_OBJCFLAGS = -Wno-import -g $(MYCFLAGS) -O0 # -Wall -O2
ADDITIONAL_CFLAGS = $(MYCFLAGS)

Gtk_BUNDLE_LIBS = $(shell pkg-config --libs glib-2.0 gtk+-2.0 gconf-2.0)

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
		NSWindow+Gnome.m \
		GGScrollKnobCell.m \
		GGScrollStepperCell.m \
		GGPainter.m \
		GGnomeThemeInitialization.m \
		GGnomeTheme.m

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
