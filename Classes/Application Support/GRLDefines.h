//  GRLDefines.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
#ifndef __GRLDEFINES__H__
#define __GRLDEFINES__H__

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

typedef enum GRLCode {
    GRLUnknown = -1,
    GRLPresent =	0,
    GRLExcused =	1,
    GRLAbsent	=	2,
    GRLLate =		3,
    GRLTardy =		4,
    GRLCut =		5
} GRLCode;

typedef enum GRLCatTreatment {
    GRLTreatNone		= 0,
    GRLTreatDropLow		= 1,
    GRLTreatAttend		= 2,
    GRLTreatExCred		= 3,
} GRLCatTreatment;

#define EXCLUDE_MARK_EXCUSED 1
#define EXCLUDE_REDUCE_NUMBER_OF_CLASSES	2

	#define EXCLUDE_ATTENDANCE EXCLUDE_MARK_EXCUSED
//	#define EXCLUDE_ATTENDANCE EXCLUDE_REDUCE_NUMBER_OF_CLASSES

#endif