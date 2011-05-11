//
//  GRLScrollView.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLScrollView.h"


@implementation GRLScrollView

- (void)awakeFromNib
{
	[super awakeFromNib]; // normally you should call this to give supers a chance to finalize
	
    //vertScroller = [[[GRLScroller alloc] initWithFrame:[[self verticalScroller] frame]] autorelease];
    //[self setVerticalScroller:vertScroller];
    //[self setHasVerticalScroller:YES];
    
    //horScroller = [[[GRLScroller alloc] initWithFrame:[[self horizontalScroller] frame]] autorelease];
    //[self setHorizontalScroller:horScroller];
    //[self setHasHorizontalScroller:YES];
    
    
    selfClip = (NSClipView *)[[self documentView] superview];
    partner1Clip = (NSClipView *)[[partner1 documentView] superview];
    partner2Clip = (NSClipView *)[[partner2 documentView] superview];
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView
{
	[super reflectScrolledClipView:aClipView];
	
	NSRect vis = [aClipView documentVisibleRect];
	
	int x = vis.origin.x;
	int y = vis.origin.y;
	
	[[partner1 documentView] scrollRectToVisible:NSMakeRect(0,y,NSWidth(vis), NSHeight(vis))];
	[[partner2 documentView] scrollRectToVisible:NSMakeRect(x,0,NSWidth(vis), NSHeight(vis))];
	
	[partner1 setNeedsDisplay:YES];
	[partner2 setNeedsDisplay:YES];
}

@synthesize partner1;
@synthesize partner2;
@synthesize selfClip;
@synthesize partner1Clip;
@synthesize partner2Clip;
//@synthesize vertScroller;
//@synthesize horScroller;
@end
