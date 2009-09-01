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
#import "DetailTableViewController.h"
#import "OverviewTableViewController.h"

#define CacheLog(what) NSLog([@"CacheManager (%i): " stringByAppendingString:what], runNum)

@implementation CacheMasterSingleton

static CacheMasterSingleton *sharedCacheMaster = nil;

@synthesize runNum;

#pragma mark
#pragma mark -
#pragma mark General methods
@synthesize truePredicate;
@synthesize filteringPredicate;
- (id) init {
	CacheLog(@"Init called for the CacheMaster");
	self = [super init];
	self.filteringPredicate = self.truePredicate;
		
	return self;
}
- (void) setFilteringPredicate:(NSPredicate *)predicate {
	/*
	 If the same predicate is set as the one that already exists
	 then nothing should be done
	 */
	if ([predicate isEqual:self.filteringPredicate]) {
		return;
	}
	
	/*
	 If the old predicate was the true predicate,
	 and the new one is not, then we should keep a copy of the old cache
	 */
	if ([self.filteringPredicate isEqual:self.truePredicate] && ![predicate isEqual:self.truePredicate]) {
		self.overviewCache_cellCache_nonfiltered = [self.overviewCache_cellCache copy];
	}
	
	[self.overviewCache_cellCache removeAllObjects];
	
	if ([predicate isEqual:self.truePredicate] && ![predicate isEqual:self.filteringPredicate]) {
		self.overviewCache_cellCache = [self.overviewCache_cellCache_nonfiltered copy];
	}
	
	[predicate retain];
	[filteringPredicate release];
	filteringPredicate = predicate;
}
- (NSPredicate*)truePredicate {
	if (truePredicate == nil) {
		truePredicate = [NSPredicate predicateWithValue:YES];
	}
	return truePredicate;
}
- (void) clearCache {

	CacheLog(@"** Clearing all cache. Telling tables that they can reload! **");
	
	// General
	self.truePredicate == nil;
	
	// Clear all the cached files
	self.detailTableCellFont = nil;
	self.detailTableCellGrayColor = nil;
	self.detailTableCellBlackColor = nil;
	self.detailTableCellBackgroundImage = nil;
	self.detailTableCellSelectedBackgroundImage = nil;
	self.detailTableCellSeparator = nil;
		
	// Overview table cache
	self.overviewCache_months = nil;
	self.overviewCache_cellCache = nil;
	
}
- (void) updatedTransaction:(Transaction*)transaction {
	CacheLog(@"** Received updated transaction. Passing it to overviewCacheControler **\n\n");
	[self overviewCacheUpdatedTransaction:transaction];
	
	if (self.detailTableDelegate != nil) {
		CacheLog(@"** Passing the updated transaction to the detailCacheController **\n\n");
		[self detailCacheUpdatedTransaction:transaction];
	}
}

#pragma mark
#pragma mark -
#pragma mark DetailTable manager
@synthesize detailTableDelegate;
@synthesize detailCache_cellCache;
- (NSMutableDictionary*) detailCache_cellCache {
	if (detailCache_cellCache == nil) {
		NSLog(@"Creating a new detailCache_cellCache");
		detailCache_cellCache = [[NSMutableDictionary alloc] init];
	}
	return detailCache_cellCache;
}
- (void) setDetailTableDelegate:(DetailTableViewController*)delegate {
	detailTableDelegate = delegate;
	/* 
	 When the delegate clears it responsibility, 
	 then the cache is automatically stale, ie we can get rid of the dictionary!
	 */
	if (delegate == nil) {self.detailCache_cellCache = nil;}
}
- (void) detailCache_tellDelegateThatItsWorthUpdating {
	if (self.detailTableDelegate != nil) {
		@try {
			[self.detailTableDelegate setWorthUpdating:YES];
		}
		@catch (NSException * e) {
			/*
			 There is no detailTableViewController.
			 It must have been dealloced... it should have deregistered,
			 but something must have gone wrong.
			 */
		}
	}	
}
- (NSDictionary*) detailCache_dataForSection:(NSInteger)_section {

	NSLog(@"detailCache_dataForSection _section %i", _section);
	/*
	 If we are trying to access an section that doesn't exists, 
	 ie is out of bounds, then we return nil
	 */
	
	NSNumber * section = [NSNumber numberWithInt:_section];
	
	if ([self.detailCache_cellCache objectForKey:section] == nil) {
		
		NSLog(@"Generating data for row_section %i", _section, section);
		
		// General data
		NSArray * _transactions = [[[self.detailTableDelegate.resultsController sections] objectAtIndex:_section] objects];
		NSArray * transactions = [_transactions filteredArrayUsingPredicate:self.filteringPredicate];
				
		// Data for header
		Transaction * aTransaction = (Transaction*) [_transactions objectAtIndex:0];
		
		// TODO: Check if the day == section... if not, then there is a section that has been deleted, and we should return nil (?)
		
		// Calculate the amount
		double dAmount = [[Utilities toolbox] sumAmountForTransactionArray:transactions];
		NSNumber * numAmount = [NSNumber numberWithDouble:dAmount];
		
		// TODO: Localize the date format display
		NSString * date = [aTransaction.day stringValue];
		NSString * amount = [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:numAmount withFraction:YES];
		
		// Data that has been worked on
		NSArray * objects = [NSArray arrayWithObjects:transactions, date, amount,nil];
		NSArray * keys = [NSArray arrayWithObjects:@"transactions", @"date", @"amount", nil];
		NSDictionary * data = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
		NSLog(@"Keys: %@", keys);
		NSLog(@"Num of transactions: %i", [transactions count]);
		NSLog(@"Day: %@", section);
		NSLog(@"Amount: %@", amount);
		
		// Insert into dictionary
		NSLog(@"Saved data for section %i in cache (day %@)", _section, section);
		[self.detailCache_cellCache setObject:data forKey:section];
	} 
	
	NSLog(@"Returning cached data");
	return [self.detailCache_cellCache objectForKey:section];
}
- (NSInteger) detailCache_numberOfSections {
	return [[self.detailTableDelegate.resultsController sections] count];
	//return [self.detailCache_dayToSection count];	
}
- (NSInteger) detailCache_numberOfRowsInSection:(NSInteger)section {
	NSLog(@"Getting number of rows for section %i", section);
	NSDictionary * data = [self detailCache_dataForSection:section];
	NSInteger count = [[data objectForKey:@"transactions"] count];
	return count;
}
- (void) detailCacheUpdatedTransaction:(Transaction*)transaction {
	NSLog(@"Getting a transaction (new/updated/deleted)");
	
	NSString * yearMonth = transaction.yearMonth;
	NSString * oldYearMonth = transaction.oldYearMonth;
	NSString * yearMonthToDisplay = self.detailTableDelegate.yearMonthToDisplay;
	
	BOOL worthUpdating = NO;

	if ([yearMonth isEqualToString:yearMonthToDisplay] || [oldYearMonth isEqualToString:yearMonthToDisplay]) {
		self.detailCache_cellCache = nil;
		worthUpdating = YES;
	}
	
	if (worthUpdating) {[self detailCache_tellDelegateThatItsWorthUpdating];}
	
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
#pragma mark OverviewTable cache manager
@synthesize overviewTableDelegate;
@synthesize overviewCache_months;
@synthesize overviewCache_cellCache;
@synthesize overviewCache_cellCache_nonfiltered;
- (NSMutableDictionary*)overviewCache_cellCache_nonfiltered {
	if (overviewCache_cellCache_nonfiltered == nil) {self.overviewCache_cellCache_nonfiltered = [[NSMutableDictionary alloc] init];}
	return overviewCache_cellCache_nonfiltered;
}
- (NSMutableDictionary*)overviewCache_cellCache {
	/* 
	 We load in the cached cell data as well
	 There are some conditions. First we check if it has already been loaded
	 If not we try to load it, and if that still doesn't result in any cache
	 then we create an empty cache dictionary
	 */
	if (overviewCache_cellCache == nil) {
		// Not loaded yet => load
		overviewCache_cellCache = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithFile:[self overviewCache_cachePath]];
		if (overviewCache_cellCache == nil) { 
			// There didn't exist any cache. We create an empty dictionary
			overviewCache_cellCache = [[NSMutableDictionary alloc] init];
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
		NSLog(@"Creating overviewCache_months");
		
		overviewCache_months = [[NSMutableArray alloc] init];
		for (NSString * key in self.overviewCache_cellCache) {
			[overviewCache_months addObject:key];
		}
		
		/* 
		 What if there are no entries in the cache? Then we should check with
		 the fetched results controller, to see if that is right
		 */
		if ([overviewCache_months count] == 0) {
			for (int n = 0; n < [[self.overviewTableDelegate.resultsController sections] count]; n++) {
				NSLog(@"At index %i out of %i", n, [[self.overviewTableDelegate.resultsController sections] count]-1);
				id <NSFetchedResultsSectionInfo> currenctSection = [[self.overviewTableDelegate.resultsController sections] objectAtIndex:n];
				NSArray * _transactionsInSection = [currenctSection objects];
				Transaction * aTransaction = (Transaction*)[_transactionsInSection objectAtIndex:0];
				
				NSString * yearMonth = aTransaction.yearMonth;
				NSLog(@"Adding yearMonth %@ to the overviewCache_months array as index %i out of %i", yearMonth, n, [[self.overviewTableDelegate.resultsController sections] count]-1);
				[overviewCache_months addObject:yearMonth];
			}
		}

		[self overviewCache_sortMonthsArray];
	}
	return overviewCache_months;
}
- (NSDictionary*)overviewCache_forRow:(NSInteger)row {
	
	NSString * yearMonth = [self.overviewCache_months objectAtIndex:row];
	
	if ([self.overviewCache_cellCache objectForKey:yearMonth] == nil) {
		
		// Get info to put into cell:
		if (self.overviewTableDelegate == nil) {return nil;}
		
		NSArray * sections = [self.overviewTableDelegate.resultsController sections];
		
		if ([sections count] <= row) {
			/* 
			 This section is activated if there are no sections, or we try to generate cache
			 for a section that is out of bounds, which means it doesn't exist and should be cleared.
			 */
			
		} else {
			
			id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:row];
			
			NSArray * _transactionsInSection = [currenctSection objects];
			NSArray * transactionsInSection = [_transactionsInSection filteredArrayUsingPredicate:self.filteringPredicate];
			
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
				//NSLog(@"ERROR: None of the transactions had a date! We had to fake one");
				dateFromObject = [NSDate date];
			}
			if (n!=0) {
				NSLog(@"Had to try %i times to get a date...",n);
			}
			
			NSNumber * numAmount = [NSNumber numberWithDouble:amount];
			
			NSString * calculatedAmount = [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:numAmount withFraction:YES];
			
			NSString * realYearMonth = aTransaction.yearMonth;
			if (![realYearMonth isEqualToString:yearMonth]) {
				/*
				 If they are not equal, then it means that there wasn't a section left with that year month
				 and that the one we got now is the next section in the fetched results controller.
				 Hence we should just return nil
				 */
				//CacheLog(@"Got a difference in yearMonth for the transactions and what we think it should be. Ie. it has been deleted");
				
			} else {
				
				NSNumber * totalNumberOfObjectsInSection = [NSNumber numberWithInt:[_transactionsInSection count]];
				//NSLog(@"Transaction yearMonth: %@. CacheManager things: %@ (RunNum: %i)", realYearMonth, yearMonth, runNum);
				
				// Preparing the data for the cache entry in the dictionary
				NSArray * data = [NSArray arrayWithObjects:dateFromObject, calculatedAmount, numAmount, yearMonth, totalNumberOfObjectsInSection, nil];
				NSArray * keys = [NSArray arrayWithObjects:@"date", @"amount", @"rawAmount", @"yearMonth", @"totNumObjects", nil];
				NSDictionary * dict = [NSDictionary dictionaryWithObjects:data forKeys:keys];
				
				[self.overviewCache_cellCache setObject:dict forKey:yearMonth];
				
			}
		}
		
		/*
		 Make the cache persistant so it is saved for later 
		 iff the don't have some filtering predicate
		 */
		if (self.filteringPredicate == self.truePredicate) {
			/*
			 Only save the cache for non-empty sections!
			 This to not get cache, when there is no data!
			 */
			NSDictionary * dict = [self.overviewCache_cellCache objectForKey:yearMonth];
			if ([[dict objectForKey:@"totNumObjects"] intValue] != 0) {
				[self overviewCache_makePersistent];
			}
			
		}
	}
	return [self.overviewCache_cellCache objectForKey:yearMonth];
}
- (void) overviewCache_makePersistent {
	// Save the cell calculations cache to get super speed up :D
	[NSKeyedArchiver archiveRootObject:self.overviewCache_cellCache
								toFile:[self overviewCache_cachePath]];
	//CacheLog(@"Saved overview table cache!");	
}
- (NSInteger) overviewCache_numberOfRows {
	return [self.overviewCache_months count];
}
- (void)overviewCacheUpdatedTransaction:(Transaction*)transaction {
	/*
	 If there isn't an overview delegate, then we should just return
	 */
	if (self.overviewTableDelegate == nil) {
		CacheLog(@"There is no overviewTableDelegate... we just return");
		return;
	}
	
	//CacheLog(@"Change in transaction");
	
	//NSLog(@"Changed values are: %@", transaction.changes);
	
	NSString * yearMonth = transaction.yearMonth;
	
	if ([transaction isDeleted]) {
		
		//CacheLog(@"It is a deleted transaction. Remove cache");
		[self overviewCache_delete:yearMonth];
		
	} else if (transaction.isNew) {
		
		//CacheLog(@"It is a supernew new transaction");
		[self overviewCache_insert:yearMonth];
		
	} else {
		
		//CacheLog(@"It has changes...");
		if (transaction.oldYearMonth != nil) {
			/* 
			 it has been moved, guaranteed work!
			 We have to clear the cache of the old location and of the new location!
			 
			 OBS! Please understand that the order here is crucial! The insert has to happen first!
			 Otherwise:
			 August is the last month and a data in an august transaction is set to september.
			 Then when deleting and rebuilding the cache for what the CacheManager thinks is August
			 has in the FetchedResultsController already become September, because it has processed the
			 changes! Hence we have an off by one, because the overviewCache_month doesn't map into 
			 the right section!
			 */
			if ([transaction.oldYearMonth compare:yearMonth] == NSOrderedAscending) {
				NSLog(@"\tOld compared with new: ORDER ASCENDING");
				[self overviewCache_insert:yearMonth];
				[self overviewCache_delete:transaction.oldYearMonth];
				
			} else if ([transaction.oldYearMonth compare:yearMonth] == NSOrderedDescending){
				NSLog(@"\tOld compared with new: ORDER DESCENDING");
				
				[self overviewCache_delete:transaction.oldYearMonth];
				[self overviewCache_insert:yearMonth];
				
			} else if ([transaction.oldYearMonth compare:yearMonth] == NSOrderedSame){
				NSLog(@"\tOld compared with new: ORDER SAME");
			}
			
			
			
		} else {
			
			//CacheLog(@"It has changes, but the date, if changed, is equal to the old one");
			
			/*
			 Check if one of the values that make for a change
			 in the overview cache data has been changed
			 */
			if (([transaction.changes objectForKey:@"expense"] != nil) ||
				([transaction.changes objectForKey:@"kroner"] != nil)) {
				
				//CacheLog(@"It has interesting changes, ie: kroner or expense");
				
				/* 
				 It has a change to either:
				 expense: bool
				 kroner: NSNumber
				 */
				[self.overviewCache_cellCache removeObjectForKey:yearMonth];
				[self overviewCache_tellDelegateThatItsWorthUpdating];
				
			} else {
				/* No interesting change has happened... */
				//CacheLog(@"No changes that interest us");
			}
		}
	}
}
- (void)overviewCache_insert:(NSString*)yearMonth {
	
	//CacheLog(@"It is a new transaction");
	if ([self.overviewCache_months containsObject:yearMonth]) {
		/* It has an entry. Let's clear it's cache */
		//CacheLog(@"The month already exists");
		[self.overviewCache_cellCache removeObjectForKey:yearMonth];
	} else {
		/* It is a new entry! Insert it, and sort the array again */
		//NSLog(@"\tIt is a transaction for a new month %@", yearMonth);
		[self.overviewCache_months addObject:yearMonth];
		[self overviewCache_sortMonthsArray];
	}
	
	[self overviewCache_tellDelegateThatItsWorthUpdating];
	
}
- (void)overviewCache_delete:(NSString*)yearMonth {
	
	//CacheLog(@"It is a deleted transaction");
	/*
	 Now we clear the cache, then we 
	 regenerate the cache to see if there is still any elements present
	 and if there is not, then we remove it completely from the list
	 */
	[self.overviewCache_cellCache removeObjectForKey:yearMonth];
	if ([self.overviewCache_months containsObject:yearMonth]) {
		
		CacheLog(@"Reloading cache for row");
		NSInteger row = [self.overviewCache_months indexOfObject:yearMonth];
		NSLog(@"CacheManager (%i): Told to load index %i", self.runNum, row);
		NSDictionary * dict = [self overviewCache_forRow:row];
		if (dict == nil) {
			//CacheLog(@"Last object in section, delete month");
			[self.overviewCache_months removeObjectAtIndex:row];
		}
		
		/*
		 Tell the delegat that it's worth updating
		 */
		[self overviewCache_tellDelegateThatItsWorthUpdating];
		
		
	} else {
		
		//CacheLog(@"Error. Wanted to delete, but there was no object in the months array with that for that month");
		
	}
	
}
- (void)overviewCache_sortMonthsArray {
	NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO selector:@selector(compare:)];
	[overviewCache_months sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
}
- (void)overviewCache_tellDelegateThatItsWorthUpdating {
	if (self.overviewTableDelegate != nil) {
		@try {
			[self.overviewTableDelegate setWorthUpdating:YES];	
		}
		@catch (NSException * e) {
			/* 
			 Do nothing...
			 It must have been dealloced somewhere/somewhen... what ever.
			 */
		}

	}
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
