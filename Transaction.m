// 
//  transaction.m
//  Finance
//
//  Created by Sebastian Probst Eide on 09.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Transaction.h"


@implementation Transaction 

@dynamic expense;
@dynamic kroner;
@dynamic ore;

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
	has_ore = NO;
	numOfOre = 0;
	
	// Set date to the current date
	self.date = [NSDate date];
	
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
	
	self.transactionDescription = @"";
	self.tags = @"";
}
-(void)dealloc {
	[formatter dealloc];
	[super dealloc];
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
-(NSString*)toString {
	// TODO: Probably not optimal...
	//NSNumber * number = [NSNumber numberWithDouble:[self.kroner doubleValue] + [self.ore doubleValue]/100];
	NSNumber * number = [NSNumber numberWithDouble:[self.kroner doubleValue]/100];
	return [self numberToMoney:number];
}
-(NSString*)numberToMoney:(NSNumber*)number {
	if (formatter == nil) {
		self.formatter = [[NSNumberFormatter alloc] init];
	}

	// TODO: Set it to something smart based on where the user is 
	// and also based on what the user chooses manually...
	[formatter setCurrencyCode:@"EUR"];
	
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	return [formatter stringFromNumber:number];
}
-(NSString*)tagsAndDescription {
	NSMutableString * tagsAndDescription = [[[NSMutableString alloc] init] autorelease];
	[tagsAndDescription appendString:NSLocalizedString(@"Tags and description", @"Tags and description")];
	[tagsAndDescription appendFormat:@": %@", self.tags];
	return tagsAndDescription;
}


#pragma mark
#pragma mark -
#pragma mark Alter numeric value
-(void)addNumber:(NSInteger)num {

	if (has_ore == NO) {
		NSInteger kroner = [self.kroner integerValue] * 10 + num; 
		self.kroner = [NSNumber numberWithInt:kroner];		
	} else {
		// Can it be added to?
		if (numOfOre == 0) {
			self.ore = [NSNumber numberWithInt:num*10];
			numOfOre += 1;
		} else if (numOfOre == 1) {
			self.ore = [NSNumber numberWithInt:[self.ore integerValue] + num];
			numOfOre += 1;
		} else {
			NSLog(@"Tried to add a decimal after it had already added two!");
		}
	}
		
}
-(void)eraseOneNum {
	if (has_ore == YES) {
		// Do øre stuff
		switch (numOfOre) {
			case 1:
				self.ore = [NSNumber numberWithInt:0];
				break;
			case 2:
				self.ore = [NSNumber numberWithInt:(([self.ore intValue] / 10) * 10)];
				break;
			default:
				break;
		}
		
		numOfOre -= 1;
		if (numOfOre < 1) {has_ore = NO;}
		
	} else {
		// Remove from the main num
		self. kroner = [NSNumber numberWithInt:[self.kroner intValue] / 10];
	}
}
-(void)addDecimal {
	has_ore = YES;
}



#pragma mark
#pragma mark -
#pragma mark Methods for keyboard state and general state
// Methods for display
-(bool)hasDecimals {
	return has_ore;
}
-(bool)canBeAddedTo {
	if ([self.kroner intValue] / 100000000 != 0 && has_ore == NO) {return NO;}
	if (has_ore == NO) {return YES;}
	if (has_ore == YES && numOfOre < 2) {return YES;} 
	
	return NO;
	
}
-(bool)needsDeleteButton {
	if ([self.kroner intValue] == 0 && has_ore == NO) {return NO;} 
	return YES;
}

@end
