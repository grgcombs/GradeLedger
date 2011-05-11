//
//  StudentAttributes.h
//  GradeLedger
//
//  Created by Gregory Combs on 4/18/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

@class StudentObj;

@interface StudentAttributes :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) StudentObj * student;

// For Copy/Paste Support
+ (NSArray *)keysToBeCopied;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)stringDescription;

@end



