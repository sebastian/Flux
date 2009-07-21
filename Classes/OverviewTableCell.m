//
//  TransactionTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 20.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "OverviewTableCell.h"


@implementation OverviewTableCell

@synthesize when;
@synthesize amount;

-(void)setValuesWithTransaction:(Transaction*)transaction {

#define PRICE_FIELD_MARGIN 15.0
#define PRICE_FIELD_MAX_WIDTH 120.0
	
	when.text = @"Something";
	amount.text = [transaction toString];
	
	// Resize the price field to match the price value
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:17.0];
	NSString * text = [transaction toString];
	
	CGSize textSize = [text sizeWithFont:font];
	
	CGRect cellSize = [self frame];
	
	NSLog(@"Frame width and height: %f, %f", cellSize.size.width, cellSize.size.height);
	
	float x_location = cellSize.size.width - PRICE_FIELD_MAX_WIDTH - PRICE_FIELD_MARGIN;
	float price_field_width = PRICE_FIELD_MAX_WIDTH;
	
	if (textSize.width < PRICE_FIELD_MAX_WIDTH) {
		// Adjust new price size
		x_location = cellSize.size.width - PRICE_FIELD_MARGIN - textSize.width;
		price_field_width = textSize.width;
	}
	
	CGRect price_frame = [amount frame];
	price_frame.origin.x = x_location;
	price_frame.size.width = price_field_width;
	
	[amount setFrame:price_frame];
	
}

-(void)dealloc {	
	[when release];
	[amount release];
	[super dealloc];
}

@end
