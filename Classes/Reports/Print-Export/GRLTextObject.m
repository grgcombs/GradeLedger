//
//  GRLTextObject.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLTextObject.h"

@implementation GRLTextObject

+ (id)textObjectWithString:(NSString *)str attributes:(NSDictionary *)atr rect:(NSRect)drawRect pageNumber:(NSInteger)num
{
    GRLTextObject *obj = [[GRLTextObject alloc] initWithString:str attributes:atr rect:drawRect pageNumber:num];
    
    return [obj autorelease];
}

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs rect:(NSRect)drawRect pageNumber:(NSInteger)num {
	if ((self = [super init])) {
		string = [str retain];
		attributes = [attrs retain];
		rect = drawRect;
		pageNumber = num;
	}
	return self;
}

- (void)dealloc
{
	self.string = nil;
	self.attributes = nil;
    [super dealloc];
}

- (void)drawWithPageCount:(NSInteger)count
{
    NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
    NSSize size = [info paperSize];
    size.width -= ([info leftMargin] + [info rightMargin]);
    size.height -= ([info topMargin] + [info bottomMargin]);
    
    size.height *= (count - pageNumber);

	if (string && attributes) {
		[string drawInRect:NSMakeRect(NSMinX(rect),NSMinY(rect)+size.height,NSWidth(rect),NSHeight(rect)) withAttributes:attributes]; 
	}
}

@synthesize string;
@synthesize attributes;
@end
