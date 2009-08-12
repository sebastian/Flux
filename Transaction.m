// 
//  transaction.m
//  Finance
//
//  Created by Sebastian Probst Eide on 09.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Transaction.h"
#import "Utilities.h"
#import "CurrencyManager.h"

@interface Transaction (CoreDataGeneratedPrimitiveAccessors)

- (NSDate *)primitiveDate;
- (void)setPrimitiveDate:(NSDate *)value;

@end

@implementation Transaction 

@dynamic expense;
@dynamic kroner;

@dynamic currency;

@dynamic location;

@dynamic yearMonth;
@dynamic day;
@dynamic date;

@dynamic transactionDescription;
@dynamic tags;
@dynamic autotags;

@synthesize formatter;

#pragma mark
#pragma mark -
#pragma mark Setup and teardown
- (void)awakeFromInsert {
	
	// Set date to the current date
	self.date = [NSDate date];
	
	// Set the currency
	self.currency = [[CurrencyManager sharedManager] baseCurrency];
	
	// Set them to empty strings
	self.transactionDescription = @"";
	self.tags = @"";

	self.expense = [NSNumber numberWithBool:YES];
}

- (void)setDate:(NSDate *)value {

    // From the auto generated coreData method
	[self willChangeValueForKey:@"date"];
    [self setPrimitiveDate:value];
    [self didChangeValueForKey:@"date"];
	
	// Set the month and year for easier searching and displaying and most importantly grouping!
	NSCalendar * currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents * components = [currentCalendar components:(NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit) fromDate:self.date];
	
	NSString * yearMonthValue;
	if (components.month < 10) {
		yearMonthValue = [NSString stringWithFormat:@"%4i0%i", components.year, components.month];
	} else {
		yearMonthValue = [NSString stringWithFormat:@"%4i%i", components.year, components.month];
	}
	
	self.day = [NSNumber numberWithInt:components.day];
	self.yearMonth = yearMonthValue;	
	
}

-(void)dealloc {
	[formatter dealloc];
	[super dealloc];
}
-(void)didSave {
	if (!self.isDeleted) {
		/*
		 Tags:
		 Go through all the tags:
		 Check if there already is a tag object by that name
		 YES: Then add the location to it
		 NO: Create it
		 */
		NSArray * tags = [[Utilities toolbox] tagStringToArray:self.tags];
		for (NSString * tag in tags) {
			// Does the tag exist?
			[[Utilities toolbox] addTag:tag location:self.location];
		}		
	}
}
	

#pragma mark
#pragma mark -
#pragma mark Convenience methods
-(NSString*)formattedDate {
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:[NSDateFormatter defaultFormatterBehavior]];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:self.date];
	
}
-(NSString*)longFormattedDate {
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:[NSDateFormatter defaultFormatterBehavior]];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	return [dateFormatter stringFromDate:self.date];	
}
-(double)normalizedAmount {
	double dAmount = [self.kroner doubleValue]/100;
	if ([self.expense boolValue] == YES) {
		dAmount = dAmount * (-1);
	}
	return dAmount;
}
-(NSString*)amountInLocalCurrency {
	NSNumber * amount = [NSNumber numberWithDouble:[self normalizedAmount]];
	return [[CurrencyManager sharedManager] currencyDescriptionForAmount:amount withFraction:YES currency:self.currency];
}
-(NSString*)amountInBaseCurrency {
	NSNumber * convertedValue = [self kronerInBaseCurrency];
	return [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:convertedValue withFraction:YES];
}
-(NSNumber*)kronerInBaseCurrency {
	double amount = [[CurrencyManager sharedManager] convertValue:[self normalizedAmount] fromCurrency:self.currency];
	return [NSNumber numberWithDouble:amount];
}
-(NSString*)numberToMoney:(NSNumber*)number {
	if (formatter == nil) {
		self.formatter = [[NSNumberFormatter alloc] init];
	}
	
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	return [formatter stringFromNumber:number];
}
-(NSString*)timeToString {	
	NSDateFormatter * dateFormatter = [[Utilities toolbox] dateFormatter];
	return [dateFormatter stringFromDate:self.date];
}
-(NSString*)descriptionAndTags {
	NSString * description = self.transactionDescription;
	if (![self.tags isEqualToString:@""]) {
		description = [[description stringByAppendingFormat:@" (%@)", self.tags] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	return description;
}

#pragma mark
#pragma mark -
#pragma mark Alter numeric value
-(void)addNumber:(NSInteger)num {

	NSInteger kroner = [self.kroner integerValue] * 10 + num; 
	self.kroner = [NSNumber numberWithInt:kroner];		
		
}
-(void)eraseOneNum {
	// Remove from the main num
	self. kroner = [NSNumber numberWithInt:[self.kroner intValue] / 10];
}



#pragma mark
#pragma mark -
#pragma mark Methods for keyboard state and general state
// Methods for display
-(bool)canBeAddedTo {
	if ([self.kroner intValue] / 100000000 != 0) {return NO;}
	return YES;
}
-(bool)needsDeleteButton {
	if ([self.kroner intValue] == 0) {return NO;} 
	return YES;
}

@end
