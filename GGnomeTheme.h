#ifndef __CAMAELON_DRAW_FUNCTIONS_H__
#define __CAMAELON_DRAW_FUNCTIONS_H__

#include <GNUstepGUI/GSTheme.h>
#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>

@interface GGnomeTheme : GSTheme
- (void) activate;

//- (NSRect) drawButton: (NSRect)border withClip: (NSRect)clip;
- (void) drawButton: (NSRect)frame
                 in: (NSCell*)cell
               view: (NSView*)view
              style: (int)style
              state: (GSThemeControlState)state;

- (void) drawFocusFrame: (NSRect) frame view: (NSView*) view;

- (NSRect) drawDarkBezel: (NSRect)border withClip: (NSRect)clip isFlipped: (BOOL)flag;
- (NSRect) drawDarkBezel: (NSRect)border withClip: (NSRect)clip;
- (NSRect) drawGrayBezel: (NSRect)border withClip: (NSRect)clip;
- (NSRect) drawGroove: (NSRect)border withClip: (NSRect)clip;

- (void) drawBorderType: (NSBorderType)aType
                  frame: (NSRect)frame
                   view: (NSView*)view;

- (NSCell*) cellForScrollerKnob: (BOOL)horizontal;
- (NSCell*) cellForScrollerKnobSlot: (BOOL)horizontal;

- (void) drawStepperUpButton: (NSRect) aRect;
- (void) drawStepperHighlightUpButton: (NSRect) aRect;
- (void) drawStepperDownButton: (NSRect) aRect;
- (void) drawStepperHighlightDownButton: (NSRect) aRect;
@end

#endif
