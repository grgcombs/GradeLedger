//
//  GRLGrayBox.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLGrayBox.h"

@implementation GRLGrayBox

- (void)drawWithPageCount:(NSInteger)count
{
    NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
    NSSize size = [info paperSize];
    size.width -= ([info leftMargin] + [info rightMargin]);
    size.height -= ([info topMargin] + [info bottomMargin]);
    
    size.height *= (count - pageNumber);

    [[NSColor lightGrayColor] set];
    NSRectFill(NSMakeRect(NSMinX(rect),NSMinY(rect)+size.height,NSWidth(rect),NSHeight(rect)));
}

@end
