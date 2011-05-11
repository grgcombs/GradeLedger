//
//  SpreadsheetFieldEditor.h
//  GradeLedger
//
//  Created by Gregory Combs on 4/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//


@interface SpreadsheetFieldEditor : NSTextView {

	IBOutlet NSTableView *theTable;
	
}

- (void) keyDown:(NSEvent *) event;

@property (retain) NSTableView *theTable;


@end
