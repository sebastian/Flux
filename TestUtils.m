//
//  TestUtils.m
//  Finance
//
//  Created by Sebastian Probst Eide on 23.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TestUtils.h"
#import "CacheMasterSingleton.h"

@implementation TestUtils

static int numOfRunning = 0;

+ (NSManagedObjectContext *) managedObjectContext {
	
	numOfRunning += 1;
	[CacheMasterSingleton sharedCacheMaster].runNum = numOfRunning;
	
	NSManagedObjectModel *model;
	NSPersistentStoreCoordinator *coordinator;
	NSManagedObjectContext *context;
	
	NSArray *bundles = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
	model = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];

	NSURL * storeUrl = [NSURL URLWithString:[self filePath]];
	
	NSError *error;
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
		TTLOG(@"COULDN'T CREATE A PERSISTANT STORE COORDINATOR! CHAOS");
		TTLOG(@"ERROR: %@", error);
	}    
	
	
	context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:coordinator];
	
	return context;

}
+ (NSString*)filePath {
	return @"file://localhost/Users/seb/TestData.sqlite";
}
+ (void) clearData {	
	NSError * error = nil;
	NSString * path = @"/Users/seb/TestData.sqlite";
	if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
		TTLOG(@"ERROR: %@", error);
	}
}


@end
