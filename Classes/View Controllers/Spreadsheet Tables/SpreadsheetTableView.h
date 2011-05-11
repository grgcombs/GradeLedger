//
//  SpreadsheetTableView.h


@interface SpreadsheetTableView : NSTableView 
{
	NSInteger lastRow;
	NSInteger lastCol;
}

- (void)getLastRow:(NSInteger *)row column:(NSInteger *)col;
- (void)updateLastRowAndCol;
- (BOOL)validateLastRowAndCol;

@property NSInteger lastRow;
@property NSInteger lastCol;
@end
