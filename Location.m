// 
//  Location.m
//  Finance
//
//  Created by Sebastian Probst Eide on 01.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Location.h"

#import "Tag.h"

@implementation Location 

@dynamic location;
@dynamic tag;
@dynamic date;

#pragma mark
#pragma mark -
#pragma mark Setup and teardown
- (void)awakeFromInsert {
	// Set date to the current date
	self.date = [NSDate date];
}


@end
