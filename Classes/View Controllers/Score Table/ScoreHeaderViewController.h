//
//  ScoreHeaderViewController.h
//  GradeLedger
//
//  Created by Gregory Combs on 5/10/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

@class SpreadsheetTableView;
@class GRLDatabase;

@interface ScoreHeaderViewController : NSObject <NSTableViewDataSource>
{
	IBOutlet NSTableView *headerTableView;
	//IBOutlet SpreadsheetTableView *mainTableView;
	IBOutlet GRLDatabase *database;
    NSMutableArray *toolTipArray;
}

- (IBAction) reloadTableData;


@property (retain) NSMutableArray *toolTipArray;
@property (retain) GRLDatabase *database;
//@property (retain) SpreadsheetTableView *mainTableView;
@property (retain) NSTableView *headerTableView;

@end
