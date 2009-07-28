//
//  TransactionAnnotation.m
//  Finance
//
//  Created by Sebastian Probst Eide on 27.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "MapAnnotation.h"
#import "Transaction.h"


@implementation MapAnnotation

@synthesize coordinate, currentTransaction;

-(id)initWithTransaction:(Transaction*)tr {
	self = [super init];
	if (self != nil) {
		coordinate=tr.location.coordinate;
		self.currentTransaction = tr;
		
		NSLog(@"%f,%f",coordinate.latitude,coordinate.longitude);
	}
	return self;
}

- (NSString *)subtitle {
	return currentTransaction.tags;
}
- (NSString *)title {
	return [currentTransaction toString];
}


-(void)dealloc {
	NSLog(@"Deallocing annotation");
	[currentTransaction dealloc];
	
	[super dealloc];
}

@end