//
//  DetailContentTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailContentTableCell.h"


@implementation DetailContentTableCell
@synthesize what, amount, amountBackgroundColor;

//- (void)drawRect:(CGRect)rect {
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	
//	CGRect areaToDraw = rect;
//
//	//Fill the whole area with white
//	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
//	CGContextFillRect(context, areaToDraw);
//	
//	
//	// Draw a background for the amount
//	areaToDraw.size.height = rect.size.height;
//	areaToDraw.size.width = rect.size.width - 220;
//	areaToDraw.origin.x = 220;
//	
//	CGContextSetFillColorWithColor(context, [self.amountBackgroundColor CGColor]);
//	CGContextFillRect(context, areaToDraw);	
//	
////	// Draw the divider line
////	areaToDraw.size.height = rect.size.height;
////	areaToDraw.size.width = 1;
////	areaToDraw.origin.x = 220;
////	
////	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
////	CGContextFillRect(context, areaToDraw);
//}

-(void)setBackgroundColorForCellNumber:(NSInteger)number {	
	if (number % 2 == 0) {
		self.backgroundView.alpha = 0.9;
	} else {
		self.backgroundView.alpha = 1.0;
	}
}

- (void)dealloc {
	[amountBackgroundColor release];
	
	[what release];
	[amount release];
	
    [super dealloc];
}


@end
