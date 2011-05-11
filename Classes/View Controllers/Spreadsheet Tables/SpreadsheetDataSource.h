//
//  SpreadsheetDataSource.h
//  GradeLedger
//
//  Created by Gregory Combs on 5/1/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

@class SpreadsheetFieldEditor;
@class SpreadsheetTableView;

@interface SpreadsheetDataSource : NSObject <NSTableViewDelegate> {
	IBOutlet SpreadsheetFieldEditor	*myFieldEditor;
	IBOutlet SpreadsheetTableView		*sheetTable;


}

- (NSTextView *)tableFieldEditor;
- (void)updateEditingCell;
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex;


@property (retain) SpreadsheetFieldEditor *myFieldEditor;
@property (retain) SpreadsheetTableView *sheetTable;

@end
