//
//  TransactionTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 20.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionTableCell.h"


@implementation TransactionTableCell

@synthesize what;
@synthesize price;

-(void)setValuesWithTransaction:(Transaction*)transaction {

#define PRICE_FIELD_MARGIN 10.0
#define PRICE_FIELD_MAX_WIDTH 75.0
	
	what.text = @"Something";
	price.text = [transaction toString];
	
	// Resize the price field to match the price value
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:17.0];
	NSString * text = [transaction toString];
	
	CGSize textSize = [text sizeWithFont:font];
	
	float x_location = PRICE_FIELD_MARGIN;
	float price_field_width = PRICE_FIELD_MAX_WIDTH;
	
	if (textSize.width < PRICE_FIELD_MAX_WIDTH) {
		// Adjust new price size
		x_location = PRICE_FIELD_MARGIN + PRICE_FIELD_MAX_WIDTH - textSize.width;
		price_field_width = textSize.width;
	}
	
	CGRect price_frame = [price frame];
	price_frame.origin.x = x_location;
	price_frame.size.width = price_field_width;
	
	[price setFrame:price_frame];
	
}

-(void)dealloc {	
	[what release];
	[price release];
	[super dealloc];
}

@end
