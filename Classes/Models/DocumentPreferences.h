//
//  DocumentPreferences.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

/* This object provides NSUserDefaults functionality but with more narrow scope.
 Whereas NSUserDefaults settings are specific to an entire application,
 DocumentPreferences settings are specific to each document for that app.
 
 Whether we are working in a document model or not, we can now access
 persistent store–specific parameters with a single call similar to the
 following:

	NSString *value = [[self preferences] valueForKey:@"exampleKey1" ];
 
 We can also set them with a call similar to the following:
 
	[[self preferences] setValue:@"someValue" forKey:@"someKey" ];

 In both of these examples, we are calling -valueForKey: and 
 -setValue:forKey: directly on the DocumentPreferences object and not worrying about
 whether the value exists. If it does not exist, we will receive a nil. If it
 has been set as a default, we will get the default back, and if we have
 overridden the default or previously set the property, it will be returned.
 
 Lastly, like the NSUserDefaults, the default values are not persisted to
 disk. Therefore, we need to set them every time we initialize the DocumentPreferences
 in the creation of our NSDocument object.
 */

/*
 // BOOL
 @property (retain) NSNumber *displayScoresWithCurve;
 @property (retain) NSNumber *beepForScoresExceedingMax;
 @property (retain) NSNumber *printGrid;
 @property (retain) NSNumber *monday;
 @property (retain) NSNumber *tuesday;
 @property (retain) NSNumber *wednesday;
 @property (retain) NSNumber *thursday;
 @property (retain) NSNumber *friday;
 @property (retain) NSNumber *saturday;
 @property (retain) NSNumber *sunday;
 
 // INTEGER
 @property (retain) NSNumber *tardyPenalty;
 @property (retain) NSNumber *absentPenalty;
 @property (retain) NSNumber *latePenalty;
 @property (retain) NSNumber *printNamesAndID;
 @property (retain) NSNumber *tardiesForAbsence;
 
 // STRING
 @property (retain) NSString *finalCurve;
 @property (retain) NSString *schoolName;
 @property (retain) NSString *schoolPhone;
 @property (retain) NSString *schoolHomePage;
 @property (retain) NSString *courseName;
 @property (retain) NSString *courseDescription;
 @property (retain) NSString *courseLongNotes;
 @property (retain) NSString *teacherName;
 @property (retain) NSString *teacherDepartment;
 @property (retain) NSString *teacherWorkPhone;
 @property (retain) NSString *teacherEmail;
 @property (retain) NSString *teacherHomePage;
 @property (retain) NSString *teacherOfficeHours;
 
 // MISC
 @property (retain) NSColor *excusedColor;
 @property (retain) NSColor *absentColor;
 @property (retain) NSColor *lateColor;
 @property (retain) NSColor *tardyColor;
 @property (retain) NSDate *courseBegin;
 @property (retain) NSDate *courseEnd;
 */


@interface DocumentPreferences : NSObject {
	IBOutlet NSPersistentDocument *_associatedDocument;
	NSDictionary *_defaults;
	
	NSMutableArray *classDaysList;
	NSInteger numberOfClassDaysThusFar;
	NSArray *scheduleKeys;
}

@property (nonatomic, assign) NSPersistentDocument *associatedDocument;

@property (nonatomic, readonly) NSInteger classDays;
@property (nonatomic, readonly) BOOL printName;
@property (nonatomic, readonly) BOOL printID;
@property (nonatomic, readonly) NSInteger numberOfClassDaysThusFar;
@property (nonatomic, readonly) NSInteger numberOfClassDays;

@property (nonatomic, copy) NSMutableArray *classDaysList;
@property (nonatomic, copy) NSArray *scheduleKeys;
@property (nonatomic, copy) NSDictionary *defaults;

//- (id)initWithDocument:(NSPersistentDocument*)associatedDocument;
- (NSArray*)allParameterNames;
- (NSDictionary*)allParameters;
- (NSArray*)allRealParameters;

- (NSColor *)colorForKey:(NSString *)colorKey;

- (NSString *)resolveStringAgainstPrefs:(NSString *)message;

- (void)determineClassDays;
- (IBAction)resetAllClassDays:(id)sender;

- (void)resetNumberOfClassDaysThusFar;
- (NSInteger)numberOfClassDaysThusFar;

- (BOOL)dateInScheduleWithDate:(NSDate*)date;

- (BOOL)printName;
- (BOOL)printID;

- (IBAction)validateCourseBegin;
- (IBAction)validateCourseEnd;

+ (NSManagedObject*)findParameter:(NSString*)name withContext:(NSManagedObjectContext *)moc;
+ (id)valueForPreferenceKey:(NSString*)key context:(NSManagedObjectContext*)context;

@end