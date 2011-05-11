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
        self.m_classes = [NSMutableArray array];
    }
    return self;
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
    
    if([userDefaults objectForKey:@"classes"])
    {
        self.m_classes = [[NSUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"classes"]] retain];
    }
	if (!self.m_classes) // for some reason we didn't get good data from our default preferences
		self.m_classes = [NSMutableArray array];
    if([userDefaults objectForKey:@"showClassListOnLaunch"])
        [showClassListOnLaunch setState:[[userDefaults objectForKey:@"showClassListOnLaunch"] integerValue]];
    if([userDefaults objectForKey:@"automaticallyAddNewClasses"])
        [automaticallyAddNewClasses setState:[[userDefaults objectForKey:@"automaticallyAddNewClasses"] integerValue]];
    
    if([showClassListOnLaunch state] == NSOnState)
        [classList makeKeyAndOrderFront:nil];
    
    BOOL openedOne = false;
    
    NSInteger i;
    for(i = 0; i<[self.m_classes count]; i++)
    {
        NSDictionary *next = [self.m_classes objectAtIndex:i];
        
        if([next objectForKey:@"url"] == nil)
        {
            [self.m_classes removeObjectAtIndex:i];
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
    [userDefaults setObject:[NSArchiver archivedDataWithRootObject:self.m_classes] forKey:@"classes"];
    [userDefaults setObject:[NSNumber numberWithInteger:[showClassListOnLaunch state]] forKey:@"showClassListOnLaunch"];
    [userDefaults setObject:[NSNumber numberWithInteger:[automaticallyAddNewClasses state]] forKey:@"automaticallyAddNewClasses"];
}

- (void)dealloc
{
    self.m_classes = nil;
    [super dealloc];
}


- (void)newClassCreated:(NSURL *)url
{
    NSDictionary *obj;
    
    for(obj in self.m_classes)
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
    
        [self.m_classes addObject:dict];
        [classListTable reloadData];
    }
}
- (void)addClass:(id)sender
{	
	for (NSURL *classURL in [self URLsFromRunningOpenPanel])
		[self newClassCreated:classURL];	
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
    
    if(index < 0 || index >= [self.m_classes count])
        return;
        
    [self.m_classes removeObjectAtIndex:index];
    [classListTable reloadData];
}


- (void)openClass:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[[self.m_classes objectAtIndex:[classListTable selectedRow]] objectForKey:@"url"]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.m_classes count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    NSDictionary *dict = [self.m_classes objectAtIndex:row];

    if([[column identifier] isEqualToString:@"2"])
        return [[[[dict objectForKey:@"url"] path] lastPathComponent] stringByDeletingPathExtension];
    else
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
        [aCell setState:[[[self.m_classes objectAtIndex:rowIndex] objectForKey:@"openOnLaunch"] integerValue]];
        
        [aCell setAction:@selector(toggleOpening:)];
        [aCell setTarget:self];
    }
}

- (void)toggleOpening:(id)sender
{
    NSInteger index = [classListTable selectedRow];
    NSMutableDictionary *dict = [self.m_classes objectAtIndex:index];
    NSNumber *num = [dict objectForKey:@"openOnLaunch"];
    
    [dict setObject:[NSNumber numberWithInteger:![num integerValue]] forKey:@"openOnLaunch"];
}

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:[rows count]];
    
    for(NSNumber *nextRow in rows)
        [attributes addObject:nextRow];
        
    [pboard declareTypes:[NSArray arrayWithObjects:@"GRLClassAliases",nil] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:attributes] forType:@"GRLClassAliases"];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    if(row < 0)
        return NO;

    NSPasteboard *board = [info draggingPasteboard];
    
    NSArray *attributes = [NSKeyedUnarchiver unarchiveObjectWithData:[board dataForType:@"GRLClassAliases"]];
    
    NSMutableArray *atts = [NSMutableArray array];
    
    id idNum;
    for(idNum in attributes)
    {
        [atts addObject:[self.m_classes objectAtIndex:[idNum integerValue]]];
        [self.m_classes replaceObjectAtIndex:[idNum integerValue] withObject:[NSNull null]];
    }
    
    for(idNum in [atts reverseObjectEnumerator])
        [self.m_classes insertObject:idNum atIndex:row];
    
    for(idNum in [atts reverseObjectEnumerator])
        [self.m_classes removeObject:[NSNull null]];
    
    [tableView reloadData];
    
    return YES;
}

@synthesize classList;
@synthesize classListTable;
@synthesize showClassListOnLaunch;
@synthesize automaticallyAddNewClasses;
@synthesize m_classes;
@synthesize didFinishLaunching;
@end
