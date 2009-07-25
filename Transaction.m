// 
//  transaction.m
//  Finance
//
//  Created by Sebastian Probst Eide on 09.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Transaction.h"


@implementation Transaction 

@dynamic lat;
@dynamic expense;
@dynamic kroner;
@dynamic currency;
@dynamic lng;
@dynamic date;
@dynamic ore;
@dynamic description;
@dynamic tags;

@synthesize formatter;

// This method isn't called anyway, so it is a joke...

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
	self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
	if (self) {
		has_ore = NO;
		numOfOre = 0;
		
		// Set date to the current date
		self.date = [NSDate date];
	}
	return self;
	
}

-(NSString*)toString {
	// TODO: Probably not optimal...
	NSNumber * number = [NSNumber numberWithDouble:[self.kroner doubleValue] + [self.ore doubleValue]/100];
	
	if (self.formatter == nil) {
		self.formatter = [[NSNumberFormatter alloc] init];
	}
	
	// TODO: Set it to something smart based on where the user is 
	// and also based on what the user chooses manually...
	[self.formatter setCurrencyCode:@"EUR"];
	
	[self.formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	return [self.formatter stringFromNumber:number];
	
}
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

// Methods for display
-(bool)hasDecimals {
	return has_ore;
}
-(bool)canBeAddedTo {
	if ([self.kroner intValue] / 1000000000 != 0 && has_ore == NO) {return NO;}
	if (has_ore == NO) {return YES;}
	if (has_ore == YES && numOfOre < 2) {return YES;} 
	
	return NO;
	
}
-(bool)needsDeleteButton {
	if ([self.kroner intValue] == 0 && has_ore == NO) {return NO;} 
	return YES;
}

-(void)dealloc {
	[formatter dealloc];
	[super dealloc];
}

@end
