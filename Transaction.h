//
//  transaction.h
//  Finance
//
//  Created by Sebastian Probst Eide on 09.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Transaction :  NSManagedObject  
{
}

// Amount
@property (nonatomic, retain) NSNumber * kroner;
@property (nonatomic, retain) NSNumber * ore;

// Is it an expense (or income)? YES / NO
@property (nonatomic, retain) NSNumber * expense;

// Location
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;

@property (nonatomic, retain) NSString * currency;

// When was it recorded?
@property (nonatomic, retain) NSDate * date;

// Methods
-(NSString*)toString;

@end



