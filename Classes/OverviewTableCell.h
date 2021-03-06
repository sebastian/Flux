//
//  TransactionTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 20.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Transaction.h"

@interface OverviewTableCell : UITableViewCell {
	UILabel * month;
	UILabel * year;
	UILabel * amount;
}

@property (nonatomic, retain) IBOutlet UILabel * month;
@property (nonatomic, retain) IBOutlet UILabel * amount;
@property (nonatomic, retain) IBOutlet UILabel * year;

-(void)updateCellWithDate:(NSDate*)date andAmount:(NSString*)amountString;

@end
