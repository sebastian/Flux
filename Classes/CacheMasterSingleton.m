//
//  CacheMasterSingleton.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "CacheMasterSingleton.h"
#import "FinanceAppDelegate.h"
#import "Transaction.h"
#import "Utilities.h"
#import "CurrencyManager.h"

#define CacheLog(what) NSLog([@"CacheManager: " stringByAppendingString:what])

@implementation CacheMasterSingleton

static CacheMasterSingleton *sharedCacheMaster = nil;

#pragma mark
#pragma mark -
#pragma mark General methods
@synthesize truePredicate;
- (NSPredicate*)truePredicate {
	if (truePredicate == nil) {
		truePredicate = [NSPredicate predicateWithValue:YES];
	}
	return truePredicate;
}
- (void) clearCache {

	CacheLog(@"Clearing all cache. Telling tables that they can reload!");
	
	// General
	self.truePredicate == nil;
	
	// Clear all the cached files
	self.detailTableCellFont = nil;
	self.detailTableCellGrayColor = nil;
	self.detailTableCellBlackColor = nil;
	self.detailTableCellBackgroundImage = nil;
	self.detailTableCellSelectedBackgroundImage = nil;
	self.detailTableCellSeparator = nil;
		
	[self.overviewTableDelegate setWorthUpdating:YES];
	
}

#pragma mark
#pragma mark -
#pragma mark OverviewTable cache manager
@synthesize overviewTableDelegate;
@synthesize overviewCache_months;
@synthesize overviewCache_cellCache;
- (NSMutableDictionary*)overviewCache_cellCache {
	/* 
	 We load in the cached cell data as well
	 There are some conditions. First we check if it has already been loaded
	 If not we try to load it, and if that still doesn't result in any cache
	 then we create an empty cache dictionary
	 */
	if (overviewCache_cellCache == nil) {
		// Not loaded yet => load
		CacheLog(@"Loading overview table cache");
		self.overviewCache_cellCache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self overviewCache_cachePath]];
		if (overviewCache_cellCache == nil) { 
			// There didn't exist any cache. We create an empty dictionary
			CacheLog(@"There was no overview table cache. Created it");
			self.overviewCache_cellCache = [[NSMutableDictionary alloc] init];
		}
	}
	return overviewCache_cellCache;
}
- (NSString*)overviewCache_cachePath {
	FinanceAppDelegate * app = (FinanceAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSString *archivePath = [app.applicationDocumentsDirectory stringByAppendingPathComponent:@"OverviewTableCache.archive"];
	return archivePath;
}
- (NSMutableArray*)overviewCache_months {
	if (overviewCache_months == nil) {
		CacheLog(@"Populating months array");
		overviewCache_months = [[NSMutableArray alloc] init];
		for (NSString * key in self.overviewCache_cellCache) {
			[overviewCache_months addObject:key];
		}
		[self overviewCache_sortMonthsArray];
		
		// For logging purposes
		for (NSString * month in overviewCache_months) {
			NSLog(@"\t%@", month);
		}
	}
	return overviewCache_months;
}
- (NSDictionary*)overviewCache_forRow:(NSInteger)row {
	
	NSLog(@"CacheManager: getting cache for row %i", row);
	
	NSString * yearMonth = [self.overviewCache_months objectAtIndex:row];
	
	if ([overviewCache_cellCache objectForKey:yearMonth] == nil) {
		
		NSLog(@"CacheManager: Generating overview data for row: %i", row);
		
		// Get info to put into cell:
		if (self.overviewTableDelegate == nil) {
			CacheLog(@"ERROR - there is no overviewTableDelegate. Can't return cache");
			return nil;
		}
		
		NSArray * sections = [self.overviewTableDelegate.resultsController sections];
		
		if ([sections count] == 0) {
			/* There are no sections. No need to do any more work here! */
		} else {
			
			id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:row];
			NSArray * _transactionsInSection = [currenctSection objects];
			NSArray * transactionsInSection = [_transactionsInSection filteredArrayUsingPredicate:self.overviewTableDelegate.filteringPredicate];
			
			Transaction * aTransaction = (Transaction*)[_transactionsInSection objectAtIndex:0];
			
			// Sum the amount
			double amount = [[Utilities toolbox] sumAmountForTransactionArray:transactionsInSection];
			
			NSDate * dateFromObject = aTransaction.date;
			// Do we have a valid date?
			int n = 0;
			/*
			 For some strange reason, some transactions don't have a date
			 Therefore we have to look through the transactions to see if we can find
			 a transaction with a date so that we can display the month name
			 */
			while (dateFromObject == nil) {
				n++;
				if (n >= [_transactionsInSection count]) {
					break;
				}
				
				Transaction * anotherTransaction = (Transaction*)[_transactionsInSection objectAtIndex:n];
				dateFromObject = anotherTransaction.date;
				
			}
			if (dateFromObject == nil) {
				// None of the transactions had a date, so we have to fake it...
				NSLog(@"ERROR: None of the transactions had a date! We had to fake one");
				dateFromObject = [NSDate date];
			}
			if (n!=0) {
				NSLog(@"Had to try %i times to get a date...",n);
			}
			
			NSNumber * numAmount = [NSNumber numberWithDouble:amount];
			NSString * calculatedAmount = [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:numAmount withFraction:YES];
			NSString * yearMonth = aTransaction.yearMonth;
			NSNumber * totalNumberOfObjectsInSection = [NSNumber numberWithInt:[_transactionsInSection count]];
			
			NSArray * data = [NSArray arrayWithObjects:dateFromObject, calculatedAmount, numAmount, yearMonth, totalNumberOfObjectsInSection, nil];
			NSArray * keys = [NSArray arrayWithObjects:@"date", @"amount", @"rawAmount", @"yearMonth", @"totNumObjects", nil];
			NSDictionary * dict = [NSDictionary dictionaryWithObjects:data forKeys:keys];
			
			[self.overviewCache_cellCache setObject:dict forKey:yearMonth];
				
		}
		
		/*
		 Make the cache persistant so it is saved for later 
		 iff the don't have some filtering predicate
		 */
		if (self.overviewTableDelegate.filteringPredicate == self.truePredicate) {
			[self overviewCache_makePersistent];
		}
	}
	return [self.overviewCache_cellCache objectForKey:yearMonth];
}
- (void) overviewCache_makePersistent {
	// Save the cell calculations cache to get super speed up :D
	[NSKeyedArchiver archiveRootObject:self.overviewCache_cellCache
								toFile:[self overviewCache_cachePath]];
	CacheLog(@"Saved overview table cache!");	
}
- (NSInteger) overviewCache_numberOfRows {
	return [self.overviewCache_months count];
}
// Interface for transactions
- (void) overviewCacheUpdatedTransaction:(Transaction*)transaction {
	CacheLog(@"Received updated transaction");

	NSLog(@"Changed values are: %@", transaction.changes);
	
	NSString * yearMonth = transaction.yearMonth;
	
	if (transaction.isNew) {
		
		[self overviewCache_insert:yearMonth];
		
	} else if ([transaction isDeleted]) {
			
		[self overviewCache_delete:yearMonth];
		
	} else {
		
		CacheLog(@"It has changes...");
		if (transaction.oldYearMonth != nil) {
			/* 
			 it has been moved, guaranteed work!
			 We have to clear the cache of the old location and of the new location!
			 */
			[self overviewCache_delete:transaction.oldYearMonth];
			[self overviewCache_insert:yearMonth];
			 
		} else {
			
			/*
			 TODO: Fix a smarter way. Check if it has a change that is reflected in the interface
			 If it is changed in expense/income or kroner
			 */
			[self.overviewCache_cellCache removeObjectForKey:yearMonth];
			[self.overviewTableDelegate setWorthUpdating:YES];
			
		}
	}
}
- (void)overviewCache_insert:(NSString*)yearMonth {
	
	CacheLog(@"It is a new transaction");
	if ([self.overviewCache_months containsObject:yearMonth]) {
		/* It has an entry. Let's clear it's cache */
		CacheLog(@"The month already exists");
		[self.overviewCache_cellCache removeObjectForKey:yearMonth];
	} else {
		/* It is a new entry! Insert it, and sort the array again */
		NSLog(@"\tIt is a transaction for a new month %@", yearMonth);
		[self.overviewCache_months addObject:yearMonth];
		[self overviewCache_sortMonthsArray];
	}
	
	[self.overviewTableDelegate setWorthUpdating:YES];
	
}
- (void)overviewCache_delete:(NSString*)yearMonth {
	
	CacheLog(@"It is a deleted transaction");
	/*
	 Now we clear the cache, then we 
	 regenerate the cache to see if there is still any elements present
	 and if there is not, then we remove it completely from the list
	 */
	[self.overviewCache_cellCache removeObjectForKey:yearMonth];
	if ([self.overviewCache_months containsObject:yearMonth]) {

		NSInteger row = [self.overviewCache_months indexOfObject:yearMonth];
		NSDictionary * dict = [self overviewCache_forRow:row];
		if (dict == nil) {
			CacheLog(@"Last object in section, delete month");
			[self.overviewCache_months removeObjectAtIndex:row];
		}
		
		/*
		 Tell the delegat that it's worth updating
		 */
		[self.overviewTableDelegate setWorthUpdating:YES];
		
		
	} else {
	
		CacheLog(@"Error. Wanted to delete, but there was no object in the months array with that for that month");
		
	}
		
}
- (void)overviewCache_sortMonthsArray {
	NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO selector:@selector(compare:)];
	[overviewCache_months sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
}


#pragma mark
#pragma mark -
#pragma mark Shared data for Detail Content Table cell
// Detail table view cell
@synthesize detailTableCellFont;
@synthesize detailTableCellGrayColor;
@synthesize detailTableCellBlackColor;
@synthesize detailTableCellBackgroundImage;
@synthesize detailTableCellSelectedBackgroundImage;
@synthesize detailTableCellSeparator;
// Getters
- (UIFont*)detailTableCellFont {
	if (detailTableCellFont == nil) {
		detailTableCellFont = [[UIFont systemFontOfSize:12] retain];
	}
	return detailTableCellFont;
}
- (UIColor*)detailTableCellGrayColor {
	if (detailTableCellGrayColor == nil) {
		detailTableCellGrayColor = [[UIColor grayColor] retain];
	}
	return detailTableCellGrayColor;
}
- (UIColor*)detailTableCellBlackColor {
	if (detailTableCellBlackColor == nil) {
		detailTableCellBlackColor = [[UIColor blackColor] retain];
	}
	return detailTableCellBlackColor;
}
- (UIImage*)detailTableCellBackgroundImage {
	if (detailTableCellBackgroundImage == nil) {
		detailTableCellBackgroundImage = [[UIImage imageNamed:@"CellDetail.png"] retain];
	}
	return detailTableCellBackgroundImage;
}
- (UIImage*)detailTableCellSelectedBackgroundImage {
	if (detailTableCellSelectedBackgroundImage == nil) {
		detailTableCellSelectedBackgroundImage = [[UIImage imageNamed:@"CellSelectedDetail.png"] retain];
	}
	return detailTableCellSelectedBackgroundImage;
}
- (UIImage*)detailTableCellSeparator {
	if (detailTableCellSeparator == nil) {
		detailTableCellSeparator = [[UIImage imageNamed:@"CellSeparator288.png"] retain];
	}
	return detailTableCellSeparator;
}

#pragma mark
#pragma mark -
#pragma mark Singleton methods
+ (CacheMasterSingleton*)sharedCacheMaster; {
    @synchronized(self) {
        if (sharedCacheMaster == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedCacheMaster;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedCacheMaster == nil) {
            sharedCacheMaster = [super allocWithZone:zone];
            return sharedCacheMaster;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release {
    //do nothing
}
- (id)autorelease{
    return self;
}

- (void)dealloc {	
	[super dealloc];
}


@end
