//
//  GRLTextView.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLTextView.h"
#import "GRLTextObject.h"

@implementation GRLTextView
@synthesize pageCount, textObjects;

- (id)initWithFrame:(NSRect)rect
{
    if((self = [super initWithFrame:rect])) {
        textObjects = nil;
		pageCount = 0;
    }
	return self;
}

- (void)dealloc
{
    self.textObjects = nil;
    [super dealloc];
}


- (void)drawRect:(NSRect)frame
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    
    CGFloat y = NSMinY(frame);
    CGFloat pageHeight = NSHeight(frame);
    CGFloat height = NSHeight([self bounds]);

    NSInteger page = round((height - y)/pageHeight);
    
    GRLTextObject * obj = nil;
    for(obj in textObjects) {
        if([obj pageNumber] == page) {
            [obj drawWithPageCount:pageCount];
		}
	}
}

@end
