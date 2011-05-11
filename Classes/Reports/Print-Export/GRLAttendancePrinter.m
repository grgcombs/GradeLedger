//
//  GRLAttendancePrinter.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLAttendancePrinter.h"
#import "GRLDefines.h"
#import "DocumentPreferences.h"
#import "StudentObj.h"
#import "ScoreObj.h"
#import "DateUtils.h"
#import "AttendanceForDate.h"

#import "GRLTextObject.h"
#import "GRLRotatedTextObject.h"
#import "GRLPathObject.h"
#import "GRLGrayBox.h"
#import "GRLTextView.h"

@implementation GRLAttendancePrinter

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
	[win autorelease];
	[super dealloc];
}

- (void)populateMenus
{			
	[progress setDoubleValue:0];
		
	[self.filteredStudents setSelectedObjects:[self.filteredStudents arrangedObjects]];	
}
- (void) awakeFromNib
{	
	[progress setUsesThreadedAnimation:YES];
	[groupBeginDate setDateValue:[self.prefs valueForKey:@"courseBegin"]];
	[groupEndDate setDateValue:[self.prefs valueForKey:@"courseEnd"]];	
		
	[self populateMenus];
}

- (NSDictionary *)printingSettings
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSString *temp;
	//NSArray *selection = nil;
	
	[dict setObject:[NSNumber numberWithInteger:[studentMatrix selectedRow]] forKey:@"studentMatrix"];
	//if(selection = [self.filteredStudents selectedObjects])
	//	[dict setObject:selection forKey:@"selectedStudents"];
	
	[dict setObject:[NSNumber numberWithInteger:[indivVsGroupMatrix selectedRow]] forKey:@"indivVsGroupMatrix"];
	
	if((temp = [studCodeEqual1 titleOfSelectedItem]))
		[dict setObject:temp forKey:@"studCodeEqual1"];
	if((temp = [studCodeEqual2 titleOfSelectedItem]))
		[dict setObject:temp forKey:@"studCodeEqual2"];
	if((temp = [studCodeEqual4 titleOfSelectedItem]))
		[dict setObject:temp forKey:@"studCodeEqual4"];
	if((temp = [studCodeEqual5 titleOfSelectedItem]))
		[dict setObject:temp forKey:@"studCodeEqual5"];
	
	if([(temp = [studCount1 stringValue]) length])
		[dict setObject:temp forKey:@"studCount1"];
	if([(temp = [studCount2 stringValue]) length])
		[dict setObject:temp forKey:@"studCount2"];
	if([(temp = [studCount4 stringValue]) length])
		[dict setObject:temp forKey:@"studCount4"];
	if([(temp = [studCount5 stringValue]) length])
		[dict setObject:temp forKey:@"studCount5"];
	
	if([(temp = [studBool1 stringValue]) length])
		[dict setObject:temp forKey:@"studBool1"];
	if([(temp = [studBool2 stringValue]) length])
		[dict setObject:temp forKey:@"studBool2"];
	if([(temp = [studBool4 stringValue]) length])
		[dict setObject:temp forKey:@"studBool4"];
/*	
	if([(temp = [groupBeginDate stringValue]) length])
		[dict setObject:temp forKey:@"groupBeginDate"];
	if([(temp = [groupEndDate stringValue]) length])
		[dict setObject:temp forKey:@"groupEndDate"];
	*/
	return dict;
}

- (void)setPrintingSettings:(NSDictionary *)dict
{
	NSString *obj;
	NSNumber *num;
	//NSArray *selection = nil;
	
	if((num = [dict objectForKey:@"studentMatrix"]))
		[studentMatrix selectCellAtRow:[num integerValue] column:0];
	//if(selection = [dict objectForKey:@"selectedStudents"])
	//	[self.filteredStudents setSelectedObjects:selection];
	
	[self toggleOption:studentMatrix];
	
	if((num = [dict objectForKey:@"indivVsGroupMatrix"]))
		[indivVsGroupMatrix selectCellAtRow:[num integerValue] column:0];
	
	if((obj = [dict objectForKey:@"studCodeEqual1"]) && [studCodeEqual1 indexOfItemWithTitle:obj]!=-1)
		[studCodeEqual1 selectItemWithTitle:obj];
	if((obj = [dict objectForKey:@"studCodeEqual2"]) && [studCodeEqual2 indexOfItemWithTitle:obj]!=-1)
		[studCodeEqual2 selectItemWithTitle:obj];
	if((obj = [dict objectForKey:@"studCodeEqual4"]) && [studCodeEqual4 indexOfItemWithTitle:obj]!=-1)
		[studCodeEqual4 selectItemWithTitle:obj];
	if((obj = [dict objectForKey:@"studCodeEqual5"]) && [studCodeEqual5 indexOfItemWithTitle:obj]!=-1)
		[studCodeEqual5 selectItemWithTitle:obj];
	
	if([(obj = [dict objectForKey:@"studCount1"]) length])
	{
		[studCodeEqual1 setEnabled:YES];
		[studCount1 setStringValue:obj];
		[studBool1 setEnabled:YES];
	}
	if([(obj = [dict objectForKey:@"studCount2"]) length])
	{
		[studCodeEqual2 setEnabled:YES];
		[studCount2 setStringValue:obj];
		[studBool2 setEnabled:YES];
	}
	if([(obj = [dict objectForKey:@"studCount4"]) length])
	{
		[studCodeEqual4 setEnabled:YES];
		[studCount4 setStringValue:obj];
		[studBool4 setEnabled:YES];
	}
	if([(obj = [dict objectForKey:@"studCount5"]) length])
	{
		[studCodeEqual5 setEnabled:YES];
		[studCount5 setStringValue:obj];
	}
	
	if((obj = [dict objectForKey:@"studBool1"]) && [studBool1 indexOfItemWithTitle:obj]!=-1)
		[studBool1 selectItemWithTitle:obj];
	if((obj = [dict objectForKey:@"studBool2"]) && [studBool2 indexOfItemWithTitle:obj]!=-1)
		[studBool2 selectItemWithTitle:obj];
	if((obj = [dict objectForKey:@"studBool4"]) && [studBool4 indexOfItemWithTitle:obj]!=-1)
		[studBool4 selectItemWithTitle:obj];
	
	/*
	 if([(obj = [dict objectForKey:@"groupBeginDate"]) length])
		[groupBeginDate setStringValue:obj];
	 if([(obj = [dict objectForKey:@"groupEndDate"]) length])
		[groupEndDate setStringValue:obj];
	 */
}

- (IBAction)confirmPrint:(id)sender
{
	if([indivVsGroupMatrix selectedRow] == 1)
	{
		NSDate *beginDate = [groupBeginDate dateValue];
		NSDate *endDate = [groupEndDate dateValue];
		
		if(![[groupBeginDate stringValue] length] || ![[groupEndDate stringValue] length])
		{
			NSRunAlertPanel(@"Date error!",
							@"You must enter both a valid start and a valid end date",
							nil,
							nil,
							nil);
			return;
		}
		
		if([endDate isEarlierThanDate:beginDate])
		{
			NSRunAlertPanel(@"Date error!",
							[NSString stringWithFormat:@"The date %@ is before the date %@.",
							 [DateUtils dateAsHeaderString:beginDate],
							 [DateUtils dateAsHeaderString:endDate]],
							nil,
							nil,
							nil);
			return;
		}
	}
		if (([studentMatrix selectedRow] == 0) && ([self.filteredStudents selectionIndex] == NSNotFound))
		{
			NSRunAlertPanel(@"Selection error!",
							@"You must select at least one student from the class list.",
							nil,
							nil,
							nil);
			return;
		}
		
	
	[NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)cancelPrint:(id)sender
{
	[NSApp stopModalWithCode:NSCancelButton];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	id obj = [aNotification object];
	NSString *str = [obj stringValue];
	NSUInteger len = [str length];
	
	if(obj == studCount1)
	{
		[studCodeEqual1 setEnabled:len];
		[studBool1 setEnabled:len];
	}
	else if(obj == studCount2)
	{
		[studCodeEqual2 setEnabled:len];
		[studBool2 setEnabled:len];
	}
	else if(obj == studCount4)
	{
		[studCodeEqual4 setEnabled:len];
		[studBool4 setEnabled:len];
	}
	else if(obj == studCount5)
		[studCodeEqual5 setEnabled:len];
}

- (void)runAttendanceReportPrintDialogue
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
			studs = [NSMutableArray arrayWithArray:[self.filteredStudents selectedObjects]];
		else
		{
			studs = [NSMutableArray array];
						
			for (StudentObj *candidate in [self.filteredStudents arrangedObjects])
			{
				NSInteger excuseCount = [candidate numberOfDaysWithAttendanceCode:GRLExcused];
				NSInteger absentCount = [candidate numberOfDaysWithAttendanceCode:GRLAbsent];
				NSInteger lateCount = [candidate numberOfDaysWithAttendanceCode:GRLLate];
				NSInteger tardyCount = [candidate numberOfDaysWithAttendanceCode:GRLTardy];
				
				BOOL truth = NO;
				NSInteger operation = 1; //or
				
				NSString *stringVal = nil;
				
				if([(stringVal = [studCount1 stringValue]) length])
				{
					NSInteger count = [stringVal integerValue];
					NSInteger index = [studCodeEqual1 indexOfSelectedItem];
					BOOL success;
					
					if(	(index == 0 && count < excuseCount) ||
					   (index == 1 && count > excuseCount) ||
					   (index == 2 && count == excuseCount))
						success = YES;
					else
						success = NO;
					
					if(operation == 0) //and
						truth = (truth && success);
					else //or
						truth = (truth || success);
					
					operation = [studBool1 indexOfSelectedItem];
				}
				if([(stringVal = [studCount2 stringValue]) length])
				{
					NSInteger count = [stringVal integerValue];
					NSInteger index = [studCodeEqual2 indexOfSelectedItem];
					BOOL success;
					
					if(	(index == 0 && count < absentCount) ||
					   (index == 1 && count > absentCount) ||
					   (index == 2 && count == absentCount))
						success = YES;
					else
						success = NO;
					
					if(operation == 0) //and
						truth = (truth && success);
					else //or
						truth = (truth || success);
					
					operation = [studBool2 indexOfSelectedItem];
				}
				if([(stringVal = [studCount4 stringValue]) length])
				{
					NSInteger count = [stringVal integerValue];
					NSInteger index = [studCodeEqual4 indexOfSelectedItem];
					BOOL success;
					
					if(	(index == 0 && count < tardyCount) ||
					   (index == 1 && count > tardyCount) ||
					   (index == 2 && count == tardyCount))
						success = YES;
					else
						success = NO;
					
					if(operation == 0) //and
						truth = (truth && success);
					else //or
						truth = (truth || success);
					
					operation = [studBool4 indexOfSelectedItem];
				}
				if([(stringVal = [studCount5 stringValue]) length])
				{
					NSInteger count = [stringVal integerValue];
					NSInteger index = [studCodeEqual5 indexOfSelectedItem];
					BOOL success;
					
					if(	(index == 0 && count < lateCount) ||
					   (index == 1 && count > lateCount) ||
					   (index == 2 && count == lateCount))
						success = YES;
					else
						success = NO;
					
					if(operation == 0) //and
						truth = (truth && success);
					else //or
						truth = (truth || success);
					
					//operation = [studBool5 indexOfSelectedItem];
				}
				
				if(truth)
					[studs addObject:candidate];
			}
		}
		
		textArray = [NSMutableArray array];
		
		if([indivVsGroupMatrix selectedRow] == 0)
		{
			textArray = [textArray arrayByAddingObjectsFromArray:[self individualAttendanceReportsForStudents:studs printerInfo:[NSPrintInfo sharedPrintInfo] pageCount:&pageCount]];
		}
		else
		{
			[progress setIndeterminate:YES];
			[progress startAnimation:nil];
			
			
			textArray = [textArray arrayByAddingObjectsFromArray:[self groupAttendanceReportForStudents:studs printerInfo:[NSPrintInfo sharedPrintInfo] printCount:&pageCount]];
			
			[progress stopAnimation:nil];
			[progress setIndeterminate:NO];
			
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

- (NSArray *)individualAttendanceReportsForStudents:(NSArray *)studs printerInfo:(NSPrintInfo *)printInfo pageCount:(NSInteger *)pageCount
{
	[printInfo setOrientation:NSPortraitOrientation];
		
	NSMutableArray *array = [NSMutableArray array];
	
	[progress setMaxValue:[studs count]];
	
	for(StudentObj *stud in studs)
	{
		[progress incrementBy:1.0];
		[progress display];
		
		[array addObjectsFromArray:[self individualAttendanceReportForStudent:stud printerInfo:printInfo pageCount:pageCount]];
	}
	
	return array;
}

- (NSArray *)individualAttendanceReportForStudent:(StudentObj *)stud printerInfo:(NSPrintInfo *)printInfo pageCount:(NSInteger *)pageCount
{
	NSMutableArray *textObjectsArray = [NSMutableArray array];
	
	NSSize paperSize = [printInfo paperSize];
	paperSize.width -= ([printInfo rightMargin] + [printInfo leftMargin]);
	paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
	
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
	temp = [NSString stringWithFormat:@"Attendance Report for %@",studentName];
	size = [temp sizeWithAttributes:atr];
	point.y -= size.height;
	[textObjectsArray addObject:[GRLTextObject textObjectWithString:temp attributes:atr rect:NSMakeRect(point.x,point.y,size.width,size.height) pageNumber:*pageCount]];
	point.y -= size.height;
	
	NSMutableArray *header = [NSMutableArray arrayWithObjects:@"Date",@"Attendance Code", nil];
	NSMutableArray *lengths = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.30*paperSize.width],[NSNumber numberWithFloat:0.30*paperSize.width],nil];
	
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
	
	for (AttendanceForDate *attend in [stud attendanceSortedByDate])
	{
		NSDate *date = attend.date;
		
		if(![self.prefs dateInScheduleWithDate:date])
			continue;
		
		NSString *strCode = [attend string];
		
		// If the attendance for this particular date doesn't have a notable value (excused, absent, etc), then just skip it.
		if(!strCode || ![strCode length])
			continue;
		
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
			if(![[self.prefs valueForKey:@"printGrid"] boolValue])
				[textObjectsArray addObject:[GRLGrayBox pathObjectWithRect:NSMakeRect(0,point.y-size.height,paperSize.width,size.height) pageNumber:*pageCount]];
			else
				[textObjectsArray addObject:[GRLPathObject pathObjectWithRect:NSMakeRect(0,point.y-size.height,paperSize.width,size.height) pageNumber:*pageCount]];
		}
		
		lengthEnum = [lengths objectEnumerator];
		NSInteger len;
		
		len = [[lengthEnum nextObject] integerValue];
		NSString *dateStr = [DateUtils dateAsHeaderString:date];
		if(dateStr)
		{
			size = [dateStr sizeWithAttributes:atr];
			[textObjectsArray addObject:[GRLTextObject textObjectWithString:dateStr attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
		}
		point.x += len;
		
		len = [[lengthEnum nextObject] integerValue];
		if(strCode)
		{
			size = [strCode sizeWithAttributes:atr];
			[textObjectsArray addObject:[GRLTextObject textObjectWithString:strCode attributes:atr rect:NSMakeRect(point.x,point.y-size.height,len,size.height) pageNumber:*pageCount]];
		}
		point.x += len;
	}
	
	return textObjectsArray;
}

- (NSArray *)groupAttendanceReportForStudents:(NSArray *)studs printerInfo:(NSPrintInfo *)printInfo printCount:(NSInteger *)printCount
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
	NSSize size; //= NSMakeSize(0,0);
	
	NSMutableDictionary *whiteDict = [NSMutableDictionary dictionary];
	[whiteDict setObject:[NSFont fontWithName:@"Geneva" size:9] forKey:NSFontAttributeName];
	[whiteDict setObject:[NSNumber numberWithInt:0] forKey:NSUnderlineStyleAttributeName];
	
	NSMutableDictionary *colorDict = nil;
	
	(*printCount)++;
	
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
	if([temp length])
		[textObjects addObject:[GRLTextObject textObjectWithString:temp attributes:whiteDict rect:NSMakeRect(0,paperSize.height*0.70,paperSize.width*0.25,paperSize.height*0.30) pageNumber:*printCount]];
	
	NSInteger count = 0;
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
				
				point.y -= size.height;
			}
		}
	}
	
	NSDate *beginDate = [groupBeginDate dateValue];
	NSDate *endDate = [groupEndDate dateValue];
	
	point = NSMakePoint(paperSize.width*0.25,paperSize.height*0.70);
	
	while([beginDate compare:endDate] != NSOrderedDescending)
	{
		if(![self.prefs dateInScheduleWithDate:beginDate])
		{
			beginDate = [DateUtils nextDayFromDate:beginDate];
			continue;
		}
				
		NSDate *savedDate = beginDate;
		NSString *savedDateStr = [DateUtils dateAsHeaderString:beginDate];
		
		beginDate = [DateUtils nextDayFromDate:beginDate];
		
		//NEW CODE
		BOOL willBeLast = NO;
		NSDate *nextDate = [DateUtils nextDayFromDate:beginDate];
		while((![self.prefs dateInScheduleWithDate:nextDate]) && [nextDate isEarlierThanDate:endDate])
			nextDate = [DateUtils nextDayFromDate:nextDate];
		
		if([endDate isEarlierThanDate:nextDate])
			willBeLast = YES;
		//END NEW CODE
		
		NSSize assSize =  [savedDateStr sizeWithAttributes:whiteDict];
		
		size = assSize;
		
		if(point.x + 3*size.height > paperSize.width)
		{
			//time to move on!
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
				
				point.y -= size.height;
			}
			
			point = NSMakePoint(paperSize.width*0.25,paperSize.height*0.70);
			size = [savedDateStr sizeWithAttributes:whiteDict];
		}
		
		[textObjects addObject:[GRLRotatedTextObject textObjectWithString:savedDateStr attributes:whiteDict rect:NSMakeRect(point.x+2.5*size.height,paperSize.height*0.71,size.width+10,size.height) pageNumber:*printCount degrees:90]];
		
		
		NSInteger studCount = 0;
		
		for(stud in activeStudents)
		{
			AttendanceForDate *att = [stud attendanceForDate:savedDate];
			NSColor *color = [att cellColorWithPrefs:self.prefs];
						
			NSString *str = [att abbreviatedString];
			// If we don't get an important attendance code (excused, absent, etc) then just make this one blank.
			if(!str || ![str length])
			{
				str = @" ";
				color = nil;
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
			if(willBeLast)
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
		[textObjects addObjectsFromArray:[self groupAttendanceReportForStudents:leftOverStudents printerInfo:printInfo printCount:printCount]];
	
	return textObjects;
}

- (IBAction)toggleOption:(id)sender
{
	BOOL shouldEnable = NO;

	if (sender == studentMatrix) {
		shouldEnable = ([sender selectedRow] == 0);

		[self.studentTable setEnabled:shouldEnable];
		[self.studentTable setNeedsDisplay:YES];
	}
	else if (sender == indivVsGroupMatrix) {
		shouldEnable = ([sender selectedRow] == 1);

		[self.groupBeginDate setEnabled:shouldEnable];
		[self.groupBeginDate setNeedsDisplay:YES];

		[self.groupEndDate setEnabled:shouldEnable];
		[self.groupEndDate setNeedsDisplay:YES];
	}
}

@synthesize filteredStudents;
@synthesize prefs;
@synthesize studentTable;
@synthesize groupBeginDate, groupEndDate;

@synthesize textView;
@synthesize win;
@synthesize printWindow;
@synthesize docWindow;
@synthesize studentMatrix;
@synthesize indivVsGroupMatrix;
@synthesize progress;
@synthesize headerController;
@end
