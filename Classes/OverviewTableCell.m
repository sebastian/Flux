//
//  TransactionTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 20.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "OverviewTableCell.h"


@implementation OverviewTableCell

@synthesize month;
@synthesize year;
@synthesize amount;


#define PRICE_FIELD_MARGIN 15.0
#define PRICE_FIELD_MAX_WIDTH 120.0

-(void)updateCellWithDate:(NSDate*)date andAmount:(NSString*)amountString {

//	// Resize the amount text field
//	CGSize textSize = [amountString sizeWithFont:amount.font];
//	
//	CGRect cellSize = [self frame];
//	
//	float x_location = cellSize.size.width - PRICE_FIELD_MAX_WIDTH - PRICE_FIELD_MARGIN;
//	float price_field_width = PRICE_FIELD_MAX_WIDTH;
//	
//	if (textSize.width < PRICE_FIELD_MAX_WIDTH) {
//		// Adjust new price size
//		x_location = cellSize.size.width - PRICE_FIELD_MARGIN - textSize.width;
//		price_field_width = textSize.width;
//	}
//	
//	CGRect price_frame = [amount frame];
//	price_frame.origin.x = x_location;
//	price_frame.size.width = price_field_width;
//	
//	[amount setFrame:price_frame];

	///////////////////////////////////////////
	// Get the calendar values
	NSLocale * userLocale = [NSLocale currentLocale];
	NSCalendar * currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents * components = [currentCalendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
	
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setLocale:userLocale];
	
	NSString * monthName = [[dateFormatter monthSymbols] objectAtIndex:components.month-1];
		
	/*
	 Make the month and year have the right size
	 */
	
	// Month
	// Resize:
	CGSize monthTextSize = [monthName sizeWithFont:month.font];
	CGRect monthFrame = month.frame;
	monthFrame.size.width = monthTextSize.width;
	month.frame = monthFrame;
	
	// Year move to right location
	float x_location = monthFrame.origin.x + monthFrame.size.width + 8;
	CGRect yearFrame = year.frame;
	yearFrame.origin.x = x_location;
	year.frame = yearFrame;
	
	// Set the values
	year.text = [NSString stringWithFormat:@"%i", components.year];
	month.text = monthName;
	amount.text = amountString;

}

-(void)setValuesWithTransaction:(Transaction*)transaction {

	
	month.text = @"Something";
	amount.text = [transaction toString];
	
	// Resize the price field to match the price value
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:17.0];
	NSString * text = [transaction toString];
	
	CGSize textSize = [text sizeWithFont:font];
	
	CGRect cellSize = [self frame];
	
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
	[month release];
	[year release];
	[amount release];

	[super dealloc];
}

@end
