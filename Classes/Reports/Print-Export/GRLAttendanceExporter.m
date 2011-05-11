//
//  GRLAttendanceExporter.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLAttendanceExporter.h"
#import "NSColor-Additions.h"

#import "DocumentPreferences.h"
#import "StudentObj.h"
#import "CategoryObj.h"
#import "AssignmentObj.h"
#import "AttendanceForDate.h"
#import "ScoreObj.h"
#import "DateUtils.h"
#import "GRLDatabase.h"

@implementation GRLAttendanceExporter

- (void)dealloc
{
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
    
    StudentObj *aStud;
    
    for(aStud in [self.data allStudentsSortedByName])
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
    
    [lastSelectedStart autorelease];
    [lastSelectedStop autorelease];
}

- (void) awakeFromNib {
    [progress setUsesThreadedAnimation:YES];
        
    if([[self.data allStudentsSortedByName] count] && [[self.data allAssignmentsSortedByDueDate] count]) {
        [self populateMenus];
	}
}

- (NSDictionary *)exportingSettings
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *temp;
    
    [dict setObject:[NSNumber numberWithInt:[studentMatrix selectedRow]] forKey:@"studentMatrix"];
    if((temp = [startStud titleOfSelectedItem]))
        [dict setObject:temp forKey:@"startStud"];
    if((temp = [stopStud titleOfSelectedItem]))
        [dict setObject:temp forKey:@"stopStud"];
	
    [dict setObject:[NSNumber numberWithInt:[indivVsGroupMatrix selectedRow]] forKey:@"indivVsGroupMatrix"];
    
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
	
    if([(temp = [groupBeginDate stringValue]) length])
        [dict setObject:temp forKey:@"groupBeginDate"];
    if([(temp = [groupEndDate stringValue]) length])
        [dict setObject:temp forKey:@"groupEndDate"];
    
    return dict;
}

- (void)setExportingSettings:(NSDictionary *)dict
{
    NSString *obj;
    NSNumber *num;
	
    if((num = [dict objectForKey:@"studentMatrix"]))
        [studentMatrix selectCellAtRow:[num integerValue] column:0];
    if((obj = [dict objectForKey:@"startStud"]) && [startStud indexOfItemWithTitle:obj]!=-1)
        [startStud selectItemWithTitle:obj];
    if((obj = [dict objectForKey:@"stopStud"]) && [stopStud indexOfItemWithTitle:obj]!=-1)
        [stopStud selectItemWithTitle:obj];
	
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
	
    if([(obj = [dict objectForKey:@"groupBeginDate"]) length])
        [groupBeginDate setStringValue:obj];
    if([(obj = [dict objectForKey:@"groupEndDate"]) length])
        [groupEndDate setStringValue:obj];
}

- (IBAction)confirmExport:(id)sender
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
        
        if([beginDate compare:endDate] == NSOrderedDescending)
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
	
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)cancelExport:(id)sender
{
    [NSApp stopModalWithCode:NSCancelButton];
}

- (IBAction)changeFirstStudent:(id)sender
{
    NSInteger index = [startStud indexOfSelectedItem];
    
    NSEnumerator *studentEnum = [[self.data allStudentsSortedByName] objectEnumerator];
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

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    id obj = [aNotification object];
    NSString *str = [obj stringValue];
    NSInteger len = [str length];
	
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

- (void)exportToHTML
{
    NSArray *array = [self runAttendanceExportReportDialogue];
    
    if([array count] == 1)
    {
        NSSavePanel *panel = [NSSavePanel savePanel];
        [panel setRequiredFileType:@"html"];
        
        if([panel runModal] == NSOKButton)
            [[[array objectAtIndex:0] objectForKey:@"html"] writeToFile:[panel filename] atomically:NO];
    }
    if([array count] > 1)
    {
        NSDictionary *dict;
        
        //where to save?
        NSRunAlertPanel(@"Multiple Save Message",
                        @"You are requesting to save multiple individual student attendance reports.  In a moment, you will be prompted to select a folder where these files will be saved.  Each file will be called *id*.html, where *id* is the ID number of a given student, or name if no id is set.",
                        nil,
                        nil,
                        nil);
        
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setPrompt:@"Choose"];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        
        if([panel runModal] == NSOKButton)
        {
            NSString *dir = [[panel filenames] objectAtIndex:0];
            NSMutableArray *savedNames = [NSMutableArray array];
            
            BOOL alwaysOverwrite = NO;
            
            for(dict in array)
            {
                NSString *name = [dict objectForKey:@"name"];
                name = [[name componentsSeparatedByString:@" "] componentsJoinedByString:@"_"];
				
                [self writeOutHTML:[dict objectForKey:@"html"] 
							toPath:[NSString stringWithFormat:@"%@/%@.html",dir,name]
                      originalPath:[NSString stringWithFormat:@"%@/%@.html",dir,name]
						  attempts:0
                      writtenPaths:savedNames
						 overwrite:&alwaysOverwrite];
            }
            
            [self writeOutHTML:[self createAttendanceIndex:savedNames]
						toPath:[NSString stringWithFormat:@"%@/index.html",dir]
				  originalPath:[NSString stringWithFormat:@"%@/index.html",dir]
                      attempts:0
				  writtenPaths:savedNames
					 overwrite:&alwaysOverwrite];
        }
    }
}

- (NSString *)createAttendanceIndex:(NSArray *)savedNames
{
    NSString *className = [self.prefs valueForKey:@"courseName"];
	
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<html>\n"];
    
    if(![className length])
        [html appendString:@"<title>Attendance</title>\n"];
    else
        [html appendFormat:@"<title>%@'s Attendance</title>\n",className];
	
    [html appendString:@"<body bgcolor=white>\n\n"];
    
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
    temp = [[temp componentsSeparatedByString:@"\n"] componentsJoinedByString:@"<br>\n"];
    if([temp length])
        [html appendString:temp];
	
    [html appendString:@"<br>\n"];
    
    [html appendString:@"\n<center>\n"];
    [html appendString:@"Classroom Attendance<br>\n"];
    [html appendString:@"\n<table cellpadding=5 border=1>\n"];
    
    NSEnumerator *studEnum = [[self.data allStudentsSortedByName] objectEnumerator];
    NSEnumerator *savedNameEnum = [savedNames objectEnumerator];
    
    StudentObj *stud;
    NSString *savedName;
    NSInteger i = 0;
    
    while((stud = [studEnum nextObject]) && (savedName = [savedNameEnum nextObject]))
    {
        if(i % 3 == 0)
            [html appendString:@"\t<tr>\n"];
		
        NSString *name;
        
        if(![(name = [stud studentID]) length])
            name = [stud name];
        
        [html appendFormat:@"\t\t<td><a href=\"%@\">%@</a></td>\n",[savedName lastPathComponent],name];
		
        if(i % 3 == 2)
            [html appendString:@"\t</tr>\n"];
		
        i = (i+1)%3;
    }
    
    if(i != 0)
        [html appendString:@"\t</tr>\n"];
    
    [html appendString:@"\n</table>\n"];
    [html appendString:@"\n</center>\n"];
    
    [html appendString:@"</body>\n"];
    [html appendString:@"</html>\n"];
    
    return html;
}

- (void)writeOutHTML:(NSString *)html toPath:(NSString *)path originalPath:(NSString *)origPath attempts:(NSInteger)attempts writtenPaths:(NSMutableArray *)paths overwrite:(BOOL *)over
{
    NSFileManager *manager = [NSFileManager defaultManager];
	
    BOOL fileExists = [manager fileExistsAtPath:path];
    BOOL fileNameTaken = ([paths indexOfObject:path] != NSNotFound);
    
    if(fileExists)
    {
        if(fileNameTaken)
        {
			//need a new name
			path = [path stringByDeletingPathExtension];
			NSLog(@"AttendanceExporter -- crazy path stuff: old path = %@", path);
			attempts++;
			path = [NSString stringWithFormat:@"%@_%d.html",origPath,attempts];
            
			NSLog(@"AttendanceExporter -- crazy path stuff: new path = %@", path);
			
			[self writeOutHTML:html toPath:path originalPath:origPath attempts:attempts writtenPaths:paths overwrite:over];
        }
        else if(*over)
        {
            //blow it away!
			[html writeToURL:[NSURL fileURLWithPath:path] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
            //[html writeToFile:path atomically:NO];
            [paths addObject:path];
        }
        else
        {
            //prompt for overwite, perhaps always
            int res = NSRunAlertPanel(@"Overwrite Check",
                                      [NSString stringWithFormat:@"The file %@ already exists.  What would you like to do?",[path lastPathComponent]],
                                      @"Overwrite",
                                      @"New Name",
                                      @"Always Overwrite");
			
            if(res == NSOKButton) //overwrite
            {
				[html writeToURL:[NSURL fileURLWithPath:path] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
                //[html writeToFile:path atomically:NO];
                [paths addObject:path];
            }
            else if(res == NSCancelButton) //new name
            {
                // do nothing
                while([manager fileExistsAtPath:path])
                {
                    path = [path stringByDeletingPathExtension];
					NSLog(@"AttendanceExporter -- crazy path stuff: old path = %@", path);
					
                    attempts++;
                    path = [NSString stringWithFormat:@"%@_%d.html",origPath,attempts];
					NSLog(@"AttendanceExporter -- crazy path stuff: new path = %@", path);
					
                }
				[html writeToURL:[NSURL fileURLWithPath:path] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
                //[html writeToFile:path atomically:NO];
                [paths addObject:path];
            }
            else //always overwrite
            {
				[html writeToURL:[NSURL fileURLWithPath:path] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
				//[html writeToFile:path atomically:NO];
                [paths addObject:path];
                *over = YES;
            }
        }
    }
    else
    {
        //a simple write out
		[html writeToURL:[NSURL fileURLWithPath:path] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
		//[html writeToFile:path atomically:NO];
        [paths addObject:path];
    }
}

- (NSArray *)runAttendanceExportReportDialogue
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
        
        NSMutableArray *studs;
        if([studentMatrix selectedRow] == 0)
            studs = [NSMutableArray arrayWithArray:[self.data allStudentsSortedByName]];
        else if([studentMatrix selectedRow] == 1)
        {
            NSInteger index = [startStud indexOfSelectedItem];
            NSInteger length = [stopStud indexOfSelectedItem] + 1;
            
            studs = [NSMutableArray arrayWithArray:[[self.data allStudentsSortedByName] subarrayWithRange:NSMakeRange(index,length)]];
        }
        else
        {
            studs = [NSMutableArray array];
			
            for (StudentObj *candidate in [self.data allStudentsSortedByName])
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
        
        if([indivVsGroupMatrix selectedRow] == 0)
            textArray = [self htmlDataForIndividualStudents:studs];
        else
        {
            [progress setIndeterminate:YES];
            [progress startAnimation:nil];
			
            textArray = [NSArray arrayWithObject:[self htmlDataForGroupOfStudents:studs]];
			
            [progress stopAnimation:nil];
            [progress setIndeterminate:NO];
            
            [progress stopAnimation:nil];
            [progress setIndeterminate:NO];
        }
        
        [NSApp endSheet:printWindow];
        [printWindow orderOut:self];
        
        return textArray;
        
    }
    else
    {
        [NSApp endSheet:printWindow];
        [printWindow orderOut:self];
		
        return nil;
    }
}

- (NSDictionary *)htmlDataForIndividualStudent:(StudentObj *)stud
{
    NSString *name;
    if(![(name = [stud studentID]) length])
        name = [stud name];
	
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"<html>\n"];
    [str appendFormat:@"<title>%@'s Attendance Report</title>\n",name];
    [str appendString:@"<body bgcolor=white>\n\n"];
    
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
    temp = [[temp componentsSeparatedByString:@"\n"] componentsJoinedByString:@"<br>\n"];
    if([temp length])
        [str appendFormat:@"%@ <br>\n",temp];
	
    [str appendString:@"<br>\n"];
    
    [str appendFormat:@"%@ <br>\n",name];
    
    NSMutableArray *header = [NSMutableArray arrayWithObjects:@"Date",@"Attendance Code", nil];
    NSString *head;
    
    [str appendString:@"\n<center>\n"];
    [str appendString:@"\n<table cellpadding=5>\n"];
    
    [str appendString:@"\t<tr>\n"];
    
    for(head in header)
        [str appendFormat:@"\t\t<td>%@</td>\n",head];
	
    [str appendString:@"\t</tr>\n"];
    
    NSInteger count = 0;
    
    for(AttendanceForDate *attend in [stud attendanceSortedByDate])
    {
		NSDate *date = attend.date;
		
        NSString *strCode = [attend string];
        
        if(!strCode)
            continue;
		
        count++;
        if(count % 2 == 0)
            [str appendString:@"\t<tr bgcolor=CCCCCC>\n"];
        else
            [str appendString:@"\t<tr>\n"];
		
        [str appendFormat:@"\t\t<td>%@</td>\n",[DateUtils dateAsHeaderString:date]];
        [str appendFormat:@"\t\t<td>%@</td>\n",strCode];
        
        [str appendString:@"\t</tr>\n"];
    }
    
    [str appendString:@"</table>\n"];
    [str appendString:@"\n</center>\n"];
    
    [str appendString:@"\n\n<h5>Generated using <a href=https://www.github.com/grgcombs/GradeLedger>GradeLedger</a></h5>\n\n"];
    
    [str appendString:@"</body>\n"];
    [str appendString:@"</html>"];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name,str,nil] 
									   forKeys:[NSArray arrayWithObjects:@"name",@"html",nil]];
}

- (NSArray *)htmlDataForIndividualStudents:(NSArray *)studs
{    
    NSMutableArray *array = [NSMutableArray array];
    
    [progress setMaxValue:[studs count]];
    
    for(StudentObj *stud in studs)
    {
        [progress incrementBy:1.0];
        [progress display];
        
		[array addObject:[self htmlDataForIndividualStudent:stud]];
    }
    
    return array;
}

- (NSDictionary *)htmlDataForGroupOfStudents:(NSArray *)studs
{
    NSString *className = [self.prefs valueForKey:@"courseName"];
	
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<html>\n"];
    
    if(![className length])
        [html appendString:@"<title>Attendance</title>\n"];
    else
        [html appendFormat:@"<title>%@'s Attendance</title>\n",className];
	
    [html appendString:@"<body bgcolor=white>\n\n"];
    
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
    temp = [[temp componentsSeparatedByString:@"\n"] componentsJoinedByString:@"<br>\n"];
    if([temp length])
        [html appendString:temp];
	
    [html appendString:@"<br>\n"];
    
    [html appendString:@"\n<center>\n"];
    [html appendString:@"\n<table cellpadding=5>\n"];
    
    [html appendString:@"\t<tr>\n"];
    
    [html appendString:@"\t\t<td></td>\n"];
    
    NSDate *beginDate = [groupBeginDate dateValue];
    NSDate *endDate = [groupEndDate dateValue];
    NSInteger classDays = self.prefs.classDays;
    
    while([DateUtils isEarlier:beginDate thanDate:endDate])
    {
        if(!((NSInteger)pow(2,[DateUtils dayOfWeekForDate:beginDate]) & classDays))
        {
            beginDate = [DateUtils nextDayFromDate:beginDate];
            continue;
        }
		
        [html appendFormat:@"\t\t<td nowrap>%@</td>\n",[DateUtils dateAsHeaderString:beginDate]];
        
		beginDate = [DateUtils nextDayFromDate:beginDate];
    }
    
    [html appendString:@"\t</tr>\n"];
	
    NSInteger count = 0;
    for(StudentObj *stud in studs)
    {
        count++;
		
        if(count % 2 != 0)
            [html appendString:@"\t<tr>\n"];
        else
            [html appendString:@"\t<tr bgcolor=CCCCCC>\n"];
        
        NSString *name;
        
        if(![(name = [stud studentID]) length])
            name = [stud name];
        
        [html appendFormat:@"\t\t<td>%@</td>\n",name];
		
        beginDate = [groupBeginDate dateValue];
        endDate = [groupEndDate dateValue];
        NSInteger classDays = self.prefs.classDays;
        
        while([beginDate compare:endDate] != NSOrderedDescending)
        {
			if(!((NSInteger)pow(2,[DateUtils dayOfWeekForDate:beginDate]) & classDays))
			{
				beginDate = [DateUtils nextDayFromDate:beginDate];
				continue;
			}
			
			AttendanceForDate *att = [stud attendanceForDate:beginDate];
			
			beginDate = [DateUtils nextDayFromDate:beginDate];
			NSColor *col = [att cellColorWithPrefs:self.prefs];
            
            
			NSString *hex = nil;
            
			if(col) 
				hex = [col hexForColor];
            
			NSString *string = [att string];
			if(![string length])
			{
				string = @" ";
				hex = nil;
			}
            
			if(hex)
				[html appendFormat:@"\t\t<td bgcolor=#%@>%@</td>\n",hex,string];
			else
				[html appendFormat:@"\t\t<td>%@</td>\n",string];
        }
        
        [html appendString:@"\t</tr>\n"];
    }
    
    [html appendString:@"</table>\n\n"];
    
    [html appendString:@"</center>\n\n"];
    
    [html appendString:@"\n\n<h5>Generated using <a href=https://www.github.com/grgcombs/GradeLedger>GradeLedger</a></h5>\n\n"];
    
    [html appendString:@"</body>\n"];
    [html appendString:@"</html>"];
    
    if(!className)
        className = @"Unknown Class";
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:className,html,nil] 
									   forKeys:[NSArray arrayWithObjects:@"name",@"html",nil]];
    
    
}

@synthesize data;
@synthesize prefs;
@synthesize printWindow;
@synthesize docWindow;
@synthesize studentMatrix;
@synthesize startStud;
@synthesize stopStud;
@synthesize indivVsGroupMatrix;
@synthesize progress;
@synthesize headerController;
@end
