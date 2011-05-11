//
//  GRLScrollView.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//


@interface GRLScrollView : NSScrollView 
{
    IBOutlet NSScrollView *partner1;
    IBOutlet NSScrollView *partner2;
    
    NSClipView *selfClip;
    NSClipView *partner1Clip;
    NSClipView *partner2Clip;
    
    //NSScroller *vertScroller;
    //NSScroller *horScroller;
}

@property (retain) NSScrollView *partner1;
@property (retain) NSScrollView *partner2;
@property (retain) NSClipView *selfClip;
@property (retain) NSClipView *partner1Clip;
@property (retain) NSClipView *partner2Clip;
//@property (retain) NSScroller *vertScroller;
//@property (retain) NSScroller *horScroller;
@end
