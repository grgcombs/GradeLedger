//
//  GRLDocumentController.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLDocumentController.h"

@implementation GRLDocumentController

#define userDefaults ([NSUserDefaults standardUserDefaults])


- (id)init
{
    if((self = [super init]))
    {
        m_courses = [[[NSMutableArray alloc] init] retain];
		didFinishLaunching = NO;
    }
    return self;
}

- (void)dealloc
{
    self.courses = nil;
    [super dealloc];
}


- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError **)outError
{
    if(didFinishLaunching)
		return [super openUntitledDocumentAndDisplay:displayDocument error:outError];
    else
		return [super openUntitledDocumentAndDisplay:NO error:outError];
}

- (void)applicationDidFinishLaunching:(NSNotification *)not
{
    didFinishLaunching = YES;
	
    [classListTable setDoubleAction:@selector(openClass:)];
    [classListTable setTarget:self];
    [classListTable registerForDraggedTypes:[NSArray arrayWithObject:@"GRLClassAliases"]];
    
    NSButtonCell *cell = [[[NSButtonCell alloc] init] autorelease];
    [cell setTitle:@""];
    [cell setControlSize:NSSmallControlSize];
    [cell setButtonType:NSSwitchButton];
    
    [[classListTable tableColumnWithIdentifier:@"1"] setDataCell:cell];
    
	NSMutableArray *tempCourses = nil;
    if([userDefaults objectForKey:@"classes"])
    {
        tempCourses = [NSUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"classes"]];
		if (tempCourses) {
			if (NO == [tempCourses isKindOfClass:[NSMutableArray class]]) { // maybe it's not mutable?
				tempCourses = [NSMutableArray arrayWithArray:tempCourses];
			}
			self.courses = tempCourses;
		}
    }

	if([userDefaults objectForKey:@"showClassListOnLaunch"])
        [showClassListOnLaunch setState:[[userDefaults objectForKey:@"showClassListOnLaunch"] integerValue]];
    if([userDefaults objectForKey:@"automaticallyAddNewClasses"])
        [automaticallyAddNewClasses setState:[[userDefaults objectForKey:@"automaticallyAddNewClasses"] integerValue]];
    
    if([showClassListOnLaunch state] == NSOnState)
        [classList makeKeyAndOrderFront:nil];
    
    BOOL openedOne = false;
    
    NSInteger i;
    for(i = 0; i<[self.courses count]; i++)
    {
        NSDictionary *next = [m_courses objectAtIndex:i];
        
        if([next objectForKey:@"url"] == nil)
        {
            [m_courses removeObjectAtIndex:i];
            i--;
        }
        else if([[next objectForKey:@"openOnLaunch"] integerValue] == 1)
        {
            openedOne = YES;
            [[NSWorkspace sharedWorkspace] openURL:[next objectForKey:@"url"]];
        }
    }
        
    if(!openedOne)
        [self newDocument:nil];
        
    [classListTable reloadData];
}

- (void)applicationWillTerminate:(NSNotification *)not
{
    [userDefaults setObject:[NSArchiver archivedDataWithRootObject:m_courses] forKey:@"classes"];
    [userDefaults setObject:[NSNumber numberWithInteger:[showClassListOnLaunch state]] forKey:@"showClassListOnLaunch"];
    [userDefaults setObject:[NSNumber numberWithInteger:[automaticallyAddNewClasses state]] forKey:@"automaticallyAddNewClasses"];
}


- (void)newClassCreated:(NSURL *)url
{
    NSDictionary *obj = nil;
    for(obj in self.courses)
    {
        NSURL *searchURL = [obj objectForKey:@"url"];
    
        if([[searchURL description] isEqualToString:[url description]])
            break;
    }
    
    if(!obj)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:url forKey:@"url"];
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"openOnLaunch"];
    
        [self.courses addObject:dict];
    }
	[classListTable reloadData];
}
- (void)addClass:(id)sender
{	
	for (NSURL *classURL in [self URLsFromRunningOpenPanel]) {
		[self newClassCreated:classURL];	
	}
}

- (id)openDocumentWithContentsOfURL:(NSURL *)absoluteURL display:(BOOL)displayDocument error:(NSError **)outError
{
    id doc = [super openDocumentWithContentsOfURL:absoluteURL display:displayDocument error:outError];
    
    if([automaticallyAddNewClasses state] == NSOnState)
    {        
        [self newClassCreated:absoluteURL];
    }
    
    return doc;
}

- (void)removeClass:(id)sender
{
    //remove the selected class from the list (if any)
    NSInteger index = [classListTable selectedRow];
    if(self.courses && [m_courses count] > index) {
		[m_courses removeObjectAtIndex:index];
	}
    [classListTable reloadData];
}


- (void)openClass:(id)sender
{
	NSInteger classIndex = [classListTable selectedRow];
	if (self.courses && [m_courses count] > classIndex) {
		NSMutableDictionary *course = [m_courses objectAtIndex:classIndex];
		if (course && [course objectForKey:@"url"]) {
			[[NSWorkspace sharedWorkspace] openURL:[course objectForKey:@"url"]];
		}
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if (self.courses)
		return [m_courses count];
	return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
	if([[column identifier] isEqualToString:@"2"]) {
		if (self.courses && [m_courses count]) {
			NSDictionary *dict = [m_courses objectAtIndex:row];
			return [[[[dict objectForKey:@"url"] path] lastPathComponent] stringByDeletingPathExtension];
		}
	}

	return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    return ([[column identifier] isEqualToString:@"1"]);
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if([[aTableColumn identifier] isEqualToString:@"1"])
    {
		if (self.courses && [m_courses count] > rowIndex) {
			NSMutableDictionary *course = [m_courses objectAtIndex:rowIndex];
			if (course && [course objectForKey:@"openOnLaunch"]) {
				NSInteger checkState = [[course objectForKey:@"openOnLaunch"] integerValue];
				[aCell setState:checkState];
			}
			[aCell setAction:@selector(toggleOpening:)];
			[aCell setTarget:self];
		}
    }
}

- (void)toggleOpening:(id)sender
{
    NSInteger index = [classListTable selectedRow];
	if (self.courses && [m_courses count] > index) {
		NSMutableDictionary *dict = [m_courses objectAtIndex:index];
		NSInteger checkState = [[dict objectForKey:@"openOnLaunch"] integerValue];
		NSNumber *toggleInt = [NSNumber numberWithInteger:!checkState];
		[dict setObject:toggleInt forKey:@"openOnLaunch"];
	}
}

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:[rows count]];
    
    for(NSNumber *nextRow in rows) {
        [attributes addObject:nextRow];
	}
        
    [pboard declareTypes:[NSArray arrayWithObjects:@"GRLClassAliases",nil] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:attributes] forType:@"GRLClassAliases"];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info 
									   row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    if(row < 0 || !self.courses) {
        return NO;
	}

    NSPasteboard *board = [info draggingPasteboard];
    
    NSArray *attributes = [NSKeyedUnarchiver unarchiveObjectWithData:[board dataForType:@"GRLClassAliases"]];
    NSMutableArray *atts = [[NSMutableArray alloc] init];
    
	// What is the point of this nonsense? What is this actually *doing*?
    id idNum = nil;
    for(idNum in attributes)
    {
        [atts addObject:[m_courses objectAtIndex:[idNum integerValue]]];
        [m_courses replaceObjectAtIndex:[idNum integerValue] withObject:[NSNull null]];
    }
    
    for(idNum in [atts reverseObjectEnumerator]) {
        [m_courses insertObject:idNum atIndex:row];
	}
    
    for(idNum in [atts reverseObjectEnumerator]) {
        [m_courses removeObject:[NSNull null]];
	}
    
    [tableView reloadData];
    
	[atts release];
	
    return YES;
}

@synthesize classList;
@synthesize classListTable;
@synthesize showClassListOnLaunch;
@synthesize automaticallyAddNewClasses;
@synthesize courses = m_courses;
@synthesize didFinishLaunching;
@end
