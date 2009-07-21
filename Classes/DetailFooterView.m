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

- (void)dealloc {
	[totalAmount release];
    [super dealloc];
}


@end
