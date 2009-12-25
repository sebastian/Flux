//
//  CacheMasterSingleton.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import <CoreData/CoreData.h>
#import "TransactionModel.h"

@class Transaction;
@class DetailTableViewController;
@class OverviewTableViewController;

@interface CacheMasterSingleton : NSObject {

	NSPredicate * truePredicate;
	NSPredicate * filteringPredicate;
	
	// Detail table cell - resources
	UIFont  * detailTableCellFont;
	UIColor * detailTableCellGrayColor;
	UIColor * detailTableCellBlackColor;
	UIImage * detailTableCellBackgroundImage;
	UIImage * detailTableCellSelectedBackgroundImage;
	UIImage * detailTableCellSeparator;	
	NSMutableDictionary * detailTableCellData;
	bool _shouldDeleteDetailCache;
	
	// Detail header view - resource
	UIFont * detailHeaderViewFont;
	UIColor * detailHeaderViewGrayColor;
	UIColor * detailHeaderViewBlackColor;
	UIImage * detailHeaderViewBackgroundImage;
	
	// DetailTable cache
	DetailTableModel * detailTableDelegate;
	NSMutableDictionary * detailCache_cellCache;
	NSMutableDictionary * detailCache_headerViewCache;
	
	// OverviewTable cache
	NSMutableArray * overviewCache_months;
	NSMutableDictionary * overviewCache_cellCache;
	TransactionModel * overviewTableDelegate;
	bool _shouldDeleteOverviewCache;
	NSString * _cachedTotalSum;
	
	// Filtering
	NSArray * tagWords;
	UIBarButtonItem * filterButton;
		
	int runNum;

}

#pragma mark General methods
@property (nonatomic, assign) int runNum;
@property (nonatomic, retain) NSPredicate * truePredicate;
@property (nonatomic, retain) NSPredicate * filteringPredicate;
+ (CacheMasterSingleton*)sharedCacheMaster;
- (void) clearCache;
- (void) updatedTransaction:(Transaction*)transaction;
- (void) tellDelegatesItsWorthReloading;
- (void) reloadDelegateData;
- (void) forceCleanAndReload;
- (void)registerForManagedObjectContextNotifications;
- (void)deregisterForManagedObjectContextNotifications;

#pragma mark Filtering
@property (nonatomic, retain) NSArray * tagWords;
@property (nonatomic, retain) UIBarButtonItem * filterButton;
- (UIBarButtonItem*)filterButton;
- (void) toggleTagWord:(NSString*)tagWord;

#pragma mark DetailTable cache
@property (nonatomic, assign) DetailTableModel * detailTableDelegate;
@property (nonatomic, retain) NSMutableDictionary * detailCache_cellCache;
@property (nonatomic, retain) NSMutableDictionary * detailCache_headerViewCache;
- (void) detailCache_clearCache;
- (void) detailCacheUpdatedTransaction:(Transaction*)transaction;
- (NSDictionary*) detailCache_dataForSection:(NSInteger)_section;
- (NSInteger) detailCache_numberOfSections;
- (NSInteger) detailCache_numberOfRowsInSection:(NSInteger)section;
- (void) detailCache_tellDelegateThatItsWorthUpdating;
- (UIView*) detailCache_headerViewForSection:(NSInteger)section;
- (UIImageView*) detailCache_footerViewForSection:(NSInteger)section;

#pragma mark Shared data for Detail header view
@property (nonatomic, retain) UIFont * detailHeaderViewFont;
@property (nonatomic, retain) UIColor * detailHeaderViewGrayColor;
@property (nonatomic, retain) UIColor * detailHeaderViewBlackColor;
@property (nonatomic, retain) UIImage * detailHeaderViewBackgroundImage;

#pragma mark Shared data for Detail Content Table cell
@property (nonatomic, retain) UIFont * detailTableCellFont;
@property (nonatomic, retain) UIColor * detailTableCellGrayColor;
@property (nonatomic, retain) UIColor * detailTableCellBlackColor;
@property (nonatomic, retain) UIImage * detailTableCellBackgroundImage;
@property (nonatomic, retain) UIImage * detailTableCellSelectedBackgroundImage;
@property (nonatomic, retain) UIImage * detailTableCellSeparator;
@property (nonatomic, retain) NSMutableDictionary * detailTableCellData;

- (UIFont*)detailTableCellFont;
- (UIColor*)detailTableCellGrayColor;
- (UIColor*)detailTableCellBlackColor;
- (UIImage*)detailTableCellBackgroundImage;
- (UIImage*)detailTableCellSelectedBackgroundImage;
- (UIImage*)detailTableCellSeparator;

#pragma mark OverviewTable Cache
@property (nonatomic, assign) TransactionModel * overviewTableDelegate;
@property (nonatomic, retain) NSMutableArray * overviewCache_months;
@property (nonatomic, retain) NSMutableDictionary * overviewCache_cellCache;
- (NSString*)overviewCache_cachePath;
- (NSDictionary*)overviewCache_forRow:(NSInteger)row;
- (void) overviewCache_makePersistent;
- (void) overviewCache_removePersistentCache;
- (NSInteger) overviewCache_numberOfRows;
// Interface for transactions
- (void) overviewCacheUpdatedTransaction:(Transaction*)transaction;
- (void) overviewCache_insert:(NSString*)yearMonth;
- (void) overviewCache_delete:(NSString*)yearMonth;
- (void) overviewCache_sortMonthsArray;
- (void) overviewCache_tellDelegateThatItsWorthUpdating;
- (void) overviewCache_removeCacheForYearMonth:(NSString*)yearMonth;
- (void) overviewCache_invalidateTotalSumCache;
- (NSString*) overviewCache_totalSum;

@end
