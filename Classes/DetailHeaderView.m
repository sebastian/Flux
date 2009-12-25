//
//  DetailTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailHeaderView.h"
#import "CacheMasterSingleton.h"

@implementation DetailHeaderView

@synthesize date, amount, monthYear;

- (void) setDate:(NSString*)_date amount:(NSString*)_amount andMonthYear:(NSString*)_monthYear {
	self.date = _date;
	self.amount = _amount;
	self.monthYear = _monthYear;
	[self setNeedsDisplay];
}

- (void)dealloc {
	[monthYear release];
	[amount release];
	[date release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	
	CGPoint topCorner;
	topCorner.x = 0;
	topCorner.y = 0;
	
	[[[CacheMasterSingleton sharedCacheMaster] detailHeaderViewBackgroundImage] drawAtPoint:topCorner];
	
	CGRect drawTextRect;
	drawTextRect.origin.y = 4;
	drawTextRect.size.height = 19;
	
	// Set the black colour
	[[[CacheMasterSingleton sharedCacheMaster] detailHeaderViewBlackColor] set];
	
	// Draw the date
	drawTextRect.origin.x = 8;
	drawTextRect.size.width = 22;	
	[date drawInRect:drawTextRect 
			withFont:[[CacheMasterSingleton sharedCacheMaster] detailHeaderViewFont] 
	   lineBreakMode:UILineBreakModeTailTruncation 
		   alignment:UITextAlignmentRight];

	// Draw amount
	drawTextRect.origin.x = 170;
	drawTextRect.size.width = 140;
	[amount drawInRect:drawTextRect 
			  withFont:[[CacheMasterSingleton sharedCacheMaster] detailHeaderViewFont] 
		 lineBreakMode:UILineBreakModeTailTruncation 
			 alignment:UITextAlignmentRight];

	// Set the gray colour
	[[[CacheMasterSingleton sharedCacheMaster] detailHeaderViewGrayColor] set];
	
	// Draw MonthYear
	drawTextRect.origin.x = 35;
	drawTextRect.size.width = 130;
	[monthYear drawInRect:drawTextRect 
				 withFont:[[CacheMasterSingleton sharedCacheMaster] detailHeaderViewFont] 
			lineBreakMode:UILineBreakModeTailTruncation 
				alignment:UITextAlignmentLeft];

	
}

@end
