//
//  GRLRotatedTextObject.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLRotatedTextObject.h"


@implementation GRLRotatedTextObject

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)atr rect:(NSRect)drawRect pageNumber:(NSInteger)num degrees:(CGFloat)degs {
	
	if ((self = [super initWithString:str attributes:atr rect:drawRect pageNumber:num])) {
		degrees = degs;
	}
	
	return self;
}

+ (id)textObjectWithString:(NSString *)str attributes:(NSDictionary *)atr rect:(NSRect)drawRect pageNumber:(NSInteger)num degrees:(CGFloat)degs
{
	GRLRotatedTextObject *obj = [[GRLRotatedTextObject alloc] initWithString:str attributes:atr rect:drawRect pageNumber:num degrees:degs];

    return [obj autorelease];
}


- (void)drawWithPageCount:(NSInteger)count
{
	if (string) {
		CGFloat rads = degrees * M_PI / 180;

		NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
		NSSize size = [info paperSize];
		size.width -= ([info leftMargin] + [info rightMargin]);
		size.height -= ([info topMargin] + [info bottomMargin]);
		
		size.height *= (count - pageNumber);
		
		NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
		[currentContext saveGraphicsState];
		
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform translateXBy:NSMinX(rect) yBy:NSMinY(rect)+size.height];
		[transform rotateByRadians:rads];
		[transform concat];

		[string drawInRect:NSMakeRect(0,0,NSWidth(rect),NSHeight(rect)) withAttributes:attributes]; 
		
		[currentContext restoreGraphicsState];
	}
}

@synthesize degrees;
@end
