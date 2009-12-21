//
//  CacheManager.m
//  Finance
//
//  Created by Sebastian Probst Eide on 23.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "CacheMasterSingleton.h"
#import "Transaction.h"
#import "TransactionModel.h"
#import "NewOverviewTableViewController.h"

#import "Utilities.h"
#import "TestUtils.h"



@interface CacheManagerOverviewTableTests : SenTestCase {
	Transaction * trs;
	OverviewTableModel * controller;
	
	NSManagedObjectContext * context;
	NSManagedObjectContext * otherContext;
}
- (Transaction*)getTransaction;
@end

@implementation CacheManagerOverviewTableTests

- (void)setUp {
	NSLog(@"\n\n*********** SETUP ***********");
	
	// Have to ensure that it has registered for callbacks
	[[CacheMasterSingleton sharedCacheMaster] registerForManagedObjectContextNotifications];
	context = [[TestUtils managedObjectContext] retain];
	otherContext = [[TestUtils managedObjectContext] retain];
	
	[[Utilities toolbox] setManagedObjectContext:otherContext];
	
	[[CacheMasterSingleton sharedCacheMaster] registerForManagedObjectContextNotifications];
	
	trs	 = [self getTransaction];
	
	controller = [[OverviewTableModel alloc] init] ;
	[controller loadData];
	
}
- (void) tearDown {

	[[CacheMasterSingleton sharedCacheMaster] clearCache];
	[TestUtils clearData];
	[[Utilities toolbox] setManagedObjectContext:nil];
	[otherContext release];
	context = nil;
	[controller release];
	[trs release];

	[[CacheMasterSingleton sharedCacheMaster] setOverviewTableDelegate:nil];
	[[CacheMasterSingleton sharedCacheMaster] setDetailTableDelegate:nil];
	
	[[CacheMasterSingleton sharedCacheMaster] deregisterForManagedObjectContextNotifications];
	
	[[Utilities toolbox] setManagedObjectContext:nil];
	[[Utilities toolbox] setAddTransactionManagedObjectContext:nil];
	
	NSLog(@"*********** TEAR DOWN *********** \n\n");
}
- (Transaction*)getTransactionFromContext:(NSManagedObjectContext*)theContext {
	Transaction * _trs = [NSEntityDescription
												insertNewObjectForEntityForName:@"Transaction"
												inManagedObjectContext:theContext]; 
	
	STAssertNotNil(_trs, @"Should have a transaction");
	
	return _trs;
}
- (Transaction*)getTransaction {
	return [self getTransactionFromContext:context];;
}


#pragma mark Set delegate
-(void) testSetDelegate {
	id newController = [[OverviewTableModel alloc] init];
	STAssertNotNil([[CacheMasterSingleton sharedCacheMaster] overviewTableDelegate], @"The overview table view controller should set itself as a delegate");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] overviewTableDelegate], newController, @"Should have set itself as delegate");
	[newController release];
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] overviewTableDelegate], @"The overview table view controller should set to nil on dealloc");
}


#pragma mark Adding Transactions
-(void) testUpdatedCacheAdd {
	
	[trs release];
	trs = [self getTransactionFromContext:otherContext];
	
	trs.kroner = [NSNumber numberWithInt:1400];
	[[Utilities toolbox] save:otherContext];
	
	NSDictionary * dict = [[CacheMasterSingleton sharedCacheMaster] overviewCache_forRow:0];
	int amount = [[dict valueForKey:@"rawAmount"] intValue];
	
	// FIXME: test
	//STAssertEquals(amount, -14, @"Amount should be right");
	
	Transaction * t2 = [self getTransactionFromContext:otherContext];
	t2.kroner = [NSNumber numberWithInt:2000];
	t2.expense = [NSNumber numberWithBool:NO];
	
	NSLog(@"****** I AM HERE *********");
	[[Utilities toolbox] save:otherContext];
	
	dict = [[CacheMasterSingleton sharedCacheMaster] overviewCache_forRow:0];
	amount = [[dict valueForKey:@"rawAmount"] intValue];

	// FIXME: test
	//STAssertEquals(amount, 6, @"Amount should be right");
	
}

-(void) testNumberOfMonthsAdd {
	
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:-(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	
	trs.date = date1;
	[[Utilities toolbox] save:context];

	STAssertNotNil([CacheMasterSingleton sharedCacheMaster].overviewCache_months, @"Should have populated the months array");
	NSInteger numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	for (int n = 0; n<numOfMonths;n++) {
		NSLog(@"Has month: %@", [[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:n]);
	}
	STAssertEquals(numOfMonths, 1, @"Should have 1 month entry");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197001", @"Should have an entry for Jan 1970");
	
	// Adding another transaction to the mix.
	Transaction * t1 = [self getTransaction];
	t1.date = date1;
	
	[[Utilities toolbox] save:context];
	
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 1, @"Should have 1 month entry");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197001", @"Should have an entry for Jan 1970");
	
	// Adding a month with another date
	Transaction * t2 = [self getTransaction];
	t2.date = date2;
	
	[[Utilities toolbox] save:context];
	
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have 2 month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have an entry for Feb 1970");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197001", @"Should have an entry for Jan 1970");

	
	// Adding yet another transaction with the same month
	Transaction * t3 = [self getTransaction];
	t3.date = date2;
	
	[[Utilities toolbox] save:context];
	
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have 2 month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have an entry for Feb 1970");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197001", @"Should have an entry for Jan 1970");
	
	// Adding a transaction with a new month
	Transaction * t4 = [self getTransaction];
	t4.date = date3;
	
	[[Utilities toolbox] save:context];
	
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have 3 month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have an entry for Mar 1970");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have an entry for Feb 1970");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"197001", @"Should have an entry for Jan 1970");
	
	// Adding an earlier transaction
	Transaction * t5 = [self getTransaction];
	t5.date = date4;
	
	[[Utilities toolbox] save:context];
	
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 4, @"Should have 4 month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have an entry for Mar 1970");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have an entry for Feb 1970");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"197001", @"Should have an entry for Jan 1970");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:3], @"196910", @"Should have an entry for Oct 1970");
	
}

#pragma mark Deleting transactions
-(void) testWorthUpdatingDelete {
	[trs release];
	trs = [self getTransactionFromContext:otherContext];
	
	trs.kroner = [NSNumber numberWithInt:140];
	[[Utilities toolbox] save:otherContext];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] overviewCache_numberOfRows], 1, @"Should only have a row for the one object that has been added");
		
	[otherContext deleteObject:trs];
	NSLog(@"********** I AM HERE ***********");
	[[Utilities toolbox] save:otherContext];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] overviewCache_numberOfRows], 0, @"Should not have rows for non existant objects");

}

-(void) testNumberOfMonthsDelete {
		
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:-(2 * 31 * 24 * 60 * 60)]; // 1 Octobe 1969
	
	[trs release];
	trs = [self getTransactionFromContext:otherContext];
	Transaction * t2 = [self getTransactionFromContext:otherContext];
	Transaction * t3 = [self getTransactionFromContext:otherContext];
	Transaction * t4 = [self getTransactionFromContext:otherContext];
	Transaction * t5 = [self getTransactionFromContext:otherContext];
	Transaction * t6 = [self getTransactionFromContext:otherContext];
	
	trs.date = date1;
	t2.date = date1;
	t3.date = date2;
	t4.date = date2;
	t5.date = date3;
	t6.date = date4;
	
	[[Utilities toolbox] save:otherContext];
	
	NSInteger numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 4, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"197001", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:3], @"196910", @"Should have the correnct month name");
	
	NSLog(@"Deleting one transaction from month 197001. Should be 1 left");
	[otherContext deleteObject:trs];
	NSLog(@"Saving deletion...");
	[[Utilities toolbox] save:otherContext];

	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 4, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"197001", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:3], @"196910", @"Should have the correnct month name");

	NSLog(@"Deleting the last object from month 197001. Should be 0 left");
	[otherContext deleteObject:t2];
	NSLog(@"Saving deletion...");
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have the right amount of month entries");	
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"196910", @"Should have the correnct month name");

	[otherContext deleteObject:t5];
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have the right amount of month entries");	
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"196910", @"Should have the correnct month name");
	

	[otherContext deleteObject:t6];
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 1, @"Should have the right amount of month entries");	
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	
	[otherContext deleteObject:t3];
	[otherContext deleteObject:t4];
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 0, @"Should have the right amount of month entries");	
	
}

-(void) testNumberOfMonthsMove {
	
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:-(2 * 31 * 24 * 60 * 60)]; // 1 October 1969
	
	[trs release];
	trs = [self getTransactionFromContext:otherContext];
	Transaction * t2 = [self getTransactionFromContext:otherContext];
	Transaction * t3 = [self getTransactionFromContext:otherContext];
	Transaction * t4 = [self getTransactionFromContext:otherContext];
	Transaction * t5 = [self getTransactionFromContext:otherContext];
	Transaction * t6 = [self getTransactionFromContext:otherContext];
	
	trs.date = date2;
	t2.date = date2;
	t3.date = date2;
	t4.date = date2;
	t5.date = date2;
	t6.date = date2;
	
	[[Utilities toolbox] save:otherContext];
	
	NSInteger numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 1, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	
	// Moving it way back in time
	trs.date = date4;
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"196910", @"Should have the correnct month name");
	
	t2.date = date1;
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197001", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"196910", @"Should have the correnct month name");
	
	t2.date = date4;
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"196910", @"Should have the correnct month name");

	t3.date = date3;
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"196910", @"Should have the correnct month name");
	
	t4.date = date1;
	t5.date = date4;
	t6.date = date3;
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197001", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"196910", @"Should have the correnct month name");
	
	trs.date = date4;
	t2.date = date4;
	t3.date = date4;
	t4.date = date4;
	t5.date = date4;
	t6.date = date4;
	[[Utilities toolbox] save:otherContext];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 1, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"196910", @"Should have the correnct month name");
	
}

@end