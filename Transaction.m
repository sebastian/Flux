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

-(NSString*)toString {
	return [NSString stringWithFormat:@"%i,%i",self.kroner, self.ore];
}

@end
