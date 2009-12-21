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
#import "NewDetailTableViewController.h"
#import "TransactionModel.h"

#import "Utilities.h"
#import "TestUtils.h"


@interface CacheManagerDetailTableTests : SenTestCase {
	Transaction * trs;
	DetailTableModel * controller;
	
	NSManagedObjectContext * context;
}
- (Transaction*)getTransaction;
@end

@implementation CacheManagerDetailTableTests

- (void)setUp {
	
	NSLog(@"Starting setup");
	
	NSLog(@"Getting alternative object context for utilities");
	NSManagedObjectContext * otherContext = [TestUtils managedObjectContext];
	NSLog(@"Setting alternative object context for utilities");
	[[Utilities toolbox] setManagedObjectContext:otherContext];
	
	// Have to ensure that it has registered for callbacks
	NSLog(@"Register cache master for callbacks");
	[[CacheMasterSingleton sharedCacheMaster] registerForManagedObjectContextNotifications];

	NSLog(@"Create local managed object context");
	context = [[TestUtils managedObjectContext] retain];
	
	NSLog(@"Creating a controller");
	controller = [[DetailTableModel alloc] initWithYearMonth:@"197001"];
	
	STAssertNotNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Should have a delegate");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], controller, @"Should have set itself as delegate");
	
	// To create a NSFetchedResultsController that can respond to changes...
	[controller loadData];
	
	trs	 = [self getTransaction];
	
	NSLog(@"*********** START OF METHOD ***********");
}
- (void) tearDown {
	NSLog(@"*********** END OF METHOD ***********");	
	[trs release];
	[context release];
	context = nil;
	
	[controller dealloc];
	controller = nil;
	
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Detail delegate should be nil after the controller has been released");
	
	NSLog(@"Removing CacheMaster cache");
	[[CacheMasterSingleton sharedCacheMaster] clearCache];
	NSLog(@"Clearing utilities cache");
	[[Utilities toolbox] clearCache];

	NSLog(@"Setting managedObjectContext to nil");
	[[Utilities toolbox] setManagedObjectContext:nil];	

	NSLog(@"Clearing test utils data");
	[TestUtils clearData];
	
	[[CacheMasterSingleton sharedCacheMaster] deregisterForManagedObjectContextNotifications];
	
	NSLog(@"Done with run");
	
}
- (Transaction*)getTransaction {
	Transaction * _trs = [NSEntityDescription
						  insertNewObjectForEntityForName:@"Transaction"
						  inManagedObjectContext:context]; 
	
	STAssertNotNil(_trs, @"Should have a transaction");
	
	return _trs;
}

#pragma mark Set delegate
-(void) testSetDelegateAndYearMonth {
	NSLog(@"Starting test testSetDelegateAndYearMonth");
	NSLog(@"Retain count before releasing: %i", [controller retainCount]);
	[controller dealloc];
	controller = nil;
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Should be nil after controller release");

	controller = [[DetailTableModel alloc] initWithYearMonth:@"198001"];
	
	STAssertNotNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Should have set itself through viewDidLoad");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], controller, @"Should have set itself as the delegate");
}

#pragma mark Adding Transactions
-(void) testCacheAfterAdd {
	NSLog(@"Starting test testCacheAfterAdd");
	
	STAssertTrue(controller.worthUpdating, @"Should be worth updating by default");
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:(1.1 * 24 * 60 * 60)]; // 2 (plus a little) January 1970 
	
	trs.date = date1;
	trs.kroner = [NSNumber numberWithInt:140];
	[[Utilities toolbox] save:context];	
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have one section");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have only one element");
	
	// Add a transaction that doesn't change the given controller
	// TODO: add a way to check if it gets updated or checked...
	Transaction * t2 = [self getTransaction];
	t2.date = date2;
	[[Utilities toolbox] save:context];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have one");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have only one element");
		
	// Add a new transaction to the same month
	Transaction * t3 = [self getTransaction];
	t3.date = date4;
	[[Utilities toolbox] save:context];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 2, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element in each section");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:1], 1, @"Should have one element in each section");

	// Add a new transaction to the same month and same day as the first
	Transaction * t4 = [self getTransaction];
	t4.date = date1;
	[[Utilities toolbox] save:context];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 2, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element in each section");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:1], 2, @"Should have two elements for the first day");
	
	// A different month, shouldn't really care
	Transaction * t5 = [self getTransaction];
	t5.date = date3;
	[[Utilities toolbox] save:context];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 2, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element in each section");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:1], 2, @"Should have two elements for the first day");
	
}

#pragma mark Deleting transactions
-(void) testCacheAfterDelete {
	
	[controller loadData];
	
	STAssertTrue(controller.worthUpdating, @"Should be worth updating by default");
	controller.worthUpdating = NO;
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
		
	Transaction * t2 = [self getTransaction];
	Transaction * t3 = [self getTransaction];
	Transaction * t4 = [self getTransaction];
	
	trs.date = date1;
	t2.date = date1;
	t3.date = date2;
	t4.date = date3;
	
	// Adding 4 new transactions. Not all in the same month
	[[Utilities toolbox] save:context];	
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 2, @"Should have two elements for the 1st day");
	
	// Deleting object in the current view
	[context deleteObject:trs];
	[[Utilities toolbox] save:context];	
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element for the 1st day");
	
	// Deleting object from another view
	[controller setWorthUpdating:NO];
	[context deleteObject:t3];
	[[Utilities toolbox] save:context];	
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element for the 1st day");

	// Deleting another object not in the view
	[controller setWorthUpdating:NO];
	[context deleteObject:t4];
	[[Utilities toolbox] save:context];	
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element for the 1st day");

	// Deleting object in view
	[controller setWorthUpdating:NO];
	[context deleteObject:t2];
	NSLog(@"*************** I AM HERE ***************");
	[[Utilities toolbox] save:context];	
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have one section that is empty");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 0, @"Should have no elements in the section");

}

#pragma mark Updating transactions
-(void) testCacheAfterUpdate {
	
	NSManagedObjectContext * otherContext = [[Utilities toolbox] managedObjectContext];
	
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:(2 * 24 * 60 * 60)]; // 3 January 1970
	
	Transaction * t2 = [self getTransaction];
	Transaction * t3 = [self getTransaction];
	Transaction * t4 = [self getTransaction];
	
	trs.date = date1;
	t2.date = date1;
	t3.date = date4;
	t4.date = date2;

	[[Utilities toolbox] save:context];	
	
	// Should have an entry for the month
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 2, @"Should have one section");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element for the 1st day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:1], 2, @"Should have two element for the 2nd day");
	
	// Move one of the transactions in the section to another month
	// Should have one in each section left
	Transaction * d1 = [[[[controller.resultsController sections] objectAtIndex:1] objects] objectAtIndex:0];
	d1.date = date3;
	[[Utilities toolbox] save:otherContext];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 2, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element for the 1st day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:1], 1, @"Should have one element for the 1st day");

	// Remove the one from the 1st section
	// Now the lowest section was promoted to the first
	Transaction * d2 = [[[[controller.resultsController sections] objectAtIndex:0] objects] objectAtIndex:0];
	d2.date = date2;
	[[Utilities toolbox] save:otherContext];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 1, @"Should have two sections, one for each day");
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfRowsInSection:0], 1, @"Should have one element for the 1st day");

	// Remove the one from the 1st section
	// Should have no more sections
	Transaction * d3 = [[[[controller.resultsController sections] objectAtIndex:0] objects] objectAtIndex:0];
	d3.date = date2;
	[[Utilities toolbox] save:otherContext];
	STAssertEquals([[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections], 0, @"Should have one sections, one for each day");

}

@end
