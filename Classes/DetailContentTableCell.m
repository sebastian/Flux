//
//  DetailContentTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailContentTableCell.h"
#import "Transaction.h"

@implementation DetailContentTableCell
@synthesize what, amount, time;

- (void)dealloc {
	
	[time release];
	[what release];
	[amount release];
	
    [super dealloc];
}

-(void)configureCellForTransaction:(Transaction*)trs {
	self.time.text = [trs timeToString];
	self.what.text = [trs descriptionAndTags]; 
	self.amount.text = [trs toString];

	// Calculate the right size and location for the what field depending on the 
	// way time is displayed in the users locale
	CGSize timeSize = [self.time.text sizeWithFont:[self.time font]];
	CGRect timeFrame = self.time.frame;
	timeFrame.size.width = timeSize.width;

	int margin_right = 40;
	CGSize amountSize = [self.amount.text sizeWithFont:[self.amount font]];
	CGRect amountFrame = self.amount.frame;
	amountFrame.size.width = amountSize.width;
	amountFrame.origin.x = 320 - margin_right - amountFrame.size.width;
	
	CGRect whatFrame = self.what.frame;
	int margin = 8;
	whatFrame.size.width = amountFrame.origin.x - margin - timeFrame.origin.x - timeFrame.size.width - margin;
	whatFrame.origin.x = timeFrame.origin.x + timeFrame.size.width + margin;
	
	self.time.frame = timeFrame;
	self.what.frame = whatFrame;
	self.amount.frame = amountFrame;
		
}

@end
