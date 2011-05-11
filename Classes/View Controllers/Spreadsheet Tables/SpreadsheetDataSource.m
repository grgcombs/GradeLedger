//
//  SpreadsheetDataSource.m
//  GradeLedger
//
//  Created by Gregory Combs on 5/1/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "SpreadsheetDataSource.h"
#import "SpreadsheetFieldEditor.h"
#import "SpreadsheetTableView.h"

@implementation SpreadsheetDataSource

@synthesize sheetTable;
@synthesize myFieldEditor;


- (id)init
{
    self = [super init];
    if(self)
    {

    }
    return self;
}

- (void)dealloc {
	
	if (myFieldEditor) [myFieldEditor release];
	[super dealloc];

}

- (NSTextView*) tableFieldEditor {
	if (!myFieldEditor)
	{
		myFieldEditor = [[SpreadsheetFieldEditor alloc] init];
		[myFieldEditor setTheTable:sheetTable];
	}
	return myFieldEditor;
}

- (void)updateEditingCell
{
	[sheetTable updateLastRowAndCol];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return (aTableView == sheetTable || [sheetTable selectedRow] == rowIndex);
}



@end
