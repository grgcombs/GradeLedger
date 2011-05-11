// 
//  StudentAttributes.m
//  GradeLedger
//
//  Created by Gregory Combs on 4/18/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "StudentAttributes.h"

#import "StudentObj.h"

@implementation StudentAttributes 

@dynamic name;
@dynamic value;
@dynamic student;

+ (NSArray *)keysToBeCopied {
    static NSArray *keysToBeCopied = nil;
    if (keysToBeCopied == nil) {
        keysToBeCopied = [[NSArray alloc] initWithObjects:
						  @"name", @"value", nil];
    }
    return keysToBeCopied;
}

- (NSDictionary *)dictionaryRepresentation {
    return [self dictionaryWithValuesForKeys:[[self class] keysToBeCopied]];
}

- (NSString *)stringDescription {
    NSString *stringDescription = self.name;
    NSString *valueString = self.value;
    stringDescription = [stringDescription stringByAppendingFormat:
						 @"; Value: %@", valueString];
    return stringDescription;
}

@end
