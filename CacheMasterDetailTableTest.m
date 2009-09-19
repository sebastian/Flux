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
#import "DetailTableViewController.h"
#import "OverviewTableViewController.h"
#import "TransactionsNavigationController.h"

#import "Utilities.h"
#import "TestUtils.h"


@interface CacheManagerDetailTableTests : SenTestCase {
	Transaction * trs;
	DetailTableViewController * controller;
	
	TransactionsNavigationController * transNavController;
	
	NSManagedObjectContext * context;
}
- (Transaction*)getTransaction;
@end

@implementation CacheManagerDetailTableTests

- (void)setUp {
		
	context = [[TestUtils managedObjectContext] retain];
	controller = [[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context];
	
	controller.yearMonthToDisplay = @"197001";
		
	[controller viewDidLoad];
	
	trs	 = [self getTransaction];
	
	[[Utilities toolbox] setManagedObjectContext:context];
	
	NSLog(@"*********** START OF METHOD ***********");
}
- (void) tearDown {
	NSLog(@"*********** END OF METHOD ***********");	
	[trs release];
	[context release];
	context = nil;
	
	[controller release];
	controller = nil;
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Detail delegate should be nil after the controller has been released");
	
	[[CacheMasterSingleton sharedCacheMaster] clearCache];
	[TestUtils clearData];
	[[Utilities toolbox] clearCache];
	[[Utilities toolbox] setManagedObjectContext:nil];	
	
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
	[transNavController popViewControllerAnimated:NO];
	[controller release];
	controller = nil;
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Should be nil after controller release");
	controller = [[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context];
	controller.yearMonthToDisplay = @"198001";
	[controller viewDidLoad];
	STAssertNotNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Should have set itself through viewDidLoad");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], controller, @"Should have set itself as the delegate");
}

#pragma mark Adding Transactions
-(void) testWorthUpdatingAdd {
	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating by default");
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	
	NSInteger numOfElements;
	
	trs.date = date1;
	trs.kroner = [NSNumber numberWithInt:140];
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");

	Transaction * t2 = [self getTransaction];
	t2.date = date2;
	controller.worthUpdating = NO;
	[[Utilities toolbox] save:context];
	STAssertEquals(controller.worthUpdating, NO, @"Should not care about transactions that don't belong to the detail view");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	Transaction * t3 = [self getTransaction];
	t3.date = date1;
	controller.worthUpdating = NO;
	[[Utilities toolbox] save:context];
	STAssertEquals(controller.worthUpdating, YES, @"Should care about transactions that belong to the detail view");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	Transaction * t4 = [self getTransaction];
	t4.date = date3;
	controller.worthUpdating = NO;
	[[Utilities toolbox] save:context];
	STAssertEquals(controller.worthUpdating, NO, @"Should not care about transactions that don't belong to the detail view");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
}

#pragma mark Deleting transactions
-(void) testWorthUpdatingDelete {
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating by default");
	controller.worthUpdating = NO;
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	
	NSInteger numOfElements;
	
	Transaction * t2 = [self getTransaction];
	Transaction * t3 = [self getTransaction];
	Transaction * t4 = [self getTransaction];
	
	trs.date = date1;
	t2.date = date1;
	t3.date = date2;
	t4.date = date3;
	
	// Adding 4 new transactions. Not all in the same month
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	// Deleting object in the current view
	[controller setWorthUpdating:NO];
	[context deleteObject:trs];
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	// Deleting object from another view
	[controller setWorthUpdating:NO];
	[context deleteObject:t3];
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, NO, @"Should be worth updating after save");

	// Deleting another object not in the view
	[controller setWorthUpdating:NO];
	[context deleteObject:t4];
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, NO, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];

	// Deleting object in view
	[controller setWorthUpdating:NO];
	[context deleteObject:t2];
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");	
}

#pragma mark Updating transactions
-(void) testWorthUpdatingUpdate {

	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating by default");
	controller.worthUpdating = NO;
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(31 * 24 * 60 * 60)]; // 1 February 1970
	NSDate * date3 =[NSDate dateWithTimeIntervalSince1970:(2 * 31 * 24 * 60 * 60)]; // 1 March 1970
	NSDate * date4 =[NSDate dateWithTimeIntervalSince1970:(2 * 24 * 60 * 60)]; // 3 January 1970
	NSInteger numOfElements;
	
	Transaction * t2 = [self getTransaction];
	Transaction * t3 = [self getTransaction];
	Transaction * t4 = [self getTransaction];
	
	trs.date = date1;
	t2.date = date1;
	t3.date = date2;
	t4.date = date2;
	
	[[Utilities toolbox] save:context];	
	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	[controller setWorthUpdating:NO];

	t2.date = date2;
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	t3.date = date3;
	[controller setWorthUpdating:NO];
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, NO, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	t4.date = date1;
	[controller setWorthUpdating:NO];
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	[controller setWorthUpdating:NO];
	t2.date = date1;
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	
	[controller setWorthUpdating:NO];
	t2.date = date4;
	[[Utilities toolbox] save:context];	
	STAssertEquals(controller.worthUpdating, YES, @"Should be worth updating after save");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
	numOfElements = [[[CacheMasterSingleton sharedCacheMaster] detailCache_headerViewCache] count];
	STAssertEquals(numOfElements, 0, @"Shouldn't have any elements");
}

@end
