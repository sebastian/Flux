// 
//  Location.m
//  Finance
//
//  Created by Sebastian Probst Eide on 01.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Location.h"
#import "Tag.h"

// coalesce these into one @interface Location (CoreDataGeneratedPrimitiveAccessors) section
@interface Location (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveLocation;
- (void)setPrimitiveLocation:(id)value;

@end


@implementation Location 

@dynamic location;
@dynamic tag;
@dynamic date;
@dynamic latitude;

#pragma mark
#pragma mark -
#pragma mark Setup and teardown
- (void)awakeFromInsert {
	// Set date to the current date
	self.date = [NSDate date];
}

- (void)setLocation:(CLLocation*)location {
    [self willChangeValueForKey:@"location"];
    [self setPrimitiveLocation:location];
    [self didChangeValueForKey:@"location"];
	
	self.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
}

@end
