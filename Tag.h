//
//  Tag.h
//  Finance
//
//  Created by Sebastian Probst Eide on 01.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Location;

@interface Tag :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* location;

@end


@interface Tag (CoreDataGeneratedAccessors)
- (void)addLocationObject:(Location *)value;
- (void)removeLocationObject:(Location *)value;
- (void)addLocation:(NSSet *)value;
- (void)removeLocation:(NSSet *)value;

@end

