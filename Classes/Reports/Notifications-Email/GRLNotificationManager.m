//
//  GRLNotificationManager.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLNotificationManager.h"
#import "Mail.h"
#import "NSDate+Helper.h"

#import "GRLAttendanceCodeEvent.h"
#import "GRLMissingAssignmentEvent.h"
#import "GRLScoreEvent.h"

#import "DateUtils.h"
#import "StudentObj.h"
#import "GRLDatabase.h"

@implementation GRLNotificationManager

- (id)init
{
    if((self = [super init]))
    {
        notificationArray = [[NSMutableArray alloc] init];
        timers = [[NSMutableArray alloc] init];
        loggedMessages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSEnumerator *timerEnum = [timers objectEnumerator];
    NSTimer *timer = nil;
    while((timer = [timerEnum nextObject]))
    {
        if([timer isValid]) {
            [timer invalidate];
		}
    }

    self.notificationArray = nil;
	self.timers = nil;
	self.loggedMessages = nil;
    [super dealloc];
}

- (void) awakeFromNib
{    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationFiring:) name:@"GRLNotificationFiring" object:self.data];
    
    NSButtonCell *cell = [[[NSButtonCell alloc] init] autorelease];
    [cell setTitle:@""];
    [cell setControlSize:NSSmallControlSize];
    [cell setButtonType:NSSwitchButton];
    
    [[notTable tableColumnWithIdentifier:@"3"] setDataCell:cell];
    [[notTable tableColumnWithIdentifier:@"4"] setDataCell:cell];
    
    [logView reloadData];
}

- (void)setNotificationData:(NSDictionary *)dict
{
	NSArray *tempArray = [dict objectForKey:@"notificationArray"];
    if(tempArray)
    {
        self.notificationArray = [NSMutableArray arrayWithArray:tempArray];
    }
    
	NSDictionary *tempDict = [dict objectForKey:@"loggedMessages"];
    if(tempDict)
    {
        self.loggedMessages = [NSMutableDictionary dictionaryWithDictionary:tempDict];
    }
    
    [self establishAllTimers];
}

- (NSDictionary *)notificationData
{
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:notificationArray,loggedMessages,nil]
                         forKeys:[NSArray arrayWithObjects:@"notificationArray",@"loggedMessages",nil]];
}

- (void)establishAllTimers
{
    GRLNotification *notif;
    
    for(notif in notificationArray) {
		NSTimer *timer = [self establishTimerForNotification:notif];
        [timers addObject:timer];
	}
}

- (NSTimer *)establishTimerForNotification:(GRLNotification *)notif
{
    NSDate *date = [notif nextEventDate];
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:date interval:0 target:self selector:@selector(checkTimer:) userInfo:notif repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    return [timer autorelease];
}

- (void)showNotifications
{
    [NSApp beginSheet:notSheet modalForWindow:docWindow
		modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)dismissNotifications:(id)sender
{
    [NSApp endSheet:notSheet];
    [notSheet orderOut:nil];
}

- (void)checkTimer:(NSTimer *)timer
{
	if (timer) {
		GRLNotification *not = [timer userInfo];
		NSInteger index = [timers indexOfObject:timer];
		
		[not checkNotificationFiring:self.data];
		[timers replaceObjectAtIndex:index withObject:[self establishTimerForNotification:not]];
	}
}

- (void)notificationFiring:(NSNotification *)notification
{
    NSString *message = [[notification userInfo] objectForKey:@"text"];
    StudentObj *stud = (StudentObj *)[self.data.managedObjectContext objectWithID:[[notification userInfo] objectForKey:@"stud"]];
    GRLNotification *not = [[notification userInfo] objectForKey:@"not"];

	/* create a Scripting Bridge object for talking to the Mail application */
	MailApplication *mail = [SBApplication
							 applicationWithBundleIdentifier:@"com.apple.Mail"];
	
    //do something - log and/or email
    if([not sendsEmail] && [[stud emailAddress] length]) {
		/* create a new outgoing message object */
		MailOutgoingMessage *emailMessage = [[[mail classForScriptingClass:@"outgoing message"] alloc]
											 initWithProperties: [NSDictionary dictionaryWithObjectsAndKeys:
																  [NSString stringWithFormat:@"%@: Student Notification for %@", 
																   [self.prefs valueForKey:@"courseName"],[stud name]], @"subject",
																  message, @"content", nil]];
		
		/* add the object to the mail app  */
		[[mail outgoingMessages] addObject: emailMessage];
						
		/* set the sender, show the message */
		
		emailMessage.sender = [self.prefs valueForKey:@"teacherEmail"];
		emailMessage.visible = YES;
		
		/* create a new recipient and add it to the recipients list */
		MailToRecipient *theRecipient =	[[[mail classForScriptingClass:@"to recipient"] alloc] initWithProperties:
										 [NSDictionary dictionaryWithObjectsAndKeys: [stud emailAddress], @"address", nil]];
		[emailMessage.toRecipients addObject: theRecipient];
		
		/* send the message */
		[emailMessage send];
		
		if (emailMessage) [emailMessage release], emailMessage = nil;
		if (theRecipient) [theRecipient release], theRecipient = nil;
		
	}
    
    if([not logsMessage])
    {
        NSMutableArray *array = [loggedMessages objectForKey:[stud objectID]];
        if(!array)
        {
            array = [NSMutableArray array];
            [loggedMessages setObject:array forKey:[stud objectID]];
        }
        
        [array addObject:[NSDictionary dictionaryWithObject:message forKey:[DateUtils timeStampNow]]];
        [logView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
    }
}


- (IBAction)createNotification:(id)sender
{
    //restore window info to defaults
    
    [notType selectCellAtRow:0 column:0];
    [notDates selectCellAtRow:0 column:0];
    
    [notMessage setString:[GRLAttendanceCodeEvent defaultMessage]];
    [attCode selectItemAtIndex:0];
    [attCount setIntegerValue:0];
    [missCount setIntegerValue:0];
    [finalScoreAboveBelow selectItemAtIndex:0];
    [finalScoreValue setIntegerValue:0];

    if([NSApp runModalForWindow:notInfoSheet])
    {
        GRLNotification *not = [[[GRLNotification alloc] init] autorelease];
        [not setRawMessage:[notMessage string]];
        [not setName:@"New Notification"];
        
        id event = nil;
        
        if([notType selectedRow] == 0) //attendance
        {
            event = [[[GRLAttendanceCodeEvent alloc] initWithFirstTime:[NSDate date]] autorelease];
            [event setAttendanceCode:[attCode indexOfSelectedItem]+1];
            [event setAttendanceCount:[attCount integerValue]];
        }
        else if([notType selectedRow] == 1) //missing
        {
            event = [[[GRLMissingAssignmentEvent alloc] initWithFirstTime:[NSDate date]] autorelease];
            [event setMissingCount:[missCount integerValue]];
        }
        else if([notType selectedRow] == 2) //final score
        {
            event = [[[GRLScoreEvent alloc] initWithFirstTime:[NSDate date]] autorelease];
            [event setFinalScore:[finalScoreValue integerValue]];
            [event setBelowScore:([finalScoreAboveBelow indexOfSelectedItem] == 0)];
        }
        
        [event setDayWeekMonth:[notDates selectedColumn]+1];
        [not setEvent:event];
        
        [notificationArray addObject:not];
        [timers addObject:[self establishTimerForNotification:not]];
        
        [notTable reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
    }
    
    [notInfoSheet orderOut:nil];
}

- (IBAction)editNotification:(id)sender
{
    NSInteger index = [notTable selectedRow];
    
    if(index < 0 || index >= [notificationArray count])
        return;
        
    GRLNotification *not = [notificationArray objectAtIndex:index];
    id oldEvent = [not event];
    
    [notMessage setString:[not rawMessage]];
    [notDates selectCellAtRow:0 column:[oldEvent dayWeekMonth]-1];
    
    if([oldEvent isMemberOfClass:[GRLAttendanceCodeEvent class]]) //attendance
    {
        [attCode selectItemAtIndex:[oldEvent attendanceCode]-1];
        [attCount setIntegerValue:[oldEvent attendanceCount]];
        [missCount setIntegerValue:0];
        [finalScoreAboveBelow selectItemAtIndex:0];
        [finalScoreValue setIntegerValue:0];
        [notType selectCellAtRow:0 column:0];
    }
    else if([oldEvent isMemberOfClass:[GRLMissingAssignmentEvent class]])//missing
    {
        [attCode selectItemAtIndex:0];
        [attCount setIntegerValue:0];
        [missCount setIntegerValue:[oldEvent missingCount]];
        [finalScoreAboveBelow selectItemAtIndex:0];
        [finalScoreValue setIntegerValue:0];
        [notType selectCellAtRow:1 column:0];
    }
    else if([oldEvent isMemberOfClass:[GRLScoreEvent class]])//final score
    {
        [attCode selectItemAtIndex:0];
        [attCount setIntegerValue:0];
        [missCount setIntegerValue:0];
        [finalScoreAboveBelow selectItemAtIndex:![oldEvent belowScore]];
        [finalScoreValue setIntegerValue:[oldEvent finalScore]];
        [notType selectCellAtRow:2 column:0];
    }

    //setup window to not's info

    if([NSApp runModalForWindow:notInfoSheet] == NSOKButton)
    {
        [not setRawMessage:[notMessage string]];
        
        id event = nil;
        
        NSDate *firstDate = [oldEvent firstTimeToCheck];
        NSDate *lastDate = [oldEvent lastTimeChecked];
        
        if([notType selectedRow] == 0) //attendance
        {
            event = [[[GRLAttendanceCodeEvent alloc] initWithFirstTime:firstDate] autorelease];
            [event setAttendanceCode:[attCode indexOfSelectedItem]+1];
            [event setAttendanceCount:[attCount integerValue]];
        }
        else if([notType selectedRow] == 1)//missing
        {
            event = [[[GRLMissingAssignmentEvent alloc] initWithFirstTime:firstDate] autorelease];
            [event setMissingCount:[missCount integerValue]];
        }
        else if([notType selectedRow] == 2) //final score
        {
            event = [[[GRLScoreEvent alloc] initWithFirstTime:firstDate] autorelease];
            [event setFinalScore:[finalScoreValue integerValue]];
            [event setBelowScore:([finalScoreAboveBelow indexOfSelectedItem] == 0)];
        }
        
        [event setDayWeekMonth:[notDates selectedColumn]+1];
        [event setLastTimeChecked:lastDate];
        [not setEvent:event];
        
        NSTimer *timer = [timers objectAtIndex:index];
        if([timer isValid])
            [timer invalidate];
            
        [timers replaceObjectAtIndex:index withObject:[self establishTimerForNotification:not]];
        
        [notTable reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
    }
    
    [notInfoSheet orderOut:nil];
}

- (IBAction)confirmCreationOrEditing:(id)sender
{
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)cancelCreationOrEditing:(id)sender
{
    [NSApp stopModalWithCode:NSCancelButton];
}

- (IBAction)removeNotification:(id)sender
{
    NSInteger index = [notTable selectedRow];
    
    if(index < 0 || index >= [notificationArray count])
        return;
        
    NSString *message = @"Are you sure you want to delete the selected notification(s)?\n\nThere is no undo for this operation.";	
	NSString *title = @"Remove Notifications?";
    
    NSInteger rslt = NSRunAlertPanel(title,
                               message,
                               @"Yes",
                               @"No",
                               nil,
                               [notTable window],
                               nil,
                               nil,
                               nil,
                               nil);
                               
    if(rslt == NSOKButton)
    {
		NSIndexSet *rowIndexes = [notTable selectedRowIndexes];
		//NSUInteger currentIndex = [rowIndexes lastIndex];
		
		// GREG -- couldn't we skip the loop and just do:
		[notificationArray removeObjectsAtIndexes:rowIndexes];
		/*
		while (currentIndex != NSNotFound) {
			[notificationArray removeObjectAtIndex:currentIndex];
			currentIndex = [rowIndexes indexLessThanIndex:currentIndex];
		}
         */   
        [notTable reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
    }
}

- (IBAction)invokeSelectedNotification:(id)sender
{
    NSInteger index = [notTable selectedRow];
    
    if(index < 0 || index >= [notificationArray count])
        return;
        
	NSIndexSet *rowIndexes = [notTable selectedRowIndexes];
	NSUInteger currentIndex = [rowIndexes firstIndex];
		
	while (currentIndex != NSNotFound) {
		[[notificationArray objectAtIndex:currentIndex] forceInvoke:self.data];
		currentIndex = [rowIndexes indexGreaterThanIndex:currentIndex];
	}

}

- (IBAction)matrixSelectionChanged:(id)sender
{
    if([notType selectedRow] == 0)
        [notMessage setString:[GRLAttendanceCodeEvent defaultMessage]];
    else if([notType selectedRow] == 1)
        [notMessage setString:[GRLMissingAssignmentEvent defaultMessage]];
    else if([notType selectedRow] == 2)
        [notMessage setString:[GRLScoreEvent defaultMessage]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(aTableView == notTable)
        return [notificationArray count];
    else 
        return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if(aTableView == notTable)
    {
        GRLNotification *not = [notificationArray objectAtIndex:rowIndex];
        NSString *identifier = [aTableColumn identifier];
		NSDate *tempDate = nil;
        
        if([identifier isEqualToString:@"1"])
            return [not name];
        else if([identifier isEqualToString:@"2"]) {
			tempDate = [[not event] firstTimeToCheck];
            return [tempDate stringWithFormat:kGRLTimestampFormat];
		}
        else if([identifier isEqualToString:@"5"])
			tempDate = [not nextEventDate];
            return [tempDate stringWithFormat:kGRLTimestampFormat];
        
        return nil;
    }
    else
        return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if(aTableView == notTable)
    {
        GRLNotification *not = [notificationArray objectAtIndex:rowIndex];
        NSString *identifier = [aTableColumn identifier];
        
        if([identifier isEqualToString:@"1"])
        {
            [not setName:anObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
        }
        else if([identifier isEqualToString:@"2"])
        {
            NSDate *date = [NSDate dateWithNaturalLanguageString:anObject];
            NSDate *old = [[not event] firstTimeToCheck];
        
            if([date compare:old] != NSOrderedSame)
            {
                [[not event] setFirstTimeToCheck:date];
                
                NSTimer *timer = [timers objectAtIndex:rowIndex];
                if([timer isValid])
                    [timer invalidate];
                    
                [timers replaceObjectAtIndex:rowIndex withObject:[self establishTimerForNotification:not]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
            }
        }
    }
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if(aTableView == notTable)
    {
        NSString *identifier = [aTableColumn identifier];
        GRLNotification *not = [notificationArray objectAtIndex:rowIndex];
        
        if([identifier isEqualToString:@"3"])
        {
            [aCell setState:[not sendsEmail]];
            [aCell setTarget:self];
            [aCell setAction:@selector(toggleEmail:)];
        }
        else if([identifier isEqualToString:@"4"])
        {
            [aCell setState:[not logsMessage]];
            [aCell setTarget:self];
            [aCell setAction:@selector(toggleLog:)];
        }
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(!item) //root
        return [[self.data.studentController arrangedObjects] objectAtIndex:index];
    else if([item isMemberOfClass:[StudentObj class]])
        return [[loggedMessages objectForKey:[item objectID]] objectAtIndex:index];
    else
        return nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(!item)
        return [[self.data.studentController arrangedObjects] count];
    else if([item isMemberOfClass:[StudentObj class]])
        return [[loggedMessages objectForKey:[item objectID]] count];
    else
        return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if(!item || [item isMemberOfClass:[StudentObj class]])
        return YES;
    else
        return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSString *identifier = [tableColumn identifier];

    if([item isMemberOfClass:[StudentObj class]])
    {
        if([identifier isEqualToString:@"1"])
            return [NSString stringWithFormat:@"%@ (%d)",[item name],[[loggedMessages objectForKey:[item objectID]] count]];
    }
    else if([item isKindOfClass:[NSDictionary class]])
    {
        if([identifier isEqualToString:@"1"])
            return [[item allKeys] objectAtIndex:0];
        else if([identifier isEqualToString:@"2"])
            return [[item allValues] objectAtIndex:0];
    }
    
    return nil;
}

- (void)toggleEmail:(id)sender
{
    GRLNotification *not = [notificationArray objectAtIndex:[notTable selectedRow]];
    [not setSendsEmail:![not sendsEmail]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
}

- (void)toggleLog:(id)sender
{
    GRLNotification *not = [notificationArray objectAtIndex:[notTable selectedRow]];
    [not setLogsMessage:![not logsMessage]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
}

- (IBAction)clearLog:(id)sender
{
    [loggedMessages autorelease];
    loggedMessages = [[NSMutableDictionary dictionary] retain];
    [logView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
}

- (void)showLog
{
    [NSApp beginSheet:logWindow
           modalForWindow:docWindow
           modalDelegate:nil
           didEndSelector:nil
           contextInfo:nil];
}

- (IBAction)closeLogWindow:(id)sender
{
    [NSApp endSheet:logWindow];
    [logWindow orderOut:nil];
}

@synthesize notificationArray;
@synthesize timers;
@synthesize loggedMessages;
@synthesize data, prefs;
@synthesize logWindow;
@synthesize logView;
@synthesize docWindow;
@synthesize notSheet;
@synthesize notTable;
@synthesize notInfoSheet;
@synthesize notType;
@synthesize notDates;
@synthesize notMessage;
@synthesize attCode;
@synthesize attCount;
@synthesize missCount;
@synthesize finalScoreAboveBelow;
@synthesize finalScoreValue;
@end
