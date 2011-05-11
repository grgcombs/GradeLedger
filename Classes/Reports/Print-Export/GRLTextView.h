//
//  GRLTextView.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
#import "GRLDrawObject.h"

@interface GRLTextView : NSView
{
    NSArray *textObjects;
    NSInteger pageCount;
}

@property (nonatomic, retain) NSArray *textObjects;
@property (nonatomic) NSInteger pageCount;
@end