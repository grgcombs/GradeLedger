//
//  GRLHelpManager.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLHelpManager.h"


@implementation GRLHelpManager

- (IBAction)menuItemAction:(id)sender
{
	if (helpView) {
		NSString *theFile = [[NSBundle mainBundle] pathForResource:[sender title] ofType:@"rtf"];
		if (theFile && [theFile length]) {
			[helpView readRTFDFromFile:theFile];
			[[helpView window] makeKeyAndOrderFront:nil];
		}
	}
}

@synthesize helpView;
@end
