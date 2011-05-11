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
	IBOutlet GRLDatabase *database;
}

- (IBAction) reloadTableData;


@property (nonatomic, assign) GRLDatabase *database;
@property (nonatomic, assign) NSTableView *headerTableView;

@end
