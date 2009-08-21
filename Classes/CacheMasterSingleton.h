//
//  CacheMasterSingleton.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OverviewTableViewController.h"
#import "DetailTableViewController.h"

@interface CacheMasterSingleton : NSObject {

	NSPredicate * truePredicate;
	
	// Detail table cell - resources
	UIFont  * detailTableCellFont;
	UIColor * detailTableCellGrayColor;
	UIColor * detailTableCellBlackColor;
	UIImage * detailTableCellBackgroundImage;
	UIImage * detailTableCellSelectedBackgroundImage;
	UIImage * detailTableCellSeparator;	
	
	// OverviewTable cache
	NSMutableArray * overviewCache_months;
	NSMutableDictionary * overviewCache_cellCache;
	OverviewTableViewController * overviewTableDelegate;
}

// The one public init method
@property (nonatomic, retain) NSPredicate * truePredicate;
+ (CacheMasterSingleton*)sharedCacheMaster;
- (void) clearCache;



#pragma mark OverviewTable Cache
@property (nonatomic, assign) OverviewTableViewController * overviewTableDelegate;
@property (nonatomic, retain) NSMutableArray * overviewCache_months;
@property (nonatomic, retain) NSMutableDictionary * overviewCache_cellCache;
- (NSString*)overviewCache_cachePath;
- (NSDictionary*)overviewCache_forRow:(NSInteger)row;
- (void) overviewCache_makePersistent;
- (NSInteger) overviewCache_numberOfRows;
// Interface for transactions
- (void) overviewCacheUpdatedTransaction:(Transaction*)transaction;
- (void) overviewCache_insert:(NSString*)yearMonth;
- (void) overviewCache_delete:(NSString*)yearMonth;
- (void)overviewCache_sortMonthsArray;

#pragma mark Shared data for Detail Content Table cell
@property (nonatomic, retain) UIFont * detailTableCellFont;
@property (nonatomic, retain) UIColor * detailTableCellGrayColor;
@property (nonatomic, retain) UIColor * detailTableCellBlackColor;
@property (nonatomic, retain) UIImage * detailTableCellBackgroundImage;
@property (nonatomic, retain) UIImage * detailTableCellSelectedBackgroundImage;
@property (nonatomic, retain) UIImage * detailTableCellSeparator;

- (UIFont*)detailTableCellFont;
- (UIColor*)detailTableCellGrayColor;
- (UIColor*)detailTableCellBlackColor;
- (UIImage*)detailTableCellBackgroundImage;
- (UIImage*)detailTableCellSelectedBackgroundImage;
- (UIImage*)detailTableCellSeparator;


@end
