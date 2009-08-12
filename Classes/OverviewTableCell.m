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
	
	NSInteger itemPaddingSpace = 8;
	
	// Month
	// Resize:
	CGSize monthTextSize = [monthName sizeWithFont:month.font];
	CGRect monthFrame = month.frame;
	monthFrame.size.width = monthTextSize.width;
	month.frame = monthFrame;
	
	// Year move to right location
	float x_location = monthFrame.origin.x + monthFrame.size.width + itemPaddingSpace;
	CGRect yearFrame = year.frame;
	yearFrame.origin.x = x_location;
	year.frame = yearFrame;
	
	// Set the values
	year.text = [NSString stringWithFormat:@"%i", components.year];
	month.text = [monthName capitalizedString]; 
	amount.text = amountString;
	
	// Resize the amount text field to get it as big as possible
	CGRect amountFrame = self.amount.frame;

	amountFrame.size.width = amountFrame.origin.x + amountFrame.size.width - yearFrame.origin.x - yearFrame.size.width - itemPaddingSpace;
	amountFrame.origin.x = yearFrame.origin.x + yearFrame.size.width + itemPaddingSpace;
	
	[amount setFrame:amountFrame];
	

}

-(void)dealloc {	
	[month release];
	[year release];
	[amount release];

	[super dealloc];
}

@end
