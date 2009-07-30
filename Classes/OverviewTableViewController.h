//
//  ExpensesTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionTableViewController.h"

@class OverviewTableCell;

@interface OverviewTableViewController : TransactionTableViewController {
	OverviewTableCell * overviewTableCell;

	BOOL onlyLast3Months;
	NSInteger numOfSections;
}

//Different table cells
@property (nonatomic, retain) IBOutlet OverviewTableCell * overviewTableCell;

@end
