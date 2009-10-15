// 
//  Tag.m
//  Finance
//
//  Created by Sebastian Probst Eide on 01.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Tag.h"

#import "Location.h"

@implementation Tag 

@dynamic name;
@dynamic location;
@dynamic autotag;

- (NSComparisonResult)compareAmountOfLocations:(id)otherTag {
	if ([[self location] count] < [[otherTag location] count]) {return NSOrderedDescending;}
	if ([[self location] count] > [[otherTag location] count]) {return NSOrderedAscending;}
	return NSOrderedSame;
}

@end
