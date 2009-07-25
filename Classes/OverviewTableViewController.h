//
//  ExpensesTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverviewTableCell.h"
#import "TransactionTableViewController.h"

@interface OverviewTableViewController : TransactionTableViewController {
	OverviewTableCell * overviewTableCell;

	// Only during beta
	Transaction * betaTransaction;
	NSMutableString * currentString;
	BOOL storingCharacters;
}

-(void)addBetaContent;

//Different table cells
@property (nonatomic, retain) IBOutlet OverviewTableCell * overviewTableCell;

@end
