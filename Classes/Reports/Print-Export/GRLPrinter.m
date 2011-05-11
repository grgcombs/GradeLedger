//
//  GRLPrinter.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLPrinter.h"
#import "DocumentPreferences.h"

#import "StudentObj.h"
#import "AssignmentObj.h"
#import "CategoryObj.h"
#import "ScoreObj.h"
#import "DateUtils.h"

#import "LetterGradeLookup.h"
#import "GRLDatabase.h"

#import "GRLTextObject.h"
#import "GRLRotatedTextObject.h"
#import "GRLPathObject.h"
#import "GRLGrayBox.h"
#import "GRLTextView.h"

@implementation GRLPrinter

- (id)init
{
	self = [super init];
	if(self)
	{
		win = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,0,0) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
		[win setReleasedWhenClosed:NO];
		textView = [[[GRLTextView alloc] initWithFrame:NSMakeRect(0,0,0,0)] autorelease];
		[[win contentView] addSubview:textView];
		
	}
	return self;
}

- (void)dealloc
{
	[textView removeFromSuperview];
	if (win) [win release];
	[super dealloc];
}

- (void)populateMenus
{
	NSString *lastSelectedStart;
	NSString *lastSelectedStop;
	
	lastSelectedStart = [[startStud titleOfSelectedItem] retain];
	lastSelectedStop = [[stopStud titleOfSelectedItem] retain];
	
	[startStud removeAllItems];
	[stopStud removeAllItems];
	
	[progress setDoubleValue:0];
	
	
	for(StudentObj *aStud in [self.data.studentController arrangedObjects])
	{
		NSString *tit = [aStud name];
		
		while([startStud indexOfItemWithTitle:tit] != -1)
			tit = [NSString stringWithFormat:@"%@ ",tit];
		[startStud addItemWithTitle:tit];
		
		tit = [aStud name];
		
		while([stopStud indexOfItemWithTitle:tit] != -1)
			tit = [NSString stringWithFormat:@"%@ ",tit];
		[stopStud addItemWithTitle:tit];
	}
	
	[startStud selectItemAtIndex:0];
	[stopStud selectItemAtIndex:[stopStud numberOfItems]-1];
	
	if(lastSelectedStart && [startStud indexOfItemWithTitle:lastSelectedStart] != -1)
		[startStud selectItemWithTitle:lastSelectedStart];
	if(lastSelectedStop && [stopStud indexOfItemWithTitle:lastSelectedStop] != -1)
		[stopStud selectItemWithTitle:lastSelectedStop];
	
	if (lastSelectedStart) [lastSelectedStart release];
	if (lastSelectedStop) [lastSelectedStop release];
	
	lastSelectedStart = [[startAss titleOfSelectedItem] retain];
	lastSelectedStop = [[stopAss titleOfSelectedItem] retain];
	
	[startAss removeAllItems];
	[stopAss removeAllItems];
	
	for(AssignmentObj *ass in [self.data allAssignmentsSortedByDueDate])
	{
		NSString *tit = [ass name];
		
		while([startAss indexOfItemWithTitle:tit] != -1)
			tit = [NSString stringWithFormat:@"%@ ",tit];
		[startAss addItemWithTitle:tit];
		
		tit = [ass name];
		
		while([stopAss indexOfItemWithTitle:tit] != -1)
			tit = [NSString stringWithFormat:@"%@ ",tit];
		[stopAss addItemWithTitle:tit];
	}
	
	[startAss selectItemAtIndex:0];
	[stopAss selectItemAtIndex:[stopAss numberOfItems]-1];
	
	if(lastSelectedStart && [startAss indexOfItemWithTitle:lastSelectedStart] != -1)
		[startAss selectItemWithTitle:lastSelectedStart];
	if(lastSelectedStop && [stopAss indexOfItemWithTitle:lastSelectedStop] != -1)
		[stopAss selectItemWithTitle:lastSelectedStop];
	
	if (lastSelectedStart) [lastSelectedStart release], lastSelectedStart = nil;
	if (lastSelectedStop) [lastSelectedStop release], lastSelectedStop = nil;
	
	NSMenuItem *item;
	NSMutableArray *pastCategories = [NSMutableArray array];
	
	for(item in [categoriesButton itemArray])
		if([item state] == NSOnState)
			[pastCategories addObject:[item title]];
	
	[categoriesButton removeAllItems];
	[categoriesButton addItemWithTitle:@"category"];
	
	for(CategoryObj *cat in [self.data allCategoriesSortedByName])
	{
		NSString *tit = [cat name];
		
		while([categoriesButton indexOfItemWithTitle:tit] != -1)
			tit = [NSString stringWithFormat:@"%@ ",tit];
		[categoriesButton addItemWithTitle:tit];
	}
	
	for(item in [categoriesButton itemArray])
		if([pastCategories indexOfObject:[item title]] != NSNotFound)
			[item setState:NSOnState];
}

- (void) awakeFromNib
{
	[progress setUsesThreadedAnimation:YES];
	
	if([[self.data.studentController arrangedObjects] count] && [[self.data.assignmentController arrangedObjects] count])
		[self populateMenus];
	
}

- (NSDictionary *)printingSettings
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSString *temp;
	
	[dict setObject:[NSNumber numberWithInteger:[studentMatrix selectedRow]] forKey:@"studentMatrix"];
	if((temp = [startStud titleOfSelectedItem]))
		[dict setObject:temp forKey:@"startStud"];
	if((temp = [stopStud titleOfSelectedItem]))
		[dict setObject:temp forKey:@"stopStud"];
	
	if([(temp = [belowScore stringValue]) length])
		[dict setObject:temp forKey:@"belowScore"];
	
	[dict setObject:[NSNumber numberWithInteger:[assMatrix selectedRow]] forKey:@"assMatrix"];
	if((temp = [startAss titleOfSelectedItem]))
		[dict setObject:temp forKey:@"startAss"];
	if((temp = [stopAss titleOfSelectedItem]))
		[dict setObject:temp forKey:@"stopAss"];
	
	NSMutableArray *selectedCats = [NSMutableArray array];
	NSMenuItem *next;
	for(next in [categoriesButton itemArray])
		if([next state] == NSOnState)
			[selectedCats addObject:[next title]];
	[dict setObject:selectedCats forKey:@"categoriesButton"];
	
	[dict setObject:[NSNumber numberWithInteger:[indivVsGroupMatrix selectedRow]] forKey:@"indivVsGroupMatrix"];
	NSMutableArray *selectedOptions = [NSMutableArray array];
	
	for(next in [optionsButton itemArray])
		if([next state] == NSOnState)
			[selectedOptions addObject:[next title]];
	[dict setObject:selectedOptions forKey:@"optionsButton"];
	
	return dict;
}

- (void)setPrintingSettings:(NSDictionary *)dict
{
	NSString *obj;
	NSNumber *num;
	
	if((num = [dict objectForKey:@"studentMatrix"]))
		[studentMatrix selectCellAtRow:[num integerValue] column:0];
	if((obj = [dict objectForKey:@"startStud"]) && [startStud indexOfItemWithTitle:obj]!=-1)
		[startStud selectItemWithTitle:obj];
	if((obj = [dict objectForKey:@"stopStud"]) && [stopStud indexOfItemWithTitle:obj]!=-1)
		[stopStud selectItemWithTitle:obj];
	
	if([(obj = [dict objectForKey:@"belowScore"]) length])
		[belowScore setStringValue:obj];
	
	if((num = [dict objectForKey:@"assMatrix"]))
		[assMatrix selectCellAtRow:[num integerValue] column:0];
	if((obj = [dict objectForKey:@"startAss"]) && [startAss indexOfItemWithTitle:obj]!=-1)
		[startAss selectItemWithTitle:obj];
	if((obj = [dict objectForKey:@"stopAss"]) && [stopAss indexOfItemWithTitle:obj]!=-1)
		[stopAss selectItemWithTitle:obj];
	
	NSMutableArray *selectedCats = [dict objectForKey:@"categoriesButton"];
	NSMenuItem *next;
	
	for(next in [categoriesButton itemArray])
		if([selectedCats indexOfObject:[next title]] != NSNotFound)
			[next setState:NSOnState];
	
	if((num = [dict objectForKey:@"indivVsGroupMatrix"]))
		[indivVsGroupMatrix selectCellAtRow:[num integerValue] column:0];
	NSMutableArray *selectedOptions = [dict objectForKey:@"optionsButton"];
	
	for(next in [optionsButton itemArray])
		if([selectedOptions indexOfObject:[next title]] != NSNotFound)
			[next setState:NSOnState];
}

- (void)runGradeReportPrintDialogue
{
	[self populateMenus];
	
	[NSApp beginSheet:printWindow
	   modalForWindow:docWindow
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
	
	NSInteger res = [NSApp runModalForWindow:printWindow];
	
	if(res == NSOKButton)
	{
		
		NSArray *textArray = nil;
		NSInteger pageCount = 0;
		
		NSMutableArray *studs;
		if([studentMatrix selectedRow] == 0)
			studs = [self.data.studentController arrangedObjects];
		else if([studentMatrix selectedRow] == 1)
		{
			NSInteger index = [startStud indexOfSelectedItem];
			NSInteger length = [stopStud indexOfSelectedItem] + 1;
			
			studs = [NSMutableArray arrayWithArray:[[self.data.studentController arrangedObjects] subarrayWithRange:NSMakeRange(index,length)]];
		}
		else
		{
			CGFloat score = [belowScore doubleValue];
			studs = [NSMutableArray array];
			
			for(StudentObj *stud in [self.data.studentController arrangedObjects])
				if([stud.gradeTotal doubleValue] < score)
					[studs addObject:stud];
		}
		
		textArray = [NSMutableArray array];
		
		if([indivVsGroupMatrix selectedRow] == 0)
		{
			
			NSInteger options = 0;
			NSInteger i = 1;
			
			NSEnumerator *itemEnum = [[optionsButton itemArray] objectEnumerator];
			NSMenuItem *item;
			
			[itemEnum nextObject];
			while((item = [itemEnum nextObject]))
			{
				if([item state])
					options += i;
				i *= 2;
			}
			
			textArray = [textArray arrayByAddingObjectsFromArray:[self individualReportsForStudents:studs printerInfo:[NSPrintInfo sharedPrintInfo] options:options pageCount:&pageCount]];
		}
		else
		{
			[progress setIndeterminate:YES];
			[progress startAnimation:nil];
			
			textArray = [textArray arrayByAddingObjectsFromArray:[self groupReportForStudents:studs printerInfo:[NSPrintInfo sharedPrintInfo] printCount:&pageCount]];
			
			[progress stopAnimation:nil];
			[progress setIndeterminate:NO];
		}
		
		[NSApp endSheet:printWindow];
		[printWindow orderOut:self];
		
		NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
		NSSize size = [info paperSize];
		size.width -= ([info leftMargin] + [info rightMargin]);
		size.height -= ([info topMargin] + [info bottomMargin]);
		
		size.height *= pageCount;
		
		[win setFrame:NSMakeRect(0,0,size.width,size.height) display:YES];
		[textView setFrame:NSMakeRect(0,0,size.width,size.height)];
		
		[textView setTextObjects:textArray];
		[textView setPageCount:pageCount];
		
		[textView print:nil];
	}
	else
	{
		[NSApp endSheet:printWindow];
		[printWindow orderOut:self];
	}
}

- (IBAction)confirmPrint:(id)sender
{
	[NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)cancelPrint:(id)sender
{
	[NSApp stopModalWithCode:NSCancelButton];
}

- (IBAction)changeFirstStudent:(id)sender
{
	NSInteger index = [startStud indexOfSelectedItem];
	
	NSEnumerator *studentEnum = [[self.data.studentController arrangedObjects] objectEnumerator];
	StudentObj *aStud;
	[stopStud removeAllItems];
	
	while(index > 0)
	{
		[studentEnum nextObject];
		index--;
	}
	
	while((aStud = [studentEnum nextObject]))
	{
		NSString *tit = [aStud name];
		
		while([stopStud indexOfItemWithTitle:tit] != -1)
			tit = [NSString stringWithFormat:@"%@ ",tit];
		[stopStud addItemWithTitle:tit];
	}
	[stopStud selectItemAtIndex:[stopStud numberOfItems]-1];
}

- (IBAction)changeFirstAssignment:(id)sender
{
	NSInteger index = [startAss indexOfSelectedItem];
	
	NSEnumerator *assEnum = [[self.data allAssignmentsSortedByDueDate] objectEnumerator];
	AssignmentObj *ass;
	[stopAss removeAllItems];
	
	while(index > 0)
	{
		[assEnum nextObject];
		index--;
	}
	
	while((ass = [assEnum nextObject]))
	{
		NSString *tit = [ass name];
		
		while([stopAss indexOfItemWithTitle:tit] != -1)
			tit = [NSString stringWithFormat:@"%@ ",tit];
		[stopAss addItemWithTitle:tit];
	}
	
	[stopAss selectItemAtIndex:[stopAss numberOfItems]-1];
}

- (IBAction)toggleOption:(id)sender
{
	[[sender selectedItem] setState:![[sender selectedItem] state]];
}

- (NSArray *)individualReportsForStudents:(NSArray *)studs printerInfo:(NSPrintInfo *)printInfo options:(NSInteger)opts pageCount:(NSInteger *)pageCount
{
	[printInfo setOrientation:NSPortraitOrientation];
	
	StudentObj *stud;
	
	NSMutableArray *array = [NSMutableArray array];
	
	[progress setMaxValue:[studs count]];
	
	for(stud in studs)
	{
		[progress incrementBy:1.0];
		[progress display];
		
		[array addObjectsFromArray:[self individualReportForStudent:stud printerInfo:printInfo options:opts pageCount:pageCount]];
	}
	
	return array;
}

- (NSArray *)individualReportForStudent:(StudentObj *)stud printerInfo:(NSPrintInfo *)printInfo options:(NSInteger)opts pageCount:(NSInteger *)pageCount
{
	NSMutableArray *textObjectsArray = [NSMutableArray array];
	
	NSEnumerator *assEnum;
	
	if([assMatrix selectedRow] == 1)
		assEnum = [[NSMutableArray arrayWithArray:[[self.data allAssignmentsSortedByDueDate] subarrayWithRange:NSMakeRange([startAss indexOfSelectedItem],[stopAss indexOfSelectedItem] + 1)]] objectEnumerator];
	else
		assEnum = [[self.data allAssignmentsSortedByDueDate] objectEnumerator];
	
	AssignmentObj *ass;
	
	//data formatting... woot!
	NSSize paperSize = [printInfo paperSize];
	paperSize.width -= ([printInfo rightMargin] + [printInfo leftMargin]);
	paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
	
	NSString *assName; 		//opts & 1
	NSString *rawScore; 	//opts & 2
	NSString *adjustedScore; 	//opts & 4
	NSString *maxScore; 	//opts & 8
	NSString *code; 		//opts & 16
	NSString *categoryName; 	//opts & 32
	NSString *dueDate; 		//opts & 64
	NSString *turnedInDate; 	//opts & 128
	
	NSMutableDictionary *atr = [NSMutableDictionary dictionary];
	
	NSPoint point = NSMakePoint(1,paperSize.height);
	NSSize size = NSMakeSize(0,0);
	
	(*pageCount)++;
	
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
	
	if([temp length])
	{
		
		size = [temp sizeWithAttributes:atr];
		point.y -= size.height;
		
		[textObjectsArray addObject:[GRLTextObject textObjectWithString:temp attributes:atr rect:NSMakeRect(point.x,point.y,size.width,size.height) pageNumber:*pageCount]];
	}
	
	NSString *studentName = @"";
	
	if(self.prefs.printName)
		studentName = [stud name];
	if(self.prefs.printID)
	{
		if([studentName length])
			studentName = [NSString stringWithFormat:@"%@ (%@)",studentName,[stud studentID]];
		else
			studentName = [stud studentID];
	}
	
	point.y -= size.height;
	temp = [NSString stringWithFormat:@"Grade Report for %@",studentName];
	size = [temp sizeWithAttributes:atr];
	point.y -= size.height;
	[textObjectsArray addObject:[GRLTextObject textObjectWithString:temp attributes:atr rect:NSMakeRect(point.x,point.y,size.width,size.height) pageNumber:*pageCount]];
	
	NSString *score = stud.gradeTotal;
	temp = [NSString stringWithFormat:@"Grade: %@%% (%@)",score,[letterGrades gradeForScore:[score doubleValue]]];
	size = [temp sizeWithAttributes:atr];
	point.y -= size.height;
	[textObjectsArray addObject:[GRLTextObject textObjectWithString:temp attributes:atr rect:NSMakeRect(point.x,point.y,size.width,size.height) pageNumber:*pageCount]];
	point.y -= size.height;
	
	NSMutableArray *header = [NSMutableArray array];
	NSMutableArray *lengths = [NSMutableArray array];
	
	if(opts & 1) 
	{
		[header addObject:@"Assignment"];
		[lengths addObject:[NSNumber numberWithDouble:0.26*paperSize.width]];
	}
	if(opts & 2) 
	{
		[header addObject:@"Grade"];
		[lengths addObject:[NSNumber numberWithDouble:0.06*paperSize.width]];
	}
	if(opts & 4) 
	{
		[header addObject:@"Curve"];
		[lengths addObject:[NSNumber numberWithDouble:0.06*paperSize.width]];
	}
	if(opts & 8) 
	{
		[header addObject:@"Max"];
		[lengths addObject:[NSNumber numberWithDouble:0.06*paperSize.width]];
	}
	if(opts & 16) 
	{	
		[header addObject:@"Note"];
		[lengths addObject:[NSNumber numberWithDouble:0.06*paperSize.width]];
	}
	if(opts & 32) 
	{
		[header addObject:@"Category"];
		[lengths addObject:[NSNumber numberWithDouble:0.20*paperSize.width]];
	}
	if(opts & 64) 
	{
		[header addObject:@"Due"];
		[lengths addObject:[NSNumber numberWithDouble:0.15*paperSize.width]];
	}
	if(opts & 128) 
	{
		[header addObject:@"Collected"];
		[lengths addObject:[NSNumber numberWithDouble:0.15*paperSize.width]];
	}
	
	NSEnumerator *lengthEnum = [lengths objectEnumerator];
	
	NSString *head;
	CGFloat length = 0.0;
	
	point.y -= size.height;
	
	atr = [NSMutableDictionary dictionary];
	[atr setObject:[NSFont fontWithName:@"Geneva" size:9] forKey:NSFontAttributeName];
	[atr setObject:[NSNumber numberWithInt:1] forKey:NSUnderlineStyleAttributeName];
	
	for(head in header)
	{
		size = [head sizeWithAttributes:atr];
		[textObjectsArray addObject:[GRLTextObject textObjectWithString:head attributes:atr rect:NSMakeRect(length,point.y,size.width,size.height) pageNumber:*pageCount]];
		length += [[lengthEnum nextObject] doubleValue];
	}
	
	NSInteger count = 0;
	
	NSMutableDictionary *whiteDict = [NSMutableDictionary dictionary];
	[whiteDict setObject:[NSFont fontWithName:@"Geneva" size:9] forKey:NSFontAttributeName];
	[whiteDict setObject:[NSNumber numberWithInt:0] forKey:NSUnderlineStyleAttributeName];
	
	atr = whiteDict;
	
	while((ass = [assEnum nextObject]))
	{
		if([assMatrix selectedRow] == 2)
		{
			NSUInteger index = [[self.data allCategoriesSortedByName] indexOfObjectIdenticalTo:ass.category];
			
			if(index == NSNotFound)
				continue;
			
			if(![[categoriesButton itemAtIndex:index+1] state])
				continue;
		}
		
		point.x = 1;
		point.y -= size.height;
		
		if(point.y - size.height < 0)
		{
			(*pageCount)++;
			point = NSMakePoint(1,paperSize.height-2*size.height);
			
			lengthEnum = [lengths objectEnumerator];
			length = 0.0;
			
			atr = [NSMutableDictionary dictionary];
			[atr setObject:[NSFont fontWithName:@"Geneva" size:9] forKey:NSFontAttributeName];
			[atr setObject:[NSNumber numberWithInt:1] forKey:NSUnderlineStyleAttributeName];
			for(head in header)
			{
				size = [head sizeWithAttributes:atr];
				[textObjectsArray addObject:[GRLTextObject textObjectWithString:head attributes:atr rect:NSMakeRect(length,point.y,size.width,size.height) pageNumber:*pageCount]];
				length += [[lengthEnum nextObject] doubleValue];
			}
			
			point.y -= size.height;
			count = 0;
			
			atr = whiteDict;
		}
		
		count++;
		if(count % 2 == 0)
		{
			if(![[self.prefs valueForKey:@"printGrid"]boolValue]) {
				[textObjectsArray addObject:[GRLGrayBox pathObjectWithRect:NSMakeRect(0,point.y-size.height,paperSize.width,size.height) pageNumber:*pageCount]];
			}
			else {
				[textObjectsArray addObject:[GRLPathObject pathObjectWithRect:NSMakeRect(0,point.y-size.height,paperSize.width,size.height) pageNumber:*pageCount]];
			}
		}
		
		ScoreObj *score = [stud scoreForAssignment:ass];
		NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
		
		lengthEnum = [lengths objectEnumerator];
		NSInteger len;
		
		if(opts & 1)
		{
			assName = [ass name];
			len = [[lengthEnum nextObject] integerValue];
			
			size = [assName sizeWithAttributes:atr];
			[textObjectsArray addObject:[GRLTextObject textObjectWithString:assName attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			
			point.x += len;
		}
		
		if(opts & 2)
		{
			rawScore = [dict objectForKey:@"raw"];
			len = [[lengthEnum nextObject] integerValue];
			if(rawScore)
			{
				size = [rawScore sizeWithAttributes:atr];
				[textObjectsArray addObject:[GRLTextObject textObjectWithString:rawScore attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			}
			
			point.x += len;
		}
		
		if(opts & 4)
		{    
			rawScore = [dict objectForKey:@"raw"];
			adjustedScore = [dict objectForKey:@"curved"];
			len = [[lengthEnum nextObject] integerValue];
			if(![adjustedScore isEqualToString:rawScore])
			{
				size = [adjustedScore sizeWithAttributes:atr];
				[textObjectsArray addObject:[GRLTextObject textObjectWithString:adjustedScore attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			}
			
			point.x += len;
		}
		
		if(opts & 8)
		{
			maxScore = [NSString stringWithFormat:@"%d",[[ass maxPoints] integerValue]];
			
			len = [[lengthEnum nextObject] integerValue];
			
			size = [maxScore sizeWithAttributes:atr];
			[textObjectsArray addObject:[GRLTextObject textObjectWithString:maxScore attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			
			point.x += len;
		}
		
		if(opts & 16)
		{
			ScoreObj *score = [stud scoreForAssignment:ass];
			code = [score abbreviatedCollectionString];
			len = [[lengthEnum nextObject] integerValue];
			if(code)
			{
				size = [code sizeWithAttributes:atr];
				[textObjectsArray addObject:[GRLTextObject textObjectWithString:code attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			}
			
			point.x += len;
		}
		
		if(opts & 32)
		{
			CategoryObj *tempCat = ass.category;
			
			NSMutableString *catString = [NSMutableString stringWithFormat:@"%@ (%d%%)", [tempCat name], [tempCat.percentOfFinalScore integerValue]];
			categoryName = catString;
			
			len = [[lengthEnum nextObject] integerValue];
			if(categoryName)
			{
				size = [categoryName sizeWithAttributes:atr];
				[textObjectsArray addObject:[GRLTextObject textObjectWithString:categoryName attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			}
			
			point.x += len;
		}
		
		if(opts & 64)
		{
			dueDate = [DateUtils stringFromDate:[ass dueDate] withFormat:kGRLDateShortFormat];
			len = [[lengthEnum nextObject] integerValue];
			if(dueDate)
			{
				size = [dueDate sizeWithAttributes:atr];
				[textObjectsArray addObject:[GRLTextObject textObjectWithString:dueDate attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			}
			
			point.x += len;
		}
		
		if(opts & 128)
		{
			ScoreObj *score = [stud scoreForAssignment:ass];
			turnedInDate = [DateUtils stringFromDate:score.collectionDate withFormat:kGRLDateShortFormat];
			len = [[lengthEnum nextObject] integerValue];
			if(turnedInDate)
			{
				size = [turnedInDate sizeWithAttributes:atr];
				[textObjectsArray addObject:[GRLTextObject textObjectWithString:turnedInDate attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
			}
			
			point.x += len;
		}
		
	}
	
	return textObjectsArray;
}

- (NSArray *)groupReportForStudents:(NSArray *)studs printerInfo:(NSPrintInfo *)printInfo printCount:(NSInteger *)printCount
{
	BOOL printGrid = [[self.prefs valueForKey:@"printGrid"] boolValue];
	[printInfo setOrientation:NSLandscapeOrientation];
	
	NSMutableArray *textObjects = [NSMutableArray array];
	
	NSSize paperSize = [printInfo paperSize];
	paperSize.width -= ([printInfo rightMargin] + [printInfo leftMargin]);
	paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
	
	StudentObj *stud;
	
	NSMutableArray *leftOverStudents = [NSMutableArray array];
	NSMutableArray *activeStudents = [NSMutableArray array];
	
	NSPoint point = NSMakePoint(1,paperSize.height*0.70);
	NSSize size;
	
	NSMutableDictionary *whiteDict = [NSMutableDictionary dictionary];
	[whiteDict setObject:[NSFont fontWithName:@"Geneva" size:9] forKey:NSFontAttributeName];
	[whiteDict setObject:[NSNumber numberWithInt:0] forKey:NSUnderlineStyleAttributeName];
	
	NSMutableDictionary *colorDict = nil;
	
	(*printCount)++;
	
	NSInteger count = 0;
	
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
	if([temp length])
		[textObjects addObject:[GRLTextObject textObjectWithString:temp attributes:whiteDict rect:NSMakeRect(0,paperSize.height*0.70,paperSize.width*0.25,paperSize.height*0.30) pageNumber:*printCount]];
	
	for(stud in studs)
	{
		if([leftOverStudents count])
			[leftOverStudents addObject:stud];
		else
		{
			//draw as many students as possible
			NSString *name = @"";
			
			if(self.prefs.printName)
				name = [stud name];
			if(self.prefs.printID)
			{
				if([name length])
					name = [NSString stringWithFormat:@"%@ %@",[stud studentID],name];
				else
					name = [stud studentID];
			}
			
			size = [name sizeWithAttributes:whiteDict];
			
			if(point.y - size.height < 0)
				[leftOverStudents addObject:stud];    
			else
			{
				count++;
				
				[activeStudents addObject:stud];
				
				[textObjects addObject:[GRLTextObject textObjectWithString:name attributes:whiteDict rect:NSMakeRect(point.x,point.y-size.height,paperSize.width*0.17,size.height) pageNumber:*printCount]];
				
				NSString *score = stud.gradeTotal;
				score = [NSString stringWithFormat:@"%@%% %@",score,[letterGrades gradeForScore:[score doubleValue]]];
				size = [score sizeWithAttributes:whiteDict];
				[textObjects addObject:[GRLTextObject textObjectWithString:score attributes:whiteDict rect:NSMakeRect(point.x+paperSize.width*0.17,point.y-size.height,paperSize.width*0.08,size.height) pageNumber:*printCount]];
				
				point.y -= size.height;
			}
		}
	}
	
	NSEnumerator *assEnum;
	
	if([assMatrix selectedRow] == 1)
		assEnum = [[NSMutableArray arrayWithArray:[[self.data allAssignmentsSortedByDueDate] subarrayWithRange:NSMakeRange([startAss indexOfSelectedItem],[stopAss indexOfSelectedItem] + 1)]] objectEnumerator];
	else
		assEnum = [[self.data allAssignmentsSortedByDueDate] objectEnumerator];
	
	AssignmentObj *ass;
	
	point = NSMakePoint(paperSize.width*0.25,paperSize.height*0.70);
	
	ass = nil;
	AssignmentObj *nextAss = [assEnum nextObject];
	
	while((ass = nextAss) != nil && ((nextAss = [assEnum nextObject]) || !nextAss))
	{
		if([assMatrix selectedRow] == 2)
		{            
			NSUInteger index = [[self.data allCategoriesSortedByName] indexOfObjectIdenticalTo:ass.category];
			
			if(index == NSNotFound)
				continue;
			
			if(![[categoriesButton itemAtIndex:index+1] state])
				continue;
		}
		
		NSString *assName = [ass name];
		
		assName = [NSString stringWithFormat:@"%d - %@",[ass.maxPoints integerValue],assName];
		
		NSSize assSize =  [assName sizeWithAttributes:whiteDict];
		
		size = assSize;
		
		if(point.x + 3*size.height > paperSize.width)
		{
			//time to move on!
			//if(printGrid)
			//   [textObjects addObject:[GRLPathObject pathObjectWithRect:NSMakeRect(paperSize.width*0.25+size.height-1,point.y-size.height,paperSize.width,size.height) pageNumber:*printCount]];
			
			(*printCount)++;
			
			NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
			NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
			if([temp length])
				[textObjects addObject:[GRLTextObject textObjectWithString:temp attributes:whiteDict rect:NSMakeRect(0,paperSize.height*0.70,paperSize.width*0.25,paperSize.height*0.30) pageNumber:*printCount]];
			
			point = NSMakePoint(1,paperSize.height*0.70);
			
			count = 0;
			for(stud in activeStudents)
			{
				NSString *name = @"";
				
				if(self.prefs.printName)
					name = [stud name];
				if(self.prefs.printID)
				{
					if([name length])
						name = [NSString stringWithFormat:@"%@ %@",[stud studentID],name];
					else
						name = [stud studentID];
				}
				
				size = [name sizeWithAttributes:whiteDict];
				
				count++; 
				
				if(count % 2 == 0)
				{
					if(!printGrid)
						[textObjects insertObject:[GRLGrayBox pathObjectWithRect:NSMakeRect(0,point.y-size.height,paperSize.width,assSize.height) pageNumber:*printCount-1] atIndex:0];
				}
				
				if(printGrid)
					[textObjects addObject:[GRLPathObject pathObjectWithRect:NSMakeRect(0,point.y-size.height,paperSize.width,assSize.height) pageNumber:*printCount-1]];
				
				[textObjects addObject:[GRLTextObject textObjectWithString:name attributes:whiteDict rect:NSMakeRect(point.x,point.y-size.height,paperSize.width*0.17,size.height) pageNumber:*printCount]];
				
				NSString *score = stud.gradeTotal;
				score = [NSString stringWithFormat:@"%@%% %@",score,[letterGrades gradeForScore:[score doubleValue]]];
				size = [score sizeWithAttributes:whiteDict];
				[textObjects addObject:[GRLTextObject textObjectWithString:score attributes:whiteDict rect:NSMakeRect(point.x+paperSize.width*0.17,point.y-size.height,paperSize.width*0.08,size.height) pageNumber:*printCount]];
				
				point.y -= size.height;
			}
			
			point = NSMakePoint(paperSize.width*0.25,paperSize.height*0.70);
			size = [assName sizeWithAttributes:whiteDict];
		}
		
		[textObjects addObject:[GRLRotatedTextObject textObjectWithString:assName attributes:whiteDict rect:NSMakeRect(point.x+2.5*size.height,paperSize.height*0.71,size.width,size.height) pageNumber:*printCount degrees:90]];
		
		
		NSInteger studCount = 0;
		
		for(stud in activeStudents)
		{
			ScoreObj *score = [stud scoreForAssignment:ass];
			NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
			
			NSString *str = [dict objectForKey:@"curved"];
			if(![str length])
			{
				str = [dict objectForKey:@"raw"];
				if(![str length])
					str = @" ";
			}
			
			NSColor *color = [score cellColorWithPrefs:self.prefs];
						
			if([str isEqualToString:@" "])
			{
				str = [score abbreviatedCollectionString];
				if(![str length])
				{
					str = @" ";
					color = nil;
				}
			}
			
			if(color)
			{
				colorDict = [NSMutableDictionary dictionary];
				[colorDict setObject:[NSFont fontWithName:@"Geneva" size:9] forKey:NSFontAttributeName];
				[colorDict setObject:[NSNumber numberWithInt:0] forKey:NSUnderlineStyleAttributeName];
				[colorDict setObject:color forKey:NSBackgroundColorAttributeName];
			}
			
			size = [str sizeWithAttributes:whiteDict];
			
			point.y -= size.height;
			
			if(str)
			{
				NSDictionary *atr;
				if(colorDict)
					atr = colorDict;
				else
					atr = whiteDict;
				
				NSInteger xOffSet = 1.5*size.height + (assSize.height - size.width)/2;
				
				[textObjects addObject:[GRLTextObject textObjectWithString:str attributes:atr rect:NSMakeRect(point.x+xOffSet,point.y,2*size.width,size.height) pageNumber:*printCount]];
			}
			
			colorDict = nil;
			
			studCount++;
			
			//if this is the last assignment...
			if(nextAss == nil)
			{
				if(studCount % 2 == 0)
				{
					if(!printGrid)
						[textObjects insertObject:[GRLGrayBox pathObjectWithRect:NSMakeRect(0,point.y,point.x+3*assSize.height-1,assSize.height) pageNumber:*printCount] atIndex:0];
				}
				
				if(printGrid)
					[textObjects addObject:[GRLPathObject pathObjectWithRect:NSMakeRect(0,point.y,point.x + 3*assSize.height-1,assSize.height) pageNumber:*printCount]];
			}
		}
		
		if(printGrid)
		{
			[textObjects addObject:[GRLPathObject pathObjectWithRect:NSMakeRect(point.x+assSize.height-1,point.y,2*assSize.height,paperSize.height - point.y) pageNumber:*printCount]];
		}
		
		point.x += 2*size.height;
		point.y = paperSize.height*0.70;
	}
	
	if([leftOverStudents count])
		[textObjects addObjectsFromArray:[self groupReportForStudents:leftOverStudents printerInfo:printInfo printCount:printCount]];
	
	return textObjects;
}

@synthesize prefs;
@synthesize letterGrades;
@synthesize headerController;
@synthesize data;
@synthesize textView;
@synthesize win;
@synthesize printWindow;
@synthesize docWindow;
@synthesize studentMatrix;
@synthesize startStud;
@synthesize stopStud;
@synthesize belowScore;
@synthesize assMatrix;
@synthesize startAss;
@synthesize stopAss;
@synthesize categoriesButton;
@synthesize indivVsGroupMatrix;
@synthesize optionsButton;
@synthesize progress;
@end
