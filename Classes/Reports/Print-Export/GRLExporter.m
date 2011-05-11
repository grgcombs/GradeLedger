//
//  GRLExporter.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLExporter.h"
#import "NSDate+Helper.h"

#import "DocumentPreferences.h"
#import "NSColor-Additions.h"
#import "StudentObj.h"
#import "ScoreObj.h"
#import "CategoryObj.h"
#import "AssignmentObj.h"
#import "DateUtils.h"
#import "GRLDatabase.h"
#import "LetterGradeLookup.h"

@implementation GRLExporter

- (id)init
{
	self = [super init];
	if(self) {
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)populateMenus
{
	NSString *lastSelectedStart = [startStud titleOfSelectedItem];
	NSString *lastSelectedStop = [stopStud titleOfSelectedItem];
		
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
		
	lastSelectedStart = [startAss titleOfSelectedItem];
	lastSelectedStop = [stopAss titleOfSelectedItem];
	
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
		
	NSMutableArray *pastCategories = [NSMutableArray array];
	
	NSMenuItem *item;
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
	
	if([[self.data.studentController arrangedObjects] count] && [[self.data allAssignmentsSortedByDueDate] count])
		[self populateMenus];
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
	
	if(([(temp = [belowScore stringValue]) length]))
		[dict setObject:temp forKey:@"belowScore"];
	
	[dict setObject:[NSNumber numberWithInt:[assMatrix selectedRow]] forKey:@"assMatrix"];
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

- (void)exportToHTML:(id)sender
{
	NSArray *array = [self runHTMLExportReportDialogue];
	
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
						@"You are requesting to save multiple individual student reports.  In a moment, you will be prompted to select a folder where these files will be saved.  Each file will be called *id*.html, where *id* is the ID number of a given student, or name if no id is set.",
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
			
			[self writeOutHTML:[self createGradesIndex:savedNames]
						toPath:[NSString stringWithFormat:@"%@/index.html",dir]
				  originalPath:[NSString stringWithFormat:@"%@/index.html",dir]
					  attempts:0
				  writtenPaths:savedNames
					 overwrite:&alwaysOverwrite];
		}
	}
}

- (NSString *)createGradesIndex:(NSArray *)savedNames
{
	NSString *className = [self.prefs valueForKey:@"courseName"];
	
	NSMutableString *html = [NSMutableString string];
	[html appendString:@"<html>\n"];
	
	if(![className length])
		[html appendString:@"<title>Grade reports</title>\n"];
	else
		[html appendFormat:@"<title>%@'s Grade Reports</title>\n",className];
	
	[html appendString:@"<body bgcolor=white>\n\n"];
	
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
	temp = [[temp componentsSeparatedByString:@"\n"] componentsJoinedByString:@"<br>\n"];
	if([temp length])
		[html appendString:temp];
	
	[html appendString:@"<br>\n"];
	
	[html appendString:@"\n<center>\n"];
	[html appendString:@"Classroom Grades<br>\n"];
	[html appendString:@"\n<table cellpadding=5 border=1>\n"];
	
	NSEnumerator *studEnum =  [[self.data.studentController arrangedObjects] objectEnumerator];
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
			NSLog(@"Exporter -- crazy path stuff: old path = %@", path);
			attempts++;
			path = [NSString stringWithFormat:@"%@_%d.html",origPath,attempts];
			NSLog(@"Exporter -- crazy path stuff: new path = %@", path);
			
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
			NSInteger res = NSRunAlertPanel(@"Overwrite Check",
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
					NSLog(@"Exporter -- crazy path stuff: old path = %@", path);
					
					attempts++;
					path = [NSString stringWithFormat:@"%@_%d.html",origPath,attempts];
					NSLog(@"Exporter -- crazy path stuff: new path = %@", path);
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

- (NSArray *)runHTMLExportReportDialogue
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
		NSArray *theArray = nil;
		
		NSMutableArray *studs;
		if([studentMatrix selectedRow] == 0)
			studs =  [self.data.studentController arrangedObjects];
		else if([studentMatrix selectedRow] == 1)
		{
			NSInteger index = [startStud indexOfSelectedItem];
			NSInteger length = [stopStud indexOfSelectedItem] + 1;
			
			studs = [NSMutableArray arrayWithArray:[ [self.data.studentController arrangedObjects] subarrayWithRange:NSMakeRange(index,length)]];
		}
		else
		{
			CGFloat score = [belowScore doubleValue];
			studs = [NSMutableArray array];
			
			for (StudentObj *stud in [self.data.studentController arrangedObjects])
				if([stud.gradeTotal doubleValue] < score)
					[studs addObject:stud];
		}
		
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
			
			theArray = [self htmlDataForIndividualStudents:studs options:options];
		}
		else
		{
			[progress setIndeterminate:YES];
			[progress startAnimation:nil];
			theArray = [NSArray arrayWithObject:[self htmlDataForGroupOfStudents:studs]];
			[progress stopAnimation:nil];
			[progress setIndeterminate:NO];
		}
		
		[NSApp endSheet:printWindow];
		[printWindow orderOut:self];
		
		return theArray;
	}
	else
	{
		[NSApp endSheet:printWindow];
		[printWindow orderOut:self];
		
		return nil;
	}
}

- (NSDictionary *)htmlDataForIndividualStudent:(StudentObj *)stud options:(NSInteger)opts
{
	NSString *name;
	if(![(name = [stud studentID]) length])
		name = [stud name];
	
	NSMutableString *str = [NSMutableString string];
	[str appendString:@"<html>\n"];
	[str appendFormat:@"<title>%@'s Grade Report</title>\n",name];
	[str appendString:@"<body bgcolor=white>\n\n"];
	
	NSEnumerator *assEnum;
	
	if([assMatrix selectedRow] == 1)
		assEnum = [[NSMutableArray arrayWithArray:[[self.data allAssignmentsSortedByDueDate] subarrayWithRange:NSMakeRange([startAss indexOfSelectedItem],[stopAss indexOfSelectedItem] + 1)]] objectEnumerator];
	else
		assEnum = [[self.data allAssignmentsSortedByDueDate] objectEnumerator];
	
	AssignmentObj *ass;
	
	NSString *assName = nil; 		//opts & 1
	NSString *rawScore = nil; 	//opts & 2
	NSString *adjustedScore; 	//opts & 4
	NSString *maxScore = nil; 	//opts & 8
	NSString *code = nil; 		//opts & 16
	NSString *categoryName = nil; 	//opts & 32
	NSString *dueDate = nil; 		//opts & 64
	NSString *turnedInDate = nil; 	//opts & 128
	
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"]; //[headerController getHeader];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
	temp = [[temp componentsSeparatedByString:@"\n"] componentsJoinedByString:@"<br>\n"];
	if([temp length])
		[str appendFormat:@"%@ <br>\n",temp];
	
	[str appendString:@"<br>\n"];
	
	[str appendFormat:@"%@ <br>\n",name];
	
	NSString *score = stud.gradeTotal;
	temp = [NSString stringWithFormat:@"Grade: %@%% %@",score,[letterGrades gradeForScore:[score doubleValue]]];
	[str appendFormat:@"%@ <br>\n",temp];
	
	[str appendString:@"<br>\n"];
	
	NSMutableArray *header = [NSMutableArray array];
	
	if(opts & 1) 
		[header addObject:@"Assignment"];
	if(opts & 2) 
		[header addObject:@"Raw"];
	if(opts & 4) 
		[header addObject:@"Adj"];
	if(opts & 8) 
		[header addObject:@"Max"];
	if(opts & 16) 
		[header addObject:@"Code"];
	if(opts & 32) 
		[header addObject:@"Category"];
	if(opts & 64) 
		[header addObject:@"Due"];
	if(opts & 128) 
		[header addObject:@"Collected"];
	
	NSString *head;
	
	[str appendString:@"\n<center>\n"];
	[str appendString:@"\n<table cellpadding=5>\n"];
	
	[str appendString:@"\t<tr>\n"];
	
	for(head in header)
		[str appendFormat:@"\t\t<td>%@</td>\n",head];
	
	[str appendString:@"\t</tr>\n"];
	
	NSInteger count = 0;
	
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
		
		[str appendString:@"\t<tr>\n"];
		
		count++;
		if(count % 2 == 0)
			[str appendString:@"\t<tr bgcolor=#D3D3D3>\n"];
		else
			[str appendString:@"\t<tr>\n"];
		
		ScoreObj *score = [stud scoreForAssignment:ass];
		NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
		
		if(opts & 1)
		{
			assName = [ass name];
			if(!assName)
				assName = @"";
			[str appendFormat:@"\t\t<td>%@</td>\n",assName];
		}
		
		if(opts & 2)
		{
			rawScore = [dict objectForKey:@"raw"];
			if(!rawScore)
				rawScore = @"";
			[str appendFormat:@"\t\t<td>%@</td>\n",rawScore];
		}
		
		if(opts & 4)
		{    
			adjustedScore = [dict objectForKey:@"curved"];
			
			if ((adjustedScore == nil) || (rawScore && [adjustedScore isEqualToString:rawScore]))
				[str appendString:@"\t\t<td></td>\n"];
			else
				[str appendFormat:@"\t\t<td>%@</td>\n",adjustedScore];
		}
		
		if(opts & 8)
		{
			maxScore = [NSString stringWithFormat:@"%d",[[ass maxPoints] integerValue]];
			if(!maxScore)
				maxScore = @"";
			[str appendFormat:@"\t\t<td>%@</td>\n",maxScore];
		}
		
		if(opts & 16)
		{
			code = @"";
			ScoreObj *score = [stud scoreForAssignment:ass];
			if (score)
				code = [score abbreviatedCollectionString];
			[str appendFormat:@"\t\t<td>%@</td>\n",code];
		}
		
		if(opts & 32)
		{
			categoryName = ass.category.name;
			if(!categoryName)
				categoryName = @"";
			[str appendFormat:@"\t\t<td>%@</td>\n",categoryName];
		}
		
		if(opts & 64)
		{
			dueDate = [[ass dueDate] stringWithFormat:kGRLDateShortFormat];
			if(!dueDate)
				dueDate = @"";
			[str appendFormat:@"\t\t<td>%@</td>\n",dueDate];
		}
		
		if(opts & 128)
		{
			ScoreObj *score = [stud scoreForAssignment:ass];
			turnedInDate = [score.collectionDate stringWithFormat:kGRLDateShortFormat];
			if(!turnedInDate)
				turnedInDate = @"";
			[str appendFormat:@"\t\t<td>%@</td>\n",turnedInDate];
		}
		
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

- (NSArray *)htmlDataForIndividualStudents:(NSArray *)studs options:(NSInteger)opts
{
	StudentObj *stud;
	
	NSMutableArray *array = [NSMutableArray array];
	
	[progress setMaxValue:[studs count]];
	
	for(stud in studs)
	{
		[progress incrementBy:1.0];
		[progress display];
		
		[array addObject:[self htmlDataForIndividualStudent:stud options:opts]];
	}
	
	return array;
}

- (NSDictionary *)htmlDataForGroupOfStudents:(NSArray *)studs
{
	NSString *className = [self.prefs valueForKey:@"courseName"];
	
	NSMutableString *html = [NSMutableString string];
	[html appendString:@"<html>\n"];
	
	if(![className length])
		[html appendString:@"<title>Grade Reports</title>\n"];
	else
		[html appendFormat:@"<title>%@'s Grade Reports</title>\n",className];
	
	[html appendString:@"<body bgcolor=white>\n\n"];
	
	NSString *headerStr = [self.prefs valueForKey:@"exportHeader"];
	NSString *temp = [self.prefs resolveStringAgainstPrefs:headerStr];
	temp = [[temp componentsSeparatedByString:@"\n"] componentsJoinedByString:@"<br>\n"];
	
	if([temp length])
		[html appendString:temp];
	
	[html appendString:@"<br>\n"];
	
	NSMutableArray *assess;
	NSEnumerator *assEnum;
	
	if([assMatrix selectedRow] == 1)
		assess = [NSMutableArray arrayWithArray:[[self.data allAssignmentsSortedByDueDate] subarrayWithRange:NSMakeRange([startAss indexOfSelectedItem],[stopAss indexOfSelectedItem] + 1)]];
	else
		assess = [NSMutableArray arrayWithArray:[self.data allAssignmentsSortedByDueDate]];
	
	assEnum = [assess objectEnumerator];
	
	AssignmentObj *ass;
	
	while((ass = [assEnum nextObject]))
	{
		if([assMatrix selectedRow] == 2)
		{            
			NSUInteger index = [[self.data allCategoriesSortedByName] indexOfObjectIdenticalTo:ass.category];
			
			if(index == NSNotFound)
				[assess removeObject:ass];
			
			if(![[categoriesButton itemAtIndex:index+1] state])
				[assess removeObject:ass];
		}
	}
	
	[html appendString:@"\n<center>\n"];
	[html appendString:@"\n<table cellpadding=5>\n"];
	
	[html appendString:@"\t<tr>\n"];
	
	[html appendString:@"\t\t<td></td>\n"];
	
	[html appendFormat:@"\t\t<td nowrap>%@</td>\n",@"Final Score"];
	
	for(ass in assess)
		[html appendFormat:@"\t\t<td nowrap>%@ (%d)</td>\n",[ass name],[ass.maxPoints integerValue]];
	
	[html appendString:@"\t</tr>\n"];
	
	StudentObj *stud;
	
	NSInteger count = 0;
	
	for(stud in studs)
	{
		count++;
		
		if(count % 2 != 0)
			[html appendString:@"\t<tr>\n"];
		else
			[html appendString:@"\t<tr bgcolor=CCCCCC>\n"];
		
		if(![[stud studentID] length])
			[html appendFormat:@"\t\t<td>%@</td>\n",[stud name]];
		else
			[html appendFormat:@"\t\t<td>%@</td>\n",[stud studentID]];
		
		NSString *finalScore = stud.gradeTotal;
		
		NSString *letterGrade = [letterGrades gradeForScore:[finalScore doubleValue]];
		
		[html appendFormat:@"\t\t<td>%@ %@</td>\n",finalScore,letterGrade];
		
		for(ass in assess)
		{
			ScoreObj *score = [stud scoreForAssignment:ass];
			NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
			
			NSString *string = [dict objectForKey:@"curved"];
			if(![string length])
			{
				string = [dict objectForKey:@"raw"];
				if(![string length])
					string = @" ";
			}
			
			NSColor *col = [score cellColorWithPrefs:self.prefs];
						
			NSString *hex = nil;
			
			if(col) 
				hex = [col hexForColor];
			
			if([string isEqualToString:@" "])
			{
				string = [score abbreviatedCollectionString];
				if(![string length])
				{
					string = @" ";
					hex = nil;
				}
			}
			
			if(hex)
				[html appendFormat:@"\t\t<td bgcolor=%@>%@</td>\n",hex,string];
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

@synthesize data, prefs;
@synthesize letterGrades;
@synthesize headerController;
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
