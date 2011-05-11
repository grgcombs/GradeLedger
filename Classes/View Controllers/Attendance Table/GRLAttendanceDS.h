//
//  GRLAttendanceDS.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "SpreadsheetDataSource.h"

@class DateHeaderController, GRLDatabase, DocumentPreferences;
@interface GRLAttendanceDS : SpreadsheetDataSource 
{
    IBOutlet NSTableView *nameTable;
    IBOutlet DateHeaderController *headerTableDS;
	
	IBOutlet GRLDatabase *data;
	IBOutlet DocumentPreferences *prefs;
}

- (void)resizeAssViewToFit;
- (void)reloadTableData;
- (IBAction)refreshCalendar:(id)sender;

@property (retain) NSTableView *nameTable;
@property (retain) DateHeaderController *headerTableDS;
@property (retain) GRLDatabase *data;
@property (retain) DocumentPreferences *prefs;
@end
