#import <AppKit/NSWindow.h>
#import <GNUstepGUI/GSTheme.h>
#import "GGPainter.h"
#import "GGnomeTheme.h"

@implementation GGnomeTheme (NSWindow)

- (void) reparentWindow: (NSWindow *)window
{
  Class cacheWindowClass = NSClassFromString(@"GSCacheW");
  Class iconWindowClass = NSClassFromString(@"NSIconWindow");
  Class menuPanelClass = NSClassFromString(@"NSMenuPanel");
  if([window isKindOfClass: [NSWindow class]] &&
     [window isKindOfClass: iconWindowClass] == NO &&
     [window isKindOfClass: cacheWindowClass] == NO &&
     [window isKindOfClass: menuPanelClass] == NO)
    {
      NSLog(@"Reparent window to GtkWindow here for NSWindow %@, number %d.",[window title],[window windowNumber]);
    }
}

@end
