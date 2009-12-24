//
//  CacheMasterSingleton.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "CacheMasterSingleton.h"
#import "FluxAppDelegate.h"
#import "Transaction.h"
#import "Utilities.h"

#import "CurrencyManager.h"
#import "DetailTableViewController.h"
#import "OverviewTableViewController.h"
#import "KleioCustomStyles.h"

#define IMAGE_WIDTH 17


@interface FilterButton : TTView {
	BOOL active;
	UIImage * searchIcon;
	UIFont * font;
	int padding;
	NSMutableArray * tags;
}
- (id) initWithFilterinYes;
- (id) initWithFilterinNo;
@end

@implementation FilterButton

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private
- (void) openFilteringPanel {
	[[TTNavigator navigator] openURL:@"kleio://tagSelector" animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
		
		padding = 6;
		
		self.backgroundColor = [UIColor clearColor];
		self.multipleTouchEnabled = YES;

		self.style = active 
			? TTSTYLEVAR(filteringButtonActive:UIControlStateNormal)
			: TTSTYLEVAR(filteringButtonPassive:UIControlStateNormal);
		
		// Alloc objects needed

		searchIcon = [TTIMAGE(@"bundle://filterIcon.png") retain];
		
		int overallWidth = - padding;
		
		tags = [[NSMutableArray alloc] init];
		
		if (active) {
		
			font = [[UIFont systemFontOfSize:12.f] retain];
			NSArray * tagWords = [CacheMasterSingleton sharedCacheMaster].tagWords;
			for (int n = 0; n < [tagWords count]; n++) {
				
				NSString * text;
				if (n > 1) {
					text = @"...";
				} else {
					text = [tagWords objectAtIndex:n];
				}
			
				CGSize textSize = [text sizeWithFont:font];
				text = [NSString stringWithFormat:@"<span class=\"filterButtonTag\">%@</span>", text];
				TTStyledTextLabel * textLabel = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 10, 50)] autorelease];
				textLabel.font = font;
				textLabel.text = [TTStyledText textFromXHTML:text lineBreaks:NO URLs:NO];
				textLabel.contentInset = UIEdgeInsetsMake(8, 5, 0, 5);
				textLabel.backgroundColor = [UIColor clearColor];
				
				overallWidth += textLabel.width + padding;
				
				[tags addObject:textLabel];
				
				if (n > 1) {
					break;
				}
			}
			
		} else {
			
			font = [UIFont systemFontOfSize:14.f];
			
			NSString * text = NSLocalizedString(@"Filter", nil);
			CGSize textSize = [text sizeWithFont:font];
			TTStyledTextLabel * textLabel = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width + padding, 33)] autorelease];
			textLabel.font = font;
			textLabel.text = [TTStyledText textFromXHTML:text];
			textLabel.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
			textLabel.textColor = [UIColor whiteColor];
			textLabel.backgroundColor = [UIColor clearColor];
			[textLabel sizeToFit];
			overallWidth += textLabel.width + padding;
			
			[tags addObject:textLabel];
		}
		
		CGSize buttonSize;
		buttonSize.width = padding + IMAGE_WIDTH + padding + overallWidth + padding;
		buttonSize.height = 33;
		
		self.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
		
	}
	
	return self;
}

- (id) initWithFilterinYes {
	active = YES;
	self = [self init];		
	return self;
}

- (id) initWithFilterinNo {
	active = NO;
	self = [self init];
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(searchIcon);
	TT_RELEASE_SAFELY(font);
	TT_RELEASE_SAFELY(tags);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTView

- (void)drawContent:(CGRect)rect {
	CGPoint point = CGPointMake(padding, 7);
	
	// Draw icon
	[searchIcon drawAtPoint:point];
	
	// Set location for text
	point.x += IMAGE_WIDTH + padding;
	point.y = 0;
	
	for (TTStyledTextLabel * label in tags) {
		label.frame = CGRectMake(point.x, point.y, label.width, label.height);
		[self addSubview:label];
		
		point.x += 3 + label.width;
	}
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Touch handling
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[super touchesBegan:touches withEvent:event];
	
	self.style = active
		? TTSTYLEVAR(filteringButtonActive:UIControlStateHighlighted) 
		: TTSTYLEVAR(filteringButtonPassive:UIControlStateHighlighted);

	[self setNeedsLayout];
	
	[self openFilteringPanel];
	
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define CacheLog(what) NSLog([@"CacheManager (%i): " stringByAppendingString:what], runNum)

@implementation CacheMasterSingleton

static CacheMasterSingleton * sharedCacheMaster = nil;

@synthesize runNum;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
		_shouldDeleteOverviewCache = NO;
		_shouldDeleteDetailCache = NO;
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Misc

#pragma mark
#pragma mark -
#pragma mark General methods
@synthesize truePredicate;
@synthesize filteringPredicate;
- (NSPredicate*)filteringPredicate {
	if (filteringPredicate == nil) {
		filteringPredicate = self.truePredicate;
	}
	return filteringPredicate;
}
- (void) setFilteringPredicate:(NSPredicate *)predicate {
	/*
	 If the same predicate is set as the one that already exists
	 then nothing should be done
	 */
	if ([predicate isEqual:self.filteringPredicate]) {
		return;
	}

	// Clear the cache
	[self.overviewCache_cellCache removeAllObjects];
	[self detailCache_clearCache];
	self.detailTableCellData = nil;
	
	[predicate retain];
	[filteringPredicate release];
	filteringPredicate = predicate;
		
	[self tellDelegatesItsWorthReloading];
	[self reloadDelegateData];
	
	
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
	self.filterButton = nil;
	
	// Clear all the cached files
	// Detail content cell
	self.detailTableCellFont = nil;
	self.detailTableCellGrayColor = nil;
	self.detailTableCellBlackColor = nil;
	self.detailTableCellBackgroundImage = nil;
	self.detailTableCellSelectedBackgroundImage = nil;
	self.detailTableCellSeparator = nil;
	self.detailTableCellData = nil;
	
	// Detail header view
	self.detailHeaderViewFont = nil;
	self.detailHeaderViewGrayColor = nil;
	self.detailHeaderViewBlackColor = nil;
	self.detailHeaderViewBackgroundImage = nil;	
	
	// Overview table cache
	self.overviewCache_months = nil;
	self.overviewCache_cellCache = nil;
	
	// Detail Cache
	[self detailCache_clearCache];
	
}
- (void) updatedTransaction:(Transaction*)transaction {
		
	if (self.detailTableDelegate != nil) {
		[self detailCacheUpdatedTransaction:transaction];
	}
	
	[self overviewCacheUpdatedTransaction:transaction];

}
- (void) tellDelegatesItsWorthReloading {
	[self overviewCache_tellDelegateThatItsWorthUpdating];
	[self detailCache_tellDelegateThatItsWorthUpdating];
}
- (void) reloadDelegateData {
	
	@try {[self.overviewTableDelegate updateIfWorthIt];} 
	@catch (NSException * e) {/* Nothing to do... */}
	
	@try {[self.detailTableDelegate updateIfWorthIt];}
	@catch (NSException * e) {/* Nothing to do... */}
	
}
- (void)objectContextUpdated:(NSNotification *)notification {	
	// Merge changes
	[[[Utilities toolbox] managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];		
}
- (void)forceCleanAndReload {
	NSLog(@"*******************************************\n");
	NSLog(@"ERROR ERROR ERROR!\n");
	NSLog(@"Was forced to do a force clean and reload of data! Caching mechanism is gone wrong!\n");
	NSLog(@"*******************************************\n");
	[self overviewCache_removePersistentCache];
	[self clearCache];
	[self tellDelegatesItsWorthReloading];
	[self reloadDelegateData];
}
- (void)registerForManagedObjectContextNotifications {
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(objectContextUpdated:)
	 name:NSManagedObjectContextDidSaveNotification
	 object:nil];
}
- (void)deregisterForManagedObjectContextNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark -
#pragma mark Filtering
@synthesize tagWords, filterButton;
- (void) setTagWords:(NSArray *)tags {
	
	// first we need to keep the new tags
	[tags retain];
	[tagWords release];
	tagWords = tags;
	
	// reset the filtering button
	self.filterButton = nil;
	
	// create a predicate, and update the cache master
	
	NSPredicate * localFilteringPredicate;
	
	if ((tagWords == nil) || ([tagWords count] == 0)) {
		localFilteringPredicate = [NSPredicate predicateWithValue:YES];
		
	} else {
		
		NSMutableArray * tagPredicates = [[NSMutableArray alloc] init];
		
		for (NSString * tag in tagWords) {
			
			if ([[Utilities toolbox] doesTagExist:tag]) {
				// Create a predicate
				NSPredicate * autotagPredicate = [NSPredicate predicateWithFormat:@"autotags contains[cd] %@", [NSString stringWithFormat:@" %@ ", tag]];
				NSPredicate * tagPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] %@", [NSString stringWithFormat:@" %@ ", tag]];
				NSPredicate * orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:tagPredicate,autotagPredicate,nil]];			
				
				// Add to predicate list
				[tagPredicates addObject:orPredicate];
			}
			
		}
		
		localFilteringPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:tagPredicates];
		[tagPredicates release];
	}
	
	[self setFilteringPredicate:localFilteringPredicate];

}
- (void) toggleTagWord:(NSString*)tagWord {

	NSMutableArray * tagWords = [[[NSMutableArray alloc] initWithArray:[self tagWords]] autorelease];
	if ([tagWords containsObject:tagWord]) {
		[tagWords removeObject:tagWord];
	} else {
		[tagWords addObject:tagWord];
	}
	[self setTagWords:tagWords];
	
}
- (UIBarButtonItem*)filterButton {

	if (filterButton != nil) {
		return filterButton;
	}
		
	FilterButton * button;
	if ([[self filteringPredicate] isEqual:[self truePredicate]]) {
	
		button = [[FilterButton alloc] initWithFilterinNo];
	
 	} else {
		
		button = [[FilterButton alloc] initWithFilterinYes];
		
	}
	
	filterButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	[button release];
	
	return filterButton;
}


#pragma mark
#pragma mark -
#pragma mark DetailTable manager
@synthesize detailTableDelegate;
@synthesize detailCache_cellCache;
@synthesize detailCache_headerViewCache;
- (void) detailCache_clearCache {
	self.detailCache_cellCache = nil;
	self.detailCache_headerViewCache = nil;
	self.detailTableCellData = nil;
}
- (NSMutableDictionary*) detailCache_headerViewCache {
	if (detailCache_headerViewCache == nil) {
		detailCache_headerViewCache = [[NSMutableDictionary alloc] init];
	}
	return detailCache_headerViewCache;
}
- (NSMutableDictionary*) detailCache_cellCache {
	if (detailCache_cellCache == nil) {
		detailCache_cellCache = [[NSMutableDictionary alloc] init];
	}
	return detailCache_cellCache;
}
- (void) setDetailTableDelegate:(DetailTableModel*)delegate {
	/* 
	 If the delegate changes, then the cache automatically becomes stale
	 */
	[self detailCache_clearCache];
	detailTableDelegate = delegate;
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
			NSLog(@"Caught an error... but didn't do anything about it... CacheMaster");
		}
	}	
}
- (NSDictionary*) detailCache_dataForSection:(NSInteger)_section {
	
	/*
	 If we are trying to access an section that doesn't exists, 
	 ie is out of bounds, then we return nil
	 */
	
	NSNumber * section = [NSNumber numberWithInt:_section];
	
	if ([self.detailCache_cellCache objectForKey:section] == nil) {
	
		/*
		 Check if there are any transactions left
		 If not, then we throw an exception
		 */
		if ([[self.detailTableDelegate.resultsController sections] count] == 0) {
			[NSException raise:@"No data" format:@"Tried to access non existant section"];
		} else {
			if ([[self.detailTableDelegate.resultsController sections] count] < _section) {
				[NSException raise:@"No data" format:@"No transaction objects for given section"];	
			}
		}

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
	
		// Insert into dictionary
		[self.detailCache_cellCache setObject:data forKey:section];
	} 
	
	return [self.detailCache_cellCache objectForKey:section];
}
- (NSInteger) detailCache_numberOfSections {
	return [[self.detailTableDelegate.resultsController sections] count];
}
- (NSInteger) detailCache_numberOfRowsInSection:(NSInteger)section {
	/*
	 Optimize: Has to recalculate the amount of rows
	 each time it is refreshed while filtering!
	 */
		
	NSArray * transactions;
	NSInteger count;
	
	if ([self.filteringPredicate isEqual:self.truePredicate]){
		transactions = [[[self.detailTableDelegate.resultsController sections] objectAtIndex:section] objects];

	} else {
		NSArray * _transactions = [[[self.detailTableDelegate.resultsController sections] objectAtIndex:section] objects];
		transactions = [_transactions filteredArrayUsingPredicate:self.filteringPredicate];
	}
	
	count=0;
	
	// FIXME: Highly inefficient
	for (int n = 0; n < [transactions count]; n++) {
		if (![[transactions objectAtIndex:n] isDeleted]) {count++;}
	}
	
	return count;
}
- (void) detailCacheUpdatedTransaction:(Transaction*)transaction {
	
	NSString * yearMonth = transaction.yearMonth;
	NSString * oldYearMonth = transaction.oldYearMonth;
	NSString * yearMonthToDisplay = self.detailTableDelegate.yearMonth;
	
	BOOL worthUpdating = NO;
	
	if ([yearMonth isEqualToString:yearMonthToDisplay] || [oldYearMonth isEqualToString:yearMonthToDisplay]) {
		[self detailCache_clearCache];
		worthUpdating = YES;
	}
	
	if (worthUpdating) {
		[self detailCache_tellDelegateThatItsWorthUpdating];
	} 
	
}
- (UIView*) detailCache_headerViewForSection:(NSInteger)_section {
		
	/*
	 If there are no elements in the section, then we don't want to display it
	 */
	NSDictionary * data = [self detailCache_dataForSection:_section];
	
	NSInteger count = [[data objectForKey:@"transactions"] count];
	if (count == 0) {return nil;}
	
	NSString * section = [NSString stringWithFormat:@"%i", _section];
	
	if ([self.detailCache_headerViewCache objectForKey:section] == nil) {
		
		//[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderAndFooter" owner:self options:nil]; 
		DetailHeaderView * headerView = [[DetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
		
		[headerView setDate:[data objectForKey:@"date"] 
					 amount:[data objectForKey:@"amount"] 
			   andMonthYear:[self.detailTableDelegate title]];
				
		// Store view
		[self.detailCache_headerViewCache setObject:headerView forKey:section];
		[headerView release];
	}

	return [self.detailCache_headerViewCache objectForKey:section];
	
}
- (UIImageView*) detailCache_footerViewForSection:(NSInteger)_section {

	/*
	 If there are no elements in the section, then we don't want to display it
	 */
	NSDictionary * data;
	@try {data = [self detailCache_dataForSection:_section];}
	@catch (NSException * e) {return nil;}

	
	NSInteger count = [[data objectForKey:@"transactions"] count];
	if (count == 0) {
		return nil;
	} else {
		return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DetailCellFooter.png"]] autorelease];
	}

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
@synthesize detailTableCellData;
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
		detailTableCellSeparator = [[UIImage imageNamed:@"CellSeparator.png"] retain];
	}
	return detailTableCellSeparator;
}
- (NSMutableDictionary*)detailTableCellData {
	if (detailTableCellData == nil) {
		detailTableCellData = [[NSMutableDictionary alloc] init];
	}
	return detailTableCellData;
}

#pragma mark
#pragma mark -
#pragma mark Shared data for Detail header view
@synthesize detailHeaderViewFont;
@synthesize detailHeaderViewGrayColor;
@synthesize detailHeaderViewBlackColor;
@synthesize detailHeaderViewBackgroundImage;
- (UIFont*) detailHeaderViewFont {
	if (detailHeaderViewFont == nil) {
		detailHeaderViewFont = [[UIFont systemFontOfSize:15] retain];
	}
	return detailHeaderViewFont;
}
- (UIColor*) detailHeaderViewGrayColor {
	if (detailHeaderViewGrayColor == nil) {
		detailHeaderViewGrayColor = [[UIColor grayColor] retain];
	}
	return detailHeaderViewGrayColor;
}
- (UIColor*) detailHeaderViewBlackColor {
	if (detailHeaderViewBlackColor == nil) {
		detailHeaderViewBlackColor = [[UIColor blackColor] retain];
	}
	return detailHeaderViewBlackColor;
}
- (UIImage*) detailHeaderViewBackgroundImage {
	if (detailHeaderViewBackgroundImage == nil) {
		detailHeaderViewBackgroundImage = [[UIImage imageNamed:@"DetailCellHeader.png"] retain];
	}
	return detailHeaderViewBackgroundImage;
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
		
		/*
		 There is that odd chance that the Base currency has been edited
		 since the cache was made. If it hasn't, then we load the cache,
		 otherwise we don't and just wait for the cache to be rebuilt.
		 */
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"KleioCacheOldBaseCurrency"] != [[CurrencyManager sharedManager] baseCurrency]) {
			[[NSUserDefaults standardUserDefaults] setObject:[[CurrencyManager sharedManager] baseCurrency]
													  forKey:@"KleioCacheOldBaseCurrency"];
		} else {
			self.overviewCache_cellCache = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithFile:[self overviewCache_cachePath]];
		}
		
		if (overviewCache_cellCache == nil) { 
			// There didn't exist any cache. We create an empty dictionary
			overviewCache_cellCache = [[NSMutableDictionary alloc] init];
		}
	}
	return overviewCache_cellCache;
}
- (NSString*)overviewCache_cachePath {
	NSString *archivePath = [[[Utilities toolbox] applicationDocumentsDirectory] stringByAppendingPathComponent:@"OverviewTableCache.archive"];	
	return archivePath;
}
- (NSMutableArray*)overviewCache_months {
	if (overviewCache_months == nil) {
		
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
				id <NSFetchedResultsSectionInfo> currenctSection = [[self.overviewTableDelegate.resultsController sections] objectAtIndex:n];
				NSArray * _transactionsInSection = [currenctSection objects];
				Transaction * aTransaction = (Transaction*)[_transactionsInSection objectAtIndex:0];
				
				NSString * yearMonth = aTransaction.yearMonth;
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
				NSLog(@"ERROR: None of the transactions had a date! We had to fake one");
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
				
			} else {
				
				NSNumber * totalNumberOfObjectsInSection = [NSNumber numberWithInt:[_transactionsInSection count]];
				
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
			[self overviewCache_makePersistent];			
		} else {
			/*
			 We remove the cache completely in case a change is happening
			 while in filtermode and the user turns of the phone without ever
			 regenerating a valid cache
			 */
			[self overviewCache_removePersistentCache];
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
- (void) overviewCache_removePersistentCache {
	NSError * error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:[self overviewCache_cachePath] error:&error];
	
	if (error != nil) {
		NSLog(@"There was an error removing the cache: %@", error);
	}
}
- (NSInteger) overviewCache_numberOfRows {
	return [self.overviewCache_months count];
}
- (void)overviewCacheUpdatedTransaction:(Transaction*)transaction {
	
	/*
	 If there isn't an overview delegate, then we should just return
	 */
	if (self.overviewTableDelegate == nil) {
		/* 
		 There is no delegate. Hence there is no one
		 that can handle the change in data.
		 Hence we have to remove the persistant cache
		 */
		[self overviewCache_removePersistentCache];
		return;
	}
	
	NSString * yearMonth = transaction.yearMonth;
	
	if ([transaction isDeleted]) {
		
		[self overviewCache_delete:yearMonth];
	
	} else if (transaction.isNew) {

		[self overviewCache_insert:yearMonth];
		
	} else {
		
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
				[self overviewCache_insert:yearMonth];
				[self overviewCache_delete:transaction.oldYearMonth];
				
			} else if ([transaction.oldYearMonth compare:yearMonth] == NSOrderedDescending){
				[self overviewCache_delete:transaction.oldYearMonth];
				[self overviewCache_insert:yearMonth];
				
			} else if ([transaction.oldYearMonth compare:yearMonth] == NSOrderedSame){
				// Nothing to do...
			}
			
			
			
		} else {
			
			/*
			 Check if one of the values that make for a change
			 in the overview cache data has been changed
			 */
			if (([transaction.changes objectForKey:@"expense"] != nil) ||
					([transaction.changes objectForKey:@"kroner"] != nil) ||
					([transaction.changes objectForKey:@"currency"])) {
				
				/* 
				 It has a change to either:
				 expense: bool
				 kroner: NSNumber
				 currency: NSString
				 */
				[self overviewCache_removeCacheForYearMonth:yearMonth];
				[self overviewCache_tellDelegateThatItsWorthUpdating];
				
			} else {
				/* No interesting change has happened... */
			}
		}
	}
}
- (void)overviewCache_insert:(NSString*)yearMonth {
	
	if ([self.overviewCache_months containsObject:yearMonth]) {
		/* It has an entry. Let's clear it's cache */
		[self overviewCache_removeCacheForYearMonth:yearMonth];

	} else {
		/* It is a new entry! Insert it, and sort the array again */
		[self.overviewCache_months addObject:yearMonth];
		[self overviewCache_sortMonthsArray];
	}
	
	[self overviewCache_tellDelegateThatItsWorthUpdating];
	
}
- (void)overviewCache_delete:(NSString*)yearMonth {
	
	/*
	 Now we clear the cache, then we 
	 regenerate the cache to see if there is still any elements present
	 and if there is not, then we remove it completely from the list
	 */
	
	/*
	 Are we deleting the last element of a section?
	 */
//	NSLog(@"Removing overviewCache for yearMonth: %@", yearMonth);
//	[self overviewCache_removeCacheForYearMonth:yearMonth];
//	
//	NSInteger row = [self.overviewCache_months indexOfObject:yearMonth];
//	NSDictionary * cache = [self overviewCache_forRow:row];
//	NSInteger numberOfObjects = [(NSNumber*)[cache objectForKey:@"totNumObjects"] intValue];
//	NSLog(@"Checking how many transactions there are in the month %@: %i", yearMonth, numberOfObjects);
//	if (numberOfObjects <= 1) {
//		
//		NSLog(@"Deleting the last element of a section");
//		// We have to remove the element from the overview list
//		[self.overviewCache_months removeObjectAtIndex:row];
//		
//	}
//	
//	// The cache should be removed in any case
//	NSLog(@"Removing overviewCache for yearMonth a second time: %@", yearMonth);
//	[self overviewCache_removeCacheForYearMonth:yearMonth];
//	
//	// Tell delegate to reload table
//	[self overviewCache_tellDelegateThatItsWorthUpdating];
	

	[self overviewCache_removeCacheForYearMonth:yearMonth];
	if ([self.overviewCache_months containsObject:yearMonth]) {
		
		NSInteger row = [self.overviewCache_months indexOfObject:yearMonth];
		NSDictionary * dict = [self overviewCache_forRow:row];
		if (dict == nil) {
			/*
			 There is no cache value for this row,
			 hence it doesn't exist anymore and we should remove it from
			 the month array
			 */
			[self.overviewCache_months removeObjectAtIndex:row];
		}
		
		/*
		 Tell the delegat that it's worth updating
		 */
		[self overviewCache_tellDelegateThatItsWorthUpdating];
		
		
	} else {
		
		// Error. Wanted to delete, but there was no object in the months array with that for that month
		
	}
	
}
- (void)overviewCache_sortMonthsArray {
	NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO selector:@selector(compare:)];
	[overviewCache_months sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
	[sortDesc release];
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
			NSLog(@"Caught an error... but didn't do anything about it... CacheMaster");
		}

	}
}
- (void)overviewCache_removeCacheForYearMonth:(NSString*)yearMonth {
	[self.overviewCache_cellCache removeObjectForKey:yearMonth];
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
	// TODO: Add releasing of all the other variables that are held here...
	
	[super dealloc];
}


@end
