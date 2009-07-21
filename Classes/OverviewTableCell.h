//
//  TransactionTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 20.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transaction.h"

@interface OverviewTableCell : UITableViewCell {
	UILabel * when;
	UILabel * amount;
}

@property (nonatomic, retain) IBOutlet UILabel * when;
@property (nonatomic, retain) IBOutlet UILabel * amount;

-(void)setValuesWithTransaction:(Transaction *)transaction;

@end
