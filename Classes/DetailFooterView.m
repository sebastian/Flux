//
//  DetailFooterTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailFooterView.h"


@implementation DetailFooterView

@synthesize totalAmount;

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect areaToDraw = rect;
	areaToDraw.size.height = 2;
	areaToDraw.origin.y = 0;
	
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextFillRect(context, areaToDraw);
}

- (void)dealloc {
	[totalAmount release];
    [super dealloc];
}


@end
