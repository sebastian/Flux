//
//  transaction.h
//  Finance
//
//  Created by Sebastian Probst Eide on 09.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface Transaction :  NSManagedObject  
{
	NSNumberFormatter * formatter;
}


@property (nonatomic, retain) NSString * transactionDescription;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * autotags;

// Amount
@property (nonatomic, retain) NSNumber * kroner;

// Is it an expense (or income)? YES / NO
@property (nonatomic, retain) NSNumber * expense;

// Location
@property (nonatomic, retain) CLLocation * location;

@property (nonatomic, retain) NSString * currency;

// When was it recorded?
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * yearMonth;
@property (nonatomic, retain) NSNumber * day;

// General non savable parameters
@property (nonatomic, retain) NSNumberFormatter * formatter;

// Methods
-(NSString*)amountInLocalCurrency;
-(void)addNumber:(NSInteger)num;
-(void)eraseOneNum;
-(NSString*)formattedDate;
-(NSString*)longFormattedDate;
-(NSString*)timeToString;
-(NSString*)descriptionAndTags;
-(NSString*)amountInBaseCurrency;
-(double)normalizedAmount;
-(NSNumber*)kronerInBaseCurrency;

// Methods for display
-(bool)canBeAddedTo;
-(bool)needsDeleteButton;

-(NSString*)numberToMoney:(NSNumber*)number;
@end