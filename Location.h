//
//  Location.h
//  Finance
//
//  Created by Sebastian Probst Eide on 01.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Tag;

@interface Location :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain) Tag * tag;
@property (nonatomic, retain) NSNumber * latitude;

@end