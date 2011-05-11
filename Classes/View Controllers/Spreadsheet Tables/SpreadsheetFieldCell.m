//
//  SpreadsheetFieldCell.m
//
//  Created by Gregory Combs on 4/29/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "SpreadsheetFieldCell.h"
#import "SpreadsheetTableView.h"
#import "GRLScoreDS.h"

@implementation SpreadsheetFieldCell

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
   return nil;
}

- (NSTextView *)fieldEditorForView:(NSView *)aControlView {	
	if ([aControlView isKindOfClass:[SpreadsheetTableView class]]) { 
		SpreadsheetDataSource *dataSource = [(SpreadsheetTableView *)aControlView delegate];
		
		return [dataSource tableFieldEditor];
	}
	else
		return [super fieldEditorForView:aControlView];
}

@end
