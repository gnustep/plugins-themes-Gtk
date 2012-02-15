#include <AppKit/AppKit.h>
#include <AppKit/NSTabView.h>
#include <GNUstepGUI/GSTheme.h>
#include "GGPainter.h"
#include "GGnomeTheme.h"

@interface NSTableView (GGnomePrivate)
- (float *) _columnOrigins;
- (void) _willDisplayCell: (NSCell*)cell
	   forTableColumn: (NSTableColumn *)tb
		      row: (int)index;
@end

@implementation GGnomeTheme (NSTableView)
- (void) drawTableViewBackgroundInClipRect: (NSRect)clipRect
				    inView: (NSView *)view
		       withBackgroundColor: (NSColor *)backgroundColor
{
  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView"];
  gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(widget), TRUE);

  NSImage *img = [painter paintFlatBox: widget
                              withPart: "cell_even"
                               andSize: clipRect
                              withClip: NSZeroRect
                            usingState: GTK_STATE_NORMAL
                                shadow: GTK_SHADOW_NONE
                                 style: widget->style];

  [painter drawAndReleaseImage: img inFrame: clipRect flipped: NO];
} 

- (void) drawTableViewGridInClipRect: (NSRect)aRect
			      inView: (NSView *)view
{
  float minX = NSMinX (aRect);
  float maxX = NSMaxX (aRect);
  float minY = NSMinY (aRect);
  float maxY = NSMaxY (aRect);
  int i;
  float x_pos;
  int startingColumn; 
  int endingColumn;
  NSRect bounds = [view bounds];
  NSTableView *tableView = (NSTableView *)view;
  NSGraphicsContext *ctxt = GSCurrentContext ();
  float position;
  int numberOfColumns = [tableView numberOfColumns];
  int startingRow    = [tableView rowAtPoint: 
			       NSMakePoint (bounds.origin.x, minY)];
  int endingRow      = [tableView rowAtPoint: 
			       NSMakePoint (bounds.origin.x, maxY)];

  /* Using columnAtPoint:, rowAtPoint: here calls them only twice 

     per drawn rect */
  x_pos = minX;
  i = 0;
  float *columnOrigins = [tableView _columnOrigins];
  NSColor *gridColor = [tableView gridColor];
  int numberOfRows = [tableView numberOfRows];
  int rowHeight = [tableView rowHeight];

  while ((i < numberOfColumns) && (x_pos > columnOrigins[i]))
    {
      i++;
    }
  startingColumn = (i - 1);

  x_pos = maxX;
  // Nota Bene: we do *not* reset i
  while ((i < numberOfColumns) && (x_pos > columnOrigins[i]))
    {
      i++;
    }
  endingColumn = (i - 1);

  if (endingColumn == -1)
    endingColumn = numberOfColumns - 1;
  /*
  int startingColumn = [tableView columnAtPoint: 
			       NSMakePoint (minX, bounds.origin.y)];
  int endingColumn   = [tableView columnAtPoint: 
			       NSMakePoint (maxX, bounds.origin.y)];
  */

  DPSgsave (ctxt);
  DPSsetlinewidth (ctxt, 1);
  [gridColor set];


  GGPainter *painter = [GGPainter instance];
  GtkWidget *widget = [GGPainter getWidget: @"GtkTreeView"];
  gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(widget), TRUE);

  NSRect image_rect = NSMakeRect(0, 0, maxX - minX, rowHeight);

  NSImage *even_row_image = [painter paintFlatBox: widget
                                         withPart: "cell_even_ruled"
                                          andSize: image_rect
                                         withClip: NSZeroRect
                                       usingState: GTK_STATE_NORMAL
                                           shadow: GTK_SHADOW_NONE
                                             style: widget->style];

  NSImage *odd_row_image = [painter paintFlatBox: widget
                                        withPart: "cell_odd_ruled"
                                         andSize: image_rect
                                        withClip: NSZeroRect
                                      usingState: GTK_STATE_NORMAL
                                          shadow: GTK_SHADOW_NONE
                                            style: widget->style];
  if (numberOfRows > 0)
    {
      /* Draw rows */
      if (startingRow == -1)
	startingRow = 0;
      if (endingRow == -1)
	endingRow = numberOfRows - 1;
      
      position = bounds.origin.y;
      position += startingRow * rowHeight;
      for (i = startingRow; i <= endingRow + 1; i++)
	{
          NSRect r = NSMakeRect(minX, position, maxX - minX, rowHeight);

          if (i%2 == 0)
            [even_row_image drawInRect: r fromRect: image_rect operation: NSCompositeSourceOver fraction: 1.0];
          else
            [odd_row_image drawInRect: r fromRect: image_rect operation: NSCompositeSourceOver fraction: 1.0];

	  position += rowHeight;
	}
    }

  RELEASE(even_row_image);
  RELEASE(odd_row_image);

  gint line_width;
  gint8 *dash_list;
  float dash_list_float[2];
  GdkGCValues lineGCValues;
  NSArray *tableColumns = [tableView tableColumns];

  gdk_gc_get_values(&widget->style->black_gc[GTK_STATE_NORMAL], &lineGCValues);
  // NSColor *lineColor = [GGPainter fromGdkColor: lineGCValues.background];

  gtk_widget_style_get (widget,
                        "grid-line-width", &line_width,
                        "grid-line-pattern", (gchar *)&dash_list,
                        NULL);
  dash_list_float[0] = (float) dash_list[0];
  dash_list_float[1] = (float) dash_list[1];

  [gridColor set];
  
  DPSsetlinewidth(ctxt, (float) line_width);
  DPSsetdash(ctxt, dash_list_float, 2, 0);
  
  if (numberOfColumns > 0)
    {
      int lastRowPosition = position - rowHeight;
      /* Draw vertical lines */
      if (startingColumn == -1)
	startingColumn = 0;
      if (endingColumn == -1)
	endingColumn = numberOfColumns - 1;

      for (i = startingColumn; i <= endingColumn; i++)
	{
	  DPSmoveto (ctxt, columnOrigins[i], minY);
	  DPSlineto (ctxt, columnOrigins[i], lastRowPosition);
	  DPSstroke (ctxt);
	}
      position =  columnOrigins[endingColumn];
      position += [[tableColumns objectAtIndex: endingColumn] width];  
      /* Last vertical line must moved a pixel to the left */
      if (endingColumn == (numberOfColumns - 1))
	position -= 1;
      DPSmoveto (ctxt, position, minY);
      DPSlineto (ctxt, position, lastRowPosition);
      DPSstroke (ctxt);
    }

  DPSgrestore (ctxt);
}


- (void) highlightTableViewSelectionInClipRect: (NSRect)clipRect
					inView: (NSView *)view
			      selectingColumns: (BOOL)selectingColumns
{
  NSTableView *tableView = (NSTableView *)view;
  //int numberOfRows = [tableView numberOfRows];
  int numberOfColumns = [tableView numberOfColumns];

  if (selectingColumns == NO)
    {
      int selectedRowsCount;
      int row;
      int startingRow, endingRow;
      
      GGPainter *painter = [GGPainter instance];
      GtkWidget *widget  = [GGPainter getWidget: @"GtkTreeView"];
      int numberOfRows = [tableView numberOfRows];
      selectedRowsCount = [[tableView selectedRowIndexes] count];

      if (selectedRowsCount == 0)
	return;
      
      /* highlight selected rows */
      startingRow = [tableView rowAtPoint: NSMakePoint(0, NSMinY(clipRect))];
      endingRow   = [tableView rowAtPoint: NSMakePoint(0, NSMaxY(clipRect))];
      
      if (startingRow == -1)
	startingRow = 0;
      if (endingRow == -1)
	endingRow = numberOfRows - 1;
      
      row = [[tableView selectedRowIndexes] indexGreaterThanOrEqualToIndex: startingRow];
      while ((row != NSNotFound) && (row <= endingRow))
	{          
          NSRect rowRect = [tableView rectOfRow: row];

          NSImage *img = [painter paintFocus: widget
                                    withPart: "treeview"
                                     andSize: rowRect
                                  usingState: GTK_STATE_NORMAL
                                       style: widget->style];

          [painter drawAndReleaseImage: img inFrame: rowRect flipped: YES];

	  //NSRectFill(NSIntersectionRect([tableView rectOfRow: row], clipRect));
	  row = [[tableView selectedRowIndexes] indexGreaterThanIndex: row];
	}	  
    }
  else // Selecting columns
    {
      unsigned int selectedColumnsCount;
      unsigned int column;
      int startingColumn, endingColumn;
      
      selectedColumnsCount = [[tableView selectedColumnIndexes] count];
      
      if (selectedColumnsCount == 0)
	return;
      
      /* highlight selected columns */
      startingColumn = [tableView columnAtPoint: NSMakePoint(NSMinX(clipRect), 0)];
      endingColumn = [tableView columnAtPoint: NSMakePoint(NSMaxX(clipRect), 0)];

      if (startingColumn == -1)
	startingColumn = 0;
      if (endingColumn == -1)
	endingColumn = numberOfColumns - 1;

      column = [[tableView selectedColumnIndexes] indexGreaterThanOrEqualToIndex: startingColumn];
      while ((column != NSNotFound) && (column <= endingColumn))
	{
	  NSHighlightRect(NSIntersectionRect([tableView rectOfColumn: column],
					     clipRect));
	  column = [[tableView selectedColumnIndexes] indexGreaterThanIndex: column];
	}	  
    }
}

- (void) drawTableViewRect: (NSRect)aRect
		    inView: (NSView *)view
{
  int startingRow;
  int endingRow;
  int i;
  NSTableView *tableView = (NSTableView *)view;
  int numberOfRows = [tableView numberOfRows];
  int numberOfColumns = [tableView numberOfColumns];
  BOOL drawsGrid = [tableView drawsGrid];
  NSRect bounds = [view bounds];

  /* Draw background */
  [tableView drawBackgroundInClipRect: aRect];

  if ((numberOfRows == 0) || (numberOfColumns == 0))
    {
      return;
    }

  /* Draw grid */
  if (drawsGrid)
    {
      [tableView drawGridInClipRect: aRect];
    }

  /* Draw selection */
  [tableView highlightSelectionInClipRect: aRect];
  
  /* Draw visible cells */
  /* Using rowAtPoint: here calls them only twice per drawn rect */
  startingRow = [tableView rowAtPoint: NSMakePoint (0, NSMinY (aRect))];
  endingRow   = [tableView rowAtPoint: NSMakePoint (0, NSMaxY (aRect))];

  if (startingRow == -1)
    {
      startingRow = 0;
    }
  if (endingRow == -1)
    {
      endingRow = numberOfRows - 1;
    }
  //  NSLog(@"drawRect : %d-%d", startingRow, endingRow);
  {
    SEL sel = @selector(drawRow:clipRect:);
    IMP imp = [tableView methodForSelector: sel];
    
    for (i = startingRow; i <= endingRow; i++)
      {
        (*imp)(tableView, sel, i, aRect);
      }
  }
  
  // paint frame around table view like in Gtk+
  GtkWidget *widget  = [GGPainter getWidget: @"GtkTreeView"];
  [[GGPainter fromGdkColor: widget->style->dark[GTK_STATE_NORMAL]] set];
  NSFrameRect(bounds);
}

- (void) drawTableViewRow: (int)rowIndex 
		 clipRect: (NSRect)clipRect
		   inView: (NSView *)view
{
  NSTableView *tableView = (NSTableView *)view;
  int startingColumn; 
  int endingColumn;
  NSTableColumn *tb;
  NSRect drawingRect;
  NSCell *cell;
  int i;
  float x_pos;
  id dataSource = [tableView dataSource];
  NSArray *tableColumns = [tableView tableColumns];
  // int numberOfRows = [tableView numberOfRows];
  int numberOfColumns = [tableView numberOfColumns];
  float *columnOrigins = [tableView _columnOrigins];
  int editedRow = [tableView editedRow];
  int editedColumn = [tableView editedColumn];

  if (dataSource == nil)
    {
      return;
    }

  /* Using columnAtPoint: here would make it called twice per row per drawn 
     rect - so we avoid it and do it natively */

  /* Determine starting column as fast as possible */
  x_pos = NSMinX (clipRect);
  i = 0;
  while ((i < numberOfColumns) && (x_pos > columnOrigins[i]))
    {
      i++;
    }
  startingColumn = (i - 1);

  if (startingColumn == -1)
    startingColumn = 0;

  /* Determine ending column as fast as possible */
  x_pos = NSMaxX (clipRect);
  // Nota Bene: we do *not* reset i
  while ((i < numberOfColumns) && (x_pos > columnOrigins[i]))
    {
      i++;
    }
  endingColumn = (i - 1);

  if (endingColumn == -1)
    endingColumn = numberOfColumns - 1;

  /* Draw the row between startingColumn and endingColumn */
  for (i = startingColumn; i <= endingColumn; i++)
    {
      if (i != editedColumn || rowIndex != editedRow)
	{
	  tb = [tableColumns objectAtIndex: i];
	  cell = [tb dataCellForRow: rowIndex];
	  [tableView _willDisplayCell: cell
		forTableColumn: tb
		row: rowIndex];
	  [cell setObjectValue: [dataSource tableView: tableView
					     objectValueForTableColumn: tb
					     row: rowIndex]]; 
	  drawingRect = [tableView frameOfCellAtColumn: i
			      row: rowIndex];
	  [cell drawWithFrame: drawingRect inView: tableView];
	}
    }
}
@end
