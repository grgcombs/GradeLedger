//
//  DocumentPreferences.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "DocumentPreferences.h"
#import "LetterGradeLookup.h"
#import "DateUtils.h"

@interface DocumentPreferences (Private)
- (NSDictionary *)getDefaultPrefs;
- (NSManagedObject*)findParameter:(NSString*)key;
- (NSManagedObject*)createParameter:(NSString*)name;

@end


@implementation DocumentPreferences

@synthesize associatedDocument = _associatedDocument;
@synthesize defaults = _defaults;
@synthesize numberOfClassDaysThusFar;
@synthesize classDaysList = m_classDaysArray;
@synthesize scheduleKeys;

- (id) init
//- (id)initWithDocument:(NSPersistentDocument*)associatedDocument
{
	if (!(self = [super init])) return nil;
	
	//_associatedDocument = associatedDocument;
	
	if (!m_classDaysArray)
		m_classDaysArray = [[NSMutableArray array] retain];

	
	// We set up the default settings every time we initialize a document, so we don't save defaults to disk.
	_defaults = [[self getDefaultPrefs] retain];
	
	numberOfClassDaysThusFar = -1;
			
	scheduleKeys = [[[NSArray alloc] initWithObjects:@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", @"sunday", 
								@"courseBegin", @"courseEnd", nil] retain];
	
	for (NSString *keyPath in scheduleKeys) {
		[self addObserver:self 
		  forKeyPath:keyPath 
			 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
			 context:nil];
	}
	
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self resetAllClassDays:self];
}

- (void) dealloc {
	for (NSString *keyPath in scheduleKeys) {
		[self removeObserver:self forKeyPath:keyPath];
	}
	
	if (scheduleKeys) [scheduleKeys release], scheduleKeys = nil;
	[super dealloc];
}

/*
 Whenever another piece
 of code requests a parameter from our DocumentPreferences object, the
 -valueForUndefinedKey: method will get called, and that is where we handle
 access to the parameters table.
 
 In this method, we receive the name of the value that the caller is
 attempting to retrieve. We use this name to retrieve the NSManagedObject
 via the -findParameter: method and return the NSManagedObject
 object’s value property.
 */
//START:valueForUndefinedKey
- (id)valueForUndefinedKey:(NSString*)key
{
	id parameter = [self findParameter:key];
	if (!parameter && [[self defaults] objectForKey:key]) {
		return [[self defaults] objectForKey:key];
	}
	return [parameter valueForKey:@"value" ];
}
//END:valueForUndefinedKey

+ (id)valueForPreferenceKey:(NSString*)key context:(NSManagedObjectContext*)context {
	
	NSManagedObject *parameter = [DocumentPreferences findParameter:key withContext:context];
	if (parameter)
		return [parameter valueForKey:@"value"];
	return nil;
}
/*
 In the -findParameter: method, we construct an NSFetchRequest against
 the parameters table using a compare on the name property to filter it
 down to a single result. Assuming there is no error on the fetch, we
 return the NSManagedObject that is returned. In this method, we are
 using the -lastObject method on the resulting array as a convenience.
 -lastObject automatically checks for an empty array and will return nil if
 the array is empty. This reduces the code complexity and gives us the
 result we want in a single call. If there is an error accessing the Core
 Data stack, we report the error and return nil. Note that we do not create
 a parameter if there is not one in this method. We intentionally separate
 this out so that we are not creating potentially empty parameters. This
 allows us to request a parameter and check whether it is nil without
 concern of parameters being generated unnecessarily.
 */
//START:findParameter
- (NSManagedObject*)findParameter:(NSString*)name;
{
	NSManagedObjectContext *moc;
	NSManagedObject *param;
	NSError *error = nil;
	moc = [[self associatedDocument] managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"DocPrefParameter"
								   inManagedObjectContext:moc]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@" , name]];
	param = [[moc executeFetchRequest:request error:&error] lastObject];
	if (request) [request release], request = nil;
	if (error) {
		NSLog(@"%@:%s Error fetching parameter: %@" , [self class], (char *)_cmd, error);
		return nil;
	}
	return param;
}
//END:findParameter

+ (NSManagedObject*)findParameter:(NSString*)name withContext:(NSManagedObjectContext *)moc
{
	NSManagedObject *param;
	NSError *error = nil;

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"DocPrefParameter"
								   inManagedObjectContext:moc]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@" , name]];
	param = [[moc executeFetchRequest:request error:&error] lastObject];
	if (request) [request release], request = nil;
	if (error) {
		NSLog(@"%@:%s Error fetching parameter: %@" , [self class], (char *)_cmd, error);
		return nil;
	}
	return param;
}

/*
 In addition to being able to access a parameter, we also need to set
 parameters. This is done in the counterpart method of -valueForUndefinedKey:
 called -setValue:forUndefinedKey:. In this method, we first
 notify the system that we are going to be changing the value associated
 with the passed-in key. This is part of KVO and is required so
 that notifications work correctly. After starting the KVO notification, we
 attempt to retrieve the NSManagedObject from the parameters table. If
 there is no NSManagedObject for the passed-in key, we then check the
 defaults NSDictionary to see whether there is a default. If there is a default
 set and the passed-in value matches the default, we complete the KVO
 notification and return. If the default value does not match the passedin
 value, we create a new NSManagedObject for the passed-in key.
 
 If there is an NSManagedObject and a default set for the key, we compare
 the default value to the passed-in value. If they match, we then
 delete the NSManagedObject, which effectively resets the parameter to
 the default. Once we pass the checks against default and/or create the
 NSManagedObject, we test the value to see whether it is an NSNumber or
 NSDate. If it is, then we pass in its -stringValue or -description as the value
 for the NSManagedObject. Otherwise, we pass in the value directly to the
 NSManagedObject. Once the value is set, we call -didChangeValueForKey:
 to complete the KVO notification.
 */

//START:setValueForKey
- (void)setValue:(id)value forUndefinedKey:(NSString*)key
{	
	[self willChangeValueForKey:key];
	
	NSManagedObject *parameter = [self findParameter:key];
	id defaultValue = [[self defaults] valueForKey:key];
	
	if (!parameter) {
		if (defaultValue) {
			//NSLog(@"Setting new preferences data");
			//NSLog(@"default kind: %@", [defaultValue class]);
			//NSLog(@"value kind: %@", [value class]);
			
			if ([defaultValue isKindOfClass:[NSArray class]] && [value isEqualToArray:defaultValue]) {
				[self didChangeValueForKey:key];
				return;
			}
			else if (defaultValue && [value isEqualTo:defaultValue]) {
				[self didChangeValueForKey:key];
				return;
			}
		}
		parameter = [self createParameter:key];
	} else {
		if (defaultValue && [value isEqualTo:defaultValue]) {
			[self didChangeValueForKey:key];
			[[[self associatedDocument] managedObjectContext] deleteObject:parameter];
			[self didChangeValueForKey:key];
			return;
		}
	}
	if ([value isKindOfClass:[NSNumber class]]) {
		[parameter setValue:[value stringValue] forKey:@"value" ];
	} else if ([value isKindOfClass:[NSDate class]]) {
		//NSLog(@"Old: %@ ------------ New: %@", value, [DateUtils roundOffTimeFromDate:value]);
		//[parameter setValue:[value description] forKey:@"value" ];
		[parameter setValue:value forKey:@"value" ];
	} else {
		[parameter setValue:value forKey:@"value" ];
	}
	//[self didChangeValueForKey:key];	// GREG REVERSE CHANGE??? this was causing duplicate announcements
	
}
//END:setValueForKey

/*
 The -createParameter: method creates a new NSManagedObject and sets
 the name property with the passed-in value. It does not set the value
 property, leaving that up to the caller. This allows us to set a nil parameter
 if we really need one.
 */
//START:createParameter
- (NSManagedObject*)createParameter:(NSString*)name
{
	NSManagedObject *param;
	NSManagedObjectContext *moc;
	moc = [[self associatedDocument] managedObjectContext];
	param = [NSEntityDescription insertNewObjectForEntityForName:@"DocPrefParameter"
										  inManagedObjectContext:moc];
	[param setValue:name forKey:@"name" ];
	return param;
}
//END:createParameter

- (NSArray*)allRealParameters
{
	NSManagedObjectContext *moc;
	NSError *error = nil;
	moc = [[self associatedDocument] managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"DocPrefParameter"
								   inManagedObjectContext:moc]];
	NSArray *params = [moc executeFetchRequest:request error:&error];
	if (request) [request release], request = nil;
	if (error) {
		NSLog(@"%@:%s Error fetching parameter: %@" , [self class], (char *)_cmd, error);
		return nil;
	}
	return params;
}

/*
 In addition to the primary function of this class, we have a couple of
 convenience methods that have proven useful. The first one, -allParameters,
 returns an NSDictionary of all the parameters, including the defaults.
 In this method, we create an NSFetchRequest for the Parameter
 entity without an NSPredicate. We take the resulting NSArray from the
 fetch and loop over it. Within that loop, we add each NSManagedObject
 to an NSMutableDictionary derived from the default NSDictionary. This
 ensures that we have both the default values and the Parameter entries
 included in the final NSDictionary.
 */
//START:allParameters
- (NSDictionary*)allParameters;
{
	NSManagedObjectContext *moc;
	NSError *error = nil;
	moc = [[self associatedDocument] managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"DocPrefParameter" inManagedObjectContext:moc]];
	
	NSArray *params = [moc executeFetchRequest:request error:&error];
	if (request) [request release], request = nil;
	if (error) {
		NSLog(@"%@:%s Error fetching parameter: %@" , [self class], (char *)_cmd, error);
		return nil;
	}
	NSMutableDictionary *dict = [[[self defaults] mutableCopy] autorelease];
	for (NSManagedObject *param in params) {
		NSString *name = [param valueForKey:@"name" ];
		NSString *value = [param valueForKey:@"value" ];
		[dict setValue: value forKey:name];
	}
	return dict;
}
//END:allParameters

/*
 Like -allParameters, -allParameterNames is a convenience method that returns
 an NSArray of the keys currently set or defaulted. Just like the
 -allParameters method, it retrieves all the parameter NSManagedObject
 objects and loops over them. Within that loop, it adds the name property
 to an NSMutableArray derived from the defaultsNSDictionary.
 */

//START:allParameterNames
- (NSArray*)allParameterNames;
{
	NSManagedObjectContext *moc;
	NSError *error = nil;
	moc = [[self associatedDocument] managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"DocPrefParameter"
								   inManagedObjectContext:moc]];
	NSArray *params = [moc executeFetchRequest:request error:&error];
	if (request) [request release], request = nil;
	if (error) {
		NSLog(@"%@:%s Error fetching parameter: %@" , [self class], (char *)_cmd, error);
		return nil;
	}
	NSMutableArray *keys = [[[[self defaults] allKeys] mutableCopy] autorelease];
	for (NSManagedObject *param in params) {
		NSString *name = [param valueForKey:@"name" ];
		[keys addObject:name];
	}
	return keys;
}
//END:allParameterNames

#pragma mark -
#pragma mark Defaults

//START:getDefaultPrefs
- (NSDictionary *)getDefaultPrefs {
	NSMutableDictionary *defPrefs = [NSMutableDictionary dictionary];
	
	[defPrefs setValue:@"Default Prefs" forKey:@"prefStatus"];
	
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"displayScoresWithCurve"];
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"beepForScoresExceedingMax"];
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"printGrid"];
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"monday"];
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"tuesday"];
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"wednesday"];
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"thursday"];
	[defPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"friday"];
	[defPrefs setValue:[NSNumber numberWithBool:NO] forKey:@"saturday"];
	[defPrefs setValue:[NSNumber numberWithBool:NO] forKey:@"sunday"];
	
	[defPrefs setValue:[NSNumber numberWithInteger:0] forKey:@"tardyPenalty"];
	[defPrefs setValue:[NSNumber numberWithInteger:0] forKey:@"absentPenalty"];
	[defPrefs setValue:[NSNumber numberWithInteger:0] forKey:@"latePenalty"];
	[defPrefs setValue:[NSNumber numberWithInteger:0] forKey:@"printNamesAndID"];
	[defPrefs setValue:[NSNumber numberWithInteger:0] forKey:@"tardiesForAbsence"];
	
	[defPrefs setValue:@"" forKey:@"finalCurve"];
	[defPrefs setValue:@"" forKey:@"schoolName"];
	[defPrefs setValue:@"" forKey:@"schoolPhone"];
	[defPrefs setValue:@"" forKey:@"schoolHomePage"];
	[defPrefs setValue:@"" forKey:@"courseName"];
	[defPrefs setValue:@"" forKey:@"courseDescription"];
	[defPrefs setValue:@"" forKey:@"courseLongNotes"];
	[defPrefs setValue:@"" forKey:@"teacherName"];
	[defPrefs setValue:@"" forKey:@"teacherDepartment"];
	[defPrefs setValue:@"" forKey:@"teacherWorkPhone"];
	[defPrefs setValue:@"" forKey:@"teacherEmail"];
	[defPrefs setValue:@"" forKey:@"teacherHomePage"];
	[defPrefs setValue:@"" forKey:@"teacherOfficeHours"];
	
	// Document Passowrd
	[defPrefs setValue:@"" forKey:@"password"];
	
	// Printing & Export Header
	[defPrefs setValue:@"<insert name>\n<insert class name>: <insert class description>" forKey:@"exportHeader"];
	
	// Course Calendar
	[defPrefs setValue:[DateUtils today] forKey:@"courseBegin"];
	[defPrefs setValue:[DateUtils today] forKey:@"courseEnd"];	
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[NSSet set]] forKey:@"excludedClassDays"];

	// Color Coding Attendance
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[[NSColor blueColor] colorWithAlphaComponent:.5]] forKey:@"excusedColor"];
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[[NSColor greenColor] colorWithAlphaComponent:.5]] forKey:@"absentColor"];
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[[NSColor yellowColor] colorWithAlphaComponent:.5]] forKey:@"tardyColor"];
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[[NSColor orangeColor] colorWithAlphaComponent:.5]] forKey:@"lateColor"];
	
	// Window Frame
	[defPrefs setValue:NSStringFromRect(NSMakeRect(165, 270, 742, 613)) forKey:@"document_frame"];

	// Letter Grades
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[LetterGradeLookup defaultLetterGradeArray]] forKey:@"letter_grades"];
	
	// Event Notification
	NSDictionary *notificationData = [NSDictionary dictionaryWithObjects:
									  [NSArray arrayWithObjects:[NSArray array], [NSDictionary dictionary], nil]
																 forKeys:[NSArray arrayWithObjects:@"notificationArray",@"loggedMessages",nil]];
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:notificationData] forKey:@"notificationData"];	

	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionary]] forKey:@"attendancePrinterSettings"];	
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionary]] forKey:@"attendanceExporterSettings"];	
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionary]] forKey:@"printerSettings"];	
	[defPrefs setValue:[NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionary]] forKey:@"exportingSettings"];	
	
	/*
	 
	 // We set up the default settings every time we initialize a document, so we don't save defaults to disk.
	 
	 NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	 [defaults setValue:@"Default Prefs" forKey:@"prefStatus"];
	 
	 [defaults setValue:[NSNumber numberWithBool:YES] forKey:@"default1"];
	 [defaults setValue:[NSNumber numberWithInteger:6] forKey:@"seating_chart_rows"];
	 [defaults setValue:[NSNumber numberWithInteger:6] forKey:@"seating_chart_cols"];
	 [defaults setValue:[NSNumber numberWithInteger:6] forKey:@"seating_chart_queue_rows"];
	 [defaults setValue:[NSNumber numberWithInteger:1] forKey:@"seating_chart_queue_cols"];
	 
	 [defaults setValue:[NSArray array] forKey:@"seating_chart_cells"];
	 [defaults setValue:[NSArray array] forKey:@"seating_chart_queue_cells"];
	 [defaults setValue:[GRLLetterGradeDS defaultLetterGradeArray] forKey:@"letter_grades"];
	 
	 [defaults setValue:[NSMutableDictionary dictionary] forKey:@"preferences"];
	 [_preferences setDefaults:defaults];
	 //END:setDefaults
	 */	
	
	
	return defPrefs;
}
//END:getDefaultPrefs

- (NSColor *)colorForKey:(NSString *)colorKey {
	return [NSKeyedUnarchiver unarchiveObjectWithData:[self valueForKey:colorKey]];
}

- (NSString *)resolveStringAgainstPrefs:(NSString *)message
{
    NSString *str = nil;
	
	str = [self valueForKey:@"courseName"];
	message = [[message componentsSeparatedByString:@"<insert class name>"] componentsJoinedByString:str];
    
	str = [self valueForKey:@"courseDescription"];
	message = [[message componentsSeparatedByString:@"<insert class description>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"courseLongNotes"];
	message = [[message componentsSeparatedByString:@"<insert class description long>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"schoolHomePage"];
	message = [[message componentsSeparatedByString:@"<insert school homepage>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"schoolName"];
	message = [[message componentsSeparatedByString:@"<insert school name>"] componentsJoinedByString:str];

	str = [self valueForKey:@"schoolPhone"];
	message = [[message componentsSeparatedByString:@"<insert school phone number>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"teacherEmail"];
	message = [[message componentsSeparatedByString:@"<insert email address>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"teacherDepartment"];
	message = [[message componentsSeparatedByString:@"<insert department>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"teacherWorkPhone"];
	message = [[message componentsSeparatedByString:@"<insert work phone number>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"teacherName"];
	message = [[message componentsSeparatedByString:@"<insert name>"] componentsJoinedByString:str];

	str = [self valueForKey:@"teacherOfficeHours"];
	message = [[message componentsSeparatedByString:@"<insert office hours>"] componentsJoinedByString:str];
	
	str = [self valueForKey:@"teacherHomePage"];
	message = [[message componentsSeparatedByString:@"<insert homepage>"] componentsJoinedByString:str];
    
	return message;
}

#pragma mark -
#pragma mark Course Schedule

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (keyPath && [keyPath length] && [scheduleKeys containsObject:keyPath]) {
		/*
		 if ([change valueForKey:NSKeyValueChangeKindKey] == NSKeyValueChangeSetting) {
		 id newVal = [change valueForKey:NSKeyValueChangeNewKey];
		 }*/
		[self resetAllClassDays:self];	// our key is one that affects our class schedule
	}
}

- (NSInteger)classDays
{
    return  [[self valueForKey:@"sunday"]boolValue]*1 + 
	[[self valueForKey:@"monday"]boolValue]*2 + 
	[[self valueForKey:@"tuesday"]boolValue]*4 + 
	[[self valueForKey:@"wednesday"]boolValue]*8 + 
	[[self valueForKey:@"thursday"]boolValue]*16 + 
	[[self valueForKey:@"friday"]boolValue]*32 + 
	[[self valueForKey:@"saturday"]boolValue]*64;
}


- (IBAction)resetAllClassDays:(id)sender {
	if (m_classDaysArray) {
		[m_classDaysArray removeAllObjects];
	}
	[self determineClassDays];		// build a new list of class days

	[self resetNumberOfClassDaysThusFar];
}


- (NSInteger)numberOfClassDaysThusFar {
	if (m_classDaysArray && [m_classDaysArray count] == 0)
		[self determineClassDays];
	
	if (numberOfClassDaysThusFar < 0) {
		[self resetNumberOfClassDaysThusFar];
	}
	return numberOfClassDaysThusFar;
}


// get the number of class days thus far
- (void)resetNumberOfClassDaysThusFar {
	
	if (!m_classDaysArray || [m_classDaysArray count] == 0) {
		NSLog(@"determineClassDaysThusFar broken, something was nil");
		return;
	}

	NSInteger numDays = 0;
	NSDate *today = [DateUtils today];
	NSDate *begin = [m_classDaysArray objectAtIndex:0];
	NSDate *end = [m_classDaysArray lastObject];
	
	if ([DateUtils isEarlier:today thanDate:begin])		// today is set before the first day of class
		numDays = 0;										
	else if ([DateUtils isEarlier:end thanDate:today])	// today is after the semester's over, return the total class schedule
		numDays = [m_classDaysArray count];			
	else {														// the date is within our schedule, so start counting.
#if		EXCLUDE_ATTENDANCE == EXCLUDE_REDUCE_NUMBER_OF_CLASSES
		NSSet *excludedClassDays = [NSKeyedUnarchiver unarchiveObjectWithData:[self valueForKey:@"excludedClassDays"]];
		if (!excludedClassDays) excludedClassDays = [NSSet set];
#endif		
		for(NSDate *aDay in m_classDaysArray)
		{
			if ([DateUtils isEarlier:[m_classDaysArray lastObject] thanDate:aDay])
				break;											// stop!!! we've gone far enough!!!

#if		EXCLUDE_ATTENDANCE == EXCLUDE_REDUCE_NUMBER_OF_CLASSES
			if (![excludedClassDays containsObject:aDay])	// if we've excluded this day (i.e. snow days) then don't count it.
#endif
				numDays++;			
		}	
	}
	if (numDays != numberOfClassDaysThusFar) {
		[self willChangeValueForKey:@"numberofClassDaysThusFar"];
		numberOfClassDaysThusFar = numDays;
		[self didChangeValueForKey:@"numberofClassDaysThusFar"];
	}
}

- (void)determineClassDays {
	if (!m_classDaysArray)
		return NSLog(@"determineClassDays broken, something was nil");
	
	NSDate *aDay = [self valueForKey:@"courseBegin"];
	
	[self willChangeValueForKey:@"classDaysList"];
	while([DateUtils isEarlier:aDay thanDate:[self valueForKey:@"courseEnd"]]) // if we've reached the last day in the period, stop the loop
	{
		// Checks to see if our day falls on a class day...
		//NSInteger dayOfWeek = [DateUtils dayOfWeekForDate:aDay];
		//if((NSInteger)pow(2,dayOfWeek) & self.classDays)
		
		// This is a cute trick ... we get a en_US style string for our date, then use that as a lookup key for our schedule weekday preferences, to see if it's a good class day.
		if ([[self valueForKey:[[aDay localWeekdayString] lowercaseString]] boolValue])
			[m_classDaysArray addObject:aDay];
			//[m_classDaysArray addObject:[DateUtils roundOffTimeFromDate:aDay]]; // probably unnecessary
		
		// Now we advance one day in the period
		aDay = [DateUtils setDaysFromDate:aDay numDays:1];
	}	
	[self didChangeValueForKey:@"classDaysList"];
}

- (IBAction)validateCourseBegin {
	NSDate *anEnd = [self valueForKey:@"courseEnd"];
	NSDate *aBegin = [self valueForKey:@"courseBegin"];
	if ([aBegin compare:anEnd] == NSOrderedDescending) {	// aBegin is later than anEnd
		[self setValue:anEnd forKey:@"courseBegin"]; 
	}
	return;
}

- (IBAction)validateCourseEnd {
	NSDate *anEnd = [self valueForKey:@"courseEnd"];
	NSDate *aBegin = [self valueForKey:@"courseBegin"];
	if ([anEnd compare:aBegin] == NSOrderedAscending) {	// anEnd is earlier than aBegin
		[self setValue:aBegin forKey:@"courseEnd"]; 
	}
	return;
}


- (BOOL)dateInScheduleWithDate:(NSDate*)date
{	
	return ([self.classDaysList containsObject:date]);
}

#pragma mark -
#pragma mark Printing

- (BOOL) printName {
	if ([[self valueForKey:@"printNamesAndID"] integerValue] == 1)
		return NO;
	return YES;
}

- (BOOL) printID {
	if ([[self valueForKey:@"printNamesAndID"] integerValue] == 0)
		return NO;
	return YES;
}
@end
