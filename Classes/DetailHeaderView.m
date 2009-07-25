//
//  DetailTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailHeaderView.h"


@implementation DetailHeaderView

@synthesize date, amount;

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGRect areaToDraw = rect;
	areaToDraw.size.height = 2;
	areaToDraw.origin.y = [self frame].size.height - 2;
	
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextFillRect(context, areaToDraw);
}

- (void)dealloc {
	[amount release];
	[date release];
    [super dealloc];
}


@end
