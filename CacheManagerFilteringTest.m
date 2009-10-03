//
//  CacheManagerFiltering.m
//  Finance
//
//  Created by Sebastian Probst Eide on 01.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "CacheMasterSingleton.h"
#import "TestUtils.h"
#import "OverviewTableViewController.h"
#import "DetailTableViewController.h"
#import "Utilities.h"
#import "Transaction.h"
#import "KleioSearchBar.h"

@interface CacheManagerFilteringTest : SenTestCase {
	DetailTableViewController * controller;
	OverviewTableViewController * overviewController;
	NSManagedObjectContext * context;
	KleioSearchBar * searchBar;
}
- (Transaction*)getTransaction;
- (void) populateCacheOverview;
- (void) populateCacheDetail;
@end

@implementation CacheManagerFilteringTest
- (void)setUp {
	
	NSManagedObjectContext* uContext = [TestUtils managedObjectContext];
	[[Utilities toolbox] setManagedObjectContext:uContext];	
	
	context = [[TestUtils managedObjectContext] retain];
	
	controller = [[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context];
	overviewController = [[OverviewTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context];

	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster] overviewTableDelegate], overviewController, @"Should have set right delegate");
	STAssertEqualObjects([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], controller, @"Should have set right delegate");
	
	controller.yearMonthToDisplay = @"197001";
	NSDate * date1 =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	NSDate * date2 =[NSDate dateWithTimeIntervalSince1970:(32 * 24 * 60 * 60)]; // 1 January 1970
	
	Transaction * t1 = [self getTransaction];
	Transaction * t2 = [self getTransaction];
	Transaction * t3 = [self getTransaction];
	Transaction * t4 = [self getTransaction];
	Transaction * t5 = [self getTransaction];
	Transaction * t6 = [self getTransaction];
	Transaction * t7 = [self getTransaction];
	Transaction * t8 = [self getTransaction];
	Transaction * t9 = [self getTransaction];
	Transaction * t10 = [self getTransaction];

	NSNumber * kroner = [NSNumber numberWithInt:240];
	t1.kroner = kroner;
	t2.kroner = kroner;
	t3.kroner = kroner;
	t4.kroner = kroner;
	t5.kroner = kroner;
	t6.kroner = kroner;
	t7.kroner = kroner;
	t8.kroner = kroner;
	t9.kroner = kroner;
	t10.kroner = kroner;
		
	t1.date = date1;
	t2.date = date1;
	t3.date = date1;
	t4.date = date1;
	t5.date = date1;
	t6.date = date1;
	t7.date = date1;
	t8.date = date1;
	t9.date = date1;
	t10.date = date2;
	
	t1.tags = @"hallo test";
	t2.tags = @"hallo test";
	t3.tags = @"hallo";
	t4.tags = @"hallo";
	t5.tags = @"halloi testi";
	t6.tags = @"halloi";
	t7.tags = @"something";
	t8.tags = @"else";
	t9.tags = @"";
	t10.tags = @"";
	
	[[Utilities toolbox] save:context];
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:[NSPredicate predicateWithValue:YES]];
	
	TTLOG(@"*********** START OF METHOD ***********");
}
- (void) tearDown {
	TTLOG(@"*********** END OF METHOD ***********");	
	[controller release];
	controller = nil;
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] detailTableDelegate], @"Detail delegate should be nil after the controller has been released");
	
	[overviewController release];
	overviewController = nil;
	STAssertNil([[CacheMasterSingleton sharedCacheMaster] overviewTableDelegate], @"Overview table delegate should be nil after the controller has been released");
	
	[[CacheMasterSingleton sharedCacheMaster] clearCache];
	[[Utilities toolbox] clearCache];
	[[Utilities toolbox] setManagedObjectContext:nil];	
	
	[context release];
	context = nil;
	
	[TestUtils clearData];
	
}
- (Transaction*)getTransaction {
	Transaction * _trs = [NSEntityDescription
						  insertNewObjectForEntityForName:@"Transaction"
						  inManagedObjectContext:context]; 
	
	STAssertNotNil(_trs, @"Should have a transaction");
	
	return _trs;
}
- (void) populateCacheOverview {
	[[CacheMasterSingleton sharedCacheMaster] overviewCache_months]; // Get amount of months
	NSInteger monthCount = [[CacheMasterSingleton sharedCacheMaster].overviewCache_months count];
	for (int n = 0; n < monthCount; n++) {
		[[CacheMasterSingleton sharedCacheMaster] overviewCache_forRow:n];
	}
}
- (void) populateCacheDetail {
	NSInteger dayCount = [[CacheMasterSingleton sharedCacheMaster] detailCache_numberOfSections];
	for (int n = 0; n < dayCount; n++) {
		[[CacheMasterSingleton sharedCacheMaster] detailCache_dataForSection:n];
	}
}
/*
 TAGS:
 hallo 
 test
 halloi
 testi
 something
 else
*/ 
- (void) testPropagationOfPredicates {
	NSPredicate * newPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] \" hallo \""];
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:newPredicate];
	BOOL equality = [[[CacheMasterSingleton sharedCacheMaster] truePredicate] isEqual:[[CacheMasterSingleton sharedCacheMaster] filteringPredicate]];
	STAssertFalse(equality, @"Should have updated the filtering predicate");
}
- (void) testSetPredicatesOverview {
	[self populateCacheOverview];
	NSDictionary * dict;
		
	NSPredicate * newPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] \" hallo \""];
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:newPredicate];
	
	// Should have cleared the current dict
	dict = [[CacheMasterSingleton sharedCacheMaster] overviewCache_cellCache];
	STAssertEquals((NSInteger)[dict count], 0, @"Shouldn't have any elements");
		
	// It should have elements after the cache has been populated
	[self populateCacheOverview];
	dict = [[CacheMasterSingleton sharedCacheMaster] overviewCache_cellCache];
	NSInteger elementCount = [dict count];
	STAssertTrue(elementCount == 2, @"Should have an element");
	NSInteger amount1 = [[[dict objectForKey:@"197001"] objectForKey:@"rawAmount"] intValue];
	NSInteger amount2 = [[[dict objectForKey:@"197002"] objectForKey:@"rawAmount"] intValue];
	STAssertTrue(amount1 != 0, @"Should have an amount");
	STAssertEquals(amount2, 0, @"Should have no amount");
	
	
	// Should not clear the cache if the same predicate is set again
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:newPredicate];
	NSDictionary * tempDict = [[CacheMasterSingleton sharedCacheMaster] overviewCache_cellCache];
	NSInteger newElementCount = [dict count];
	STAssertTrue(newElementCount == elementCount, @"Should have the same amount of elements");
	STAssertEqualObjects([dict objectForKey:@"yearMonth"], [tempDict objectForKey:@"yearMonth"], @"Should have the same values");
	amount1 = [[[dict objectForKey:@"197001"] objectForKey:@"rawAmount"] intValue];
	amount2 = [[[dict objectForKey:@"197002"] objectForKey:@"rawAmount"] intValue];
	STAssertTrue(amount1 != 0, @"Should have an amount");
	STAssertEquals(amount2, 0, @"Should have no amount");
	
}
- (void) testDeleteAndChangeWhileFilteringForOverview {

	Transaction * toDelete = [self getTransaction];
	toDelete.date = [NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	toDelete.kroner = [NSNumber numberWithInt:100];
	[[Utilities toolbox] save:context];
	
	[self populateCacheOverview];
	NSDictionary * originalDict = [[[CacheMasterSingleton sharedCacheMaster] overviewCache_cellCache] copy];
	
	NSPredicate * newPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] \" hallo \""];
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:newPredicate];
	[self populateCacheOverview];
	NSDictionary * dict = [[[CacheMasterSingleton sharedCacheMaster] overviewCache_cellCache] copy];
	
	STAssertTrue(![originalDict isEqualToDictionary:dict], @"Should not be equal after the change of filtering");
	
	[context deleteObject:toDelete];
	[[Utilities toolbox] save:context];	
	[self populateCacheOverview];
	NSDictionary * dict2 = [[CacheMasterSingleton sharedCacheMaster] overviewCache_cellCache];
	STAssertTrue(![dict isEqualToDictionary:dict2], @"Should not be equal, since I have deleted one element");
			
}
- (void) testSetPredicatesDetail {

	[self populateCacheDetail];
	
	NSInteger numOfTransactions;
	NSDictionary * dict;
	NSPredicate * newPredicate;
	
	dict = [[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache];
	numOfTransactions = (NSInteger)[[[dict objectForKey:[NSNumber numberWithInt:0]] objectForKey:@"transactions"] count];
	STAssertEquals(numOfTransactions, 9,@"Should have all objects");
	
	//*******
	
	newPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] \" hallo \""];
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:newPredicate];
		
	dict = [[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache];
	numOfTransactions = (NSInteger)[[[dict objectForKey:[NSNumber numberWithInt:0]] objectForKey:@"transactions"] count];
	STAssertEquals(numOfTransactions, 4, @"Should less objects (only with tag hallo)");
	
	//*******
	
	newPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] \" hallo \" AND tags contains[cd] \" test \""];
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:newPredicate];
	
	dict = [[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache];
	numOfTransactions = (NSInteger)[[[dict objectForKey:[NSNumber numberWithInt:0]] objectForKey:@"transactions"] count];
	STAssertEquals(numOfTransactions, 2, @"Should less objects (only with tag hallo and tag test)");
	
	//*******

	newPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] \" hallo \" AND tags contains[cd] \" test \" AND tags contains[cd] \" sugar \""];
	[[CacheMasterSingleton sharedCacheMaster] setFilteringPredicate:newPredicate];
	
	dict = [[CacheMasterSingleton sharedCacheMaster] detailCache_cellCache];
	numOfTransactions = (NSInteger)[[[dict objectForKey:[NSNumber numberWithInt:0]] objectForKey:@"transactions"] count];
	STAssertEquals(numOfTransactions, 0, @"Should less objects (only with tag hallo and tag test and sugar)");
	
	//*******

}

@end
