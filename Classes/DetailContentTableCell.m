//
//  DetailContentTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailContentTableCell.h"


@implementation DetailContentTableCell
@synthesize what, amount;

- (void)dealloc {
	[what release];
	[amount release];
	
    [super dealloc];
}


@end
