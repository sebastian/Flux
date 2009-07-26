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

-(void)setBackgroundColorForCellNumber:(NSInteger)number {	
	if (number % 2 == 0) {
		self.backgroundView.alpha = 1.0;
	} else {
		self.backgroundView.alpha = 0.75;
	}
}

- (void)dealloc {
	[amountBackgroundColor release];
	
	[what release];
	[amount release];
	
    [super dealloc];
}


@end
