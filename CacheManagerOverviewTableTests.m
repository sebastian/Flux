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
#import "OverviewTableViewController.h"

#import "Utilities.h"
#import "TestUtils.h"


@interface CacheManagerOverviewTableTests : SenTestCase {
	Transaction * trs;
	OverviewTableViewController * controller;
	
	NSManagedObjectContext * context;
}
- (Transaction*)getTransaction;
@end

@implementation CacheManagerOverviewTableTests

- (void)setUp {
	NSLog(@"\n\n*********** SETUP ***********");
	
	context = [TestUtils managedObjectContext];
	controller = [[OverviewTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context];
	[[CacheMasterSingleton sharedCacheMaster] setOverviewTableDelegate:controller];
	
	trs	 = [self getTransaction];
	
	[[Utilities toolbox] setManagedObjectContext:context];
	
}
- (void) tearDown {
	[[CacheMasterSingleton sharedCacheMaster] setOverviewTableDelegate:nil];
	[[CacheMasterSingleton sharedCacheMaster] clearCache];
	[TestUtils clearData];
	context = nil;
	[controller release];
	[trs release];
	
	NSLog(@"*********** TEAR DOWN *********** \n\n");
}
- (Transaction*)getTransaction {
	Transaction * _trs = [NSEntityDescription
			insertNewObjectForEntityForName:@"Transaction"
			inManagedObjectContext:context]; 
	
	STAssertNotNil(_trs, @"Should have a transaction");
	
	return _trs;
}

#pragma mark Set delegate
-(void) testSetDelegate {
	id newController = [[OverviewTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context];
	[newController viewDidLoad];
	STAssertNotNil([[CacheMasterSingleton sharedCacheMaster] overviewTableDelegate], @"The overview table view controller should set itself as a delegate");
	STAssertEqualObjects([CacheMasterSingleton sharedCacheMaster].overviewTableDelegate, newController, @"Should have set itself as delegate");
	[newController release];
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] overviewTableDelegate], @"The overview table view controller should set to nil on dealloc");
}

#pragma mark Adding Transactions
-(void) testWorthUpdatingAdd {
		
	STAssertEquals(controller.worthUpdating, NO, @"Should not be worth updating by default");
	
	trs.kroner = [NSNumber numberWithInt:140];

	[[Utilities toolbox] save:context];
	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
		
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
	trs.kroner = [NSNumber numberWithInt:140];
	[[Utilities toolbox] save:context];
	controller.worthUpdating = NO;
	[context deleteObject:trs];
	[[Utilities toolbox] save:context];
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after delete");
	
}
-(void) testNumberOfMonthsDelete {
	
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:-(2 * 31 * 24 * 60 * 60)]; // 1 Octobe 1969
	
	Transaction * t2 = [self getTransaction];
	Transaction * t3 = [self getTransaction];
	Transaction * t4 = [self getTransaction];
	Transaction * t5 = [self getTransaction];
	Transaction * t6 = [self getTransaction];
	
	trs.date = date1;
	t2.date = date1;
	t3.date = date2;
	t4.date = date2;
	t5.date = date3;
	t6.date = date4;
	
	[[Utilities toolbox] save:context];
	
	NSInteger numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 4, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"197001", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:3], @"196910", @"Should have the correnct month name");
	
	[context deleteObject:trs];
	[[Utilities toolbox] save:context];

	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 4, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"197001", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:3], @"196910", @"Should have the correnct month name");

	[context deleteObject:t2];
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have the right amount of month entries");	
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"196910", @"Should have the correnct month name");

	[context deleteObject:t5];
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have the right amount of month entries");	
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"196910", @"Should have the correnct month name");
	

	[context deleteObject:t6];
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 1, @"Should have the right amount of month entries");	
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	
	[context deleteObject:t3];
	[context deleteObject:t4];
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 0, @"Should have the right amount of month entries");	
	
}

#pragma mark Updating transactions
-(void) testWorthUpdatingUpdate {
	trs.kroner = [NSNumber numberWithInt:140];
	[[Utilities toolbox] save:context];
	controller.worthUpdating = NO;

	trs.kroner = [NSNumber numberWithInt:240];
	[[Utilities toolbox] save:context];
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after update");
	controller.worthUpdating = NO;
	
	trs.kroner = [NSNumber numberWithInt:240];
	[[Utilities toolbox] save:context];
	STAssertEquals(controller.worthUpdating, NO, @"Should not be worth updating if the value hasn't changed");

}
-(void) testNumberOfMonthsMove {
	
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:-(2 * 31 * 24 * 60 * 60)]; // 1 October 1969
	
	Transaction * t2 = [self getTransaction];
	Transaction * t3 = [self getTransaction];
	Transaction * t4 = [self getTransaction];
	Transaction * t5 = [self getTransaction];
	Transaction * t6 = [self getTransaction];
	
	trs.date = date2;
	t2.date = date2;
	t3.date = date2;
	t4.date = date2;
	t5.date = date2;
	t6.date = date2;
	
	[[Utilities toolbox] save:context];
	
	NSInteger numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 1, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	
	// Moving it way back in time
	trs.date = date4;
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"196910", @"Should have the correnct month name");
	
	t2.date = date1;
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197001", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"196910", @"Should have the correnct month name");
	
	t2.date = date4;
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 2, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"196910", @"Should have the correnct month name");

	t3.date = date3;
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 3, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"197003", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:1], @"197002", @"Should have the correnct month name");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:2], @"196910", @"Should have the correnct month name");
	
	t4.date = date1;
	t5.date = date4;
	t6.date = date3;
	[[Utilities toolbox] save:context];
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
	[[Utilities toolbox] save:context];
	numOfMonths = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	STAssertEquals(numOfMonths, 1, @"Should have the right amount of month entries");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster].overviewCache_months objectAtIndex:0], @"196910", @"Should have the correnct month name");
	
}

@end
