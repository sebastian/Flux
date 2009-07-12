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

-(id)init {
	self = [super init];
	if (self) {
		
		if (self.ore != 0) {
			has_ore = YES;
		} else {
			has_ore = NO;
		}
		numOfOre = 0;
	}
	return self;
}

-(NSString*)toString {
	// TODO fix this ugly hack when I have time
	if ([self.ore integerValue] > 10) {
		return [NSString stringWithFormat:@"%i,%i", [self.kroner integerValue], [self.ore integerValue]];
	} else {
		return [NSString stringWithFormat:@"%i,%i0", [self.kroner integerValue], [self.ore integerValue]];
	}
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
		numOfOre -= 1;
		if (numOfOre < 1) {has_ore = NO;}
		
		self.ore = [NSNumber numberWithInt:[self.ore integerValue] / 10];
		
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
	if (has_ore == NO) {return YES;}
	if (has_ore == YES && numOfOre < 2) {return YES;} 
	
	return NO;
	
}

@end
