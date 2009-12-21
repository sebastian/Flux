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
static NSManagedObjectModel *model;
static NSPersistentStoreCoordinator *coordinator;

+ (NSManagedObjectContext *) managedObjectContext {
	
	numOfRunning += 1;
	[CacheMasterSingleton sharedCacheMaster].runNum = numOfRunning;
	
	NSManagedObjectContext *context;
	
	NSArray *bundles = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
	
	if (model == nil) {
		model = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];
		
		NSURL * storeUrl = [NSURL URLWithString:[self filePath]];
		
		NSError *error;
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
			// Handle error
			NSLog(@"COULDN'T CREATE A PERSISTANT STORE COORDINATOR! CHAOS");
			NSLog(@"ERROR: %@", error);
		}    
	}
	
	context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:coordinator];
		
	return context;

}
+ (NSString*)filePath {
	return @"file://localhost/Users/seb/TestData.sqlite";
}
+ (void) clearData {	

	TT_RELEASE_SAFELY(model);
	TT_RELEASE_SAFELY(coordinator);
	
	NSError * error = nil;
	NSString * path = @"/Users/seb/TestData.sqlite";
	if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
		NSLog(@"ERROR: %@", error);
	}
}

+ (void) waitForLoad:(TTModel*)controller {
	while ([controller isLoading]) {sleep(0.1);}
}

@end
