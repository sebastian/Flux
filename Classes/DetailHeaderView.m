//
//  DetailTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailHeaderView.h"


@implementation DetailHeaderView

@synthesize date;

- (void)dealloc {
	[date release];
    [super dealloc];
}


@end
