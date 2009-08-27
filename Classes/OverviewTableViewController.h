//
//  ExpensesTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TransactionTableViewController.h"
#import "DetailTableViewController.h"
#import "CacheMasterSingleton.h"

@class OverviewTableCell;

@interface OverviewTableViewController : TransactionTableViewController <DetailTableViewDelegate> {
	OverviewTableCell * overviewTableCell;

	BOOL onlyLast3Months;
	NSInteger numOfSections;
	
	NSMutableDictionary * cellCalculations;
	NSMutableDictionary * cacheTable;
	
	BOOL performingDelayedReload;

}

// Clears cache and reloads table cells
- (void) baseCurrencyChanged;
- (NSString*)cellCachePath;
- (void) makeCachePersistent;

- (void) setBadgeBalance;
- (void) computeDataForIndexPath:(NSIndexPath *)indexPath;

//Different table cells
@property (nonatomic, retain) IBOutlet OverviewTableCell * overviewTableCell;
@property (nonatomic, retain) NSMutableDictionary * cellCalculations;

@end
