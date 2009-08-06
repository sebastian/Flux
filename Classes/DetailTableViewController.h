//
//  ExpensesTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailHeaderView.h"
#import "DetailContentTableCell.h"
#import "TransactionTableViewController.h"

@interface DetailTableViewController : TransactionTableViewController {
	DetailHeaderView * detailHeaderView;
	DetailContentTableCell * detailContentTableCell;
	UIImageView * detailFooterView;
	NSString * yearMonthToDisplay;
	
	// Remember the state of the search bar
	NSString * filterString;
	BOOL filterActive;
	
	NSMutableDictionary * transactionsDataCache;
	NSMutableDictionary * headerViewCache;
	NSMutableDictionary * footerViewCache;
	
}

@property (nonatomic, retain) NSMutableDictionary * transactionsDataCache;
@property (nonatomic, retain) NSMutableDictionary * headerViewCache;
@property (nonatomic, retain) NSMutableDictionary * footerViewCache;

@property (nonatomic, retain) NSString * yearMonthToDisplay;

//Different table cells
@property (nonatomic, retain) IBOutlet DetailHeaderView * detailHeaderView;
@property (nonatomic, retain) IBOutlet DetailContentTableCell * detailContentTableCell;
@property (nonatomic, retain) IBOutlet UIImageView * detailFooterView;

// Custom init
//- (id)initWithStyle:(UITableViewStyle)style yearMonthToDisplay:(NSString*)yearMonth andContext:(NSManagedObjectContext*)context;

@end
