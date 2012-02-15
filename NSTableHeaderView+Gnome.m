#include <AppKit/AppKit.h>
#include "GGnomeTheme.h"
#include "GGPainter.h"

@implementation GGnomeTheme (NSTableHeaderView)
/*
 * Overidden Methods
 */
- (void)drawTableHeaderRect: (NSRect)aRect
		     inView: (NSView *)view
{
  NSTableHeaderView *tableHeaderView = (NSTableHeaderView *)view;
  NSTableView *tableView = [tableHeaderView tableView];
  NSArray *columns;
  int firstColumnToDraw;
  int lastColumnToDraw;
  NSRect drawingRect;
  NSTableColumn *column;
  NSTableColumn *highlightedTableColumn;
  float width;
  int i;
  NSCell *cell;

  if (tableView == nil)
    return;

  firstColumnToDraw = [tableHeaderView columnAtPoint: NSMakePoint (aRect.origin.x,
                                                        aRect.origin.y)];
  if (firstColumnToDraw == -1)
    firstColumnToDraw = 0;

  lastColumnToDraw = [tableHeaderView columnAtPoint: NSMakePoint (NSMaxX (aRect),
                                                       aRect.origin.y)];
  if (lastColumnToDraw == -1)
    lastColumnToDraw = [tableView numberOfColumns] - 1;

  drawingRect = [tableHeaderView headerRectOfColumn: firstColumnToDraw];
  if (![tableHeaderView isFlipped])
    {
      drawingRect.origin.y++;
    }
  //avoid gap: drawingRect.size.height--;

  columns = [tableView tableColumns];
  highlightedTableColumn = [tableView highlightedTableColumn];
  
  for (i = firstColumnToDraw; i < lastColumnToDraw; i++)
    {
      column = [columns objectAtIndex: i];
      width = [column width];
      drawingRect.size.width = width;
      cell = [column headerCell];
      if ((column == highlightedTableColumn)
          || [tableView isColumnSelected: i])
        {
          [cell setHighlighted: YES];
        }
      else
        {
          [cell setHighlighted: NO];
        }
      [cell drawWithFrame: drawingRect
                           inView: tableHeaderView];
      drawingRect.origin.x += width;
    }
  if (lastColumnToDraw == [tableView numberOfColumns] - 1)
    {
      column = [columns objectAtIndex: lastColumnToDraw];
      width = [column width] - 1;
      drawingRect.size.width = width;
      cell = [column headerCell];
      if ((column == highlightedTableColumn)
          || [tableView isColumnSelected: lastColumnToDraw])
        {
          [cell setHighlighted: YES];
        }
      else
        {
          [cell setHighlighted: NO];
        }
      [cell drawWithFrame: drawingRect
                           inView: tableHeaderView];
      drawingRect.origin.x += width;
    }
  else
    {
      column = [columns objectAtIndex: lastColumnToDraw];
      width = [column width];
      drawingRect.size.width = width;
      cell = [column headerCell];
      if ((column == highlightedTableColumn)
          || [tableView isColumnSelected: lastColumnToDraw])
        {
          [cell setHighlighted: YES];
        }
      else
        {
          [cell setHighlighted: NO];
        }
      [cell drawWithFrame: drawingRect
                           inView: tableHeaderView];
      drawingRect.origin.x += width;
    }

  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView"];
  [[GGPainter fromGdkColor: widget->style->dark[GTK_STATE_NORMAL]] set];
  NSFrameRect(aRect);
}
@end
