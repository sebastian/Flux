//
//  TransactionTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 20.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transaction.h"

@interface TransactionTableCell : UITableViewCell {
	UILabel * what;
	UILabel * price;
}

@property (nonatomic, retain) IBOutlet UILabel * what;
@property (nonatomic, retain) IBOutlet UILabel * price;

-(void)setValuesWithTransaction:(Transaction *)transaction;

@end
