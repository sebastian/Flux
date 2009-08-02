//
//  Utilities.m
//  Finance
//
//  Created by Sebastian Probst Eide on 30.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Utilities.h"
#import "Tag.h"
#import "Location.h"

@implementation Utilities

@synthesize managedObjectContext;

static Utilities *sharedUtilitiesToolbox = nil;

-(double)sumAmountForTransactionArray:(NSArray*)transactions {
	
	// Predicates
	NSPredicate * expensePredicate = [NSPredicate predicateWithFormat:@"expense = YES"];
	NSPredicate * incomePredicate = [NSPredicate predicateWithFormat:@"expense = NO"];
	
	NSArray * expenseTransactions = [transactions filteredArrayUsingPredicate:expensePredicate];
	NSArray * incomeTransactions = [transactions filteredArrayUsingPredicate:incomePredicate];
	
	int iKronerExpense;
	int iKronerIncome;
	@try {
		iKronerExpense = [(NSNumber*)[expenseTransactions valueForKeyPath:@"@sum.kroner"] intValue];
		iKronerIncome = [(NSNumber*)[incomeTransactions valueForKeyPath:@"@sum.kroner"] intValue];
	}
	@catch (NSException * e) {
		NSLog(@"Error summing kroner for transactions");
		iKronerExpense = 0;
		iKronerIncome = 0;
	}
	
	int iOreExpense;
	int iOreIncome;
	@try {
		iOreExpense = [(NSNumber*)[expenseTransactions valueForKeyPath:@"@sum.ore"] intValue];
		iOreIncome = [(NSNumber*)[incomeTransactions valueForKeyPath:@"@sum.ore"] intValue];
	}
	@catch (NSException * e) {
		NSLog(@"Error summing ore for transactions");
		iOreExpense = 0;
		iOreIncome = 0;
	}
	
	int iKroner = iKronerExpense - iKronerIncome;
	int iOre = iOreExpense - iOreIncome;
	
	double amount = iKroner + ((double)iOre/100);

	return amount;
}
-(float)keyboardAnimationDuration {return 0.3;}
-(BOOL)doesTagExist:(NSString*)tag {

	// Create the tag existance dictionary if it doesn't exist
	if (tagExistance == nil) { tagExistance = [[NSMutableDictionary alloc] init]; }
	// Look up in cache
	if ([tagExistance objectForKey:tag] != nil) {return [(NSNumber*)[tagExistance objectForKey:tag] boolValue];}
	
	NSLog(@"No recollection of tag %@. Checking...", tag);
	
	if ([[Utilities toolbox] tagObjectforTag:tag] == nil) {
		[tagExistance setValue:[NSNumber numberWithBool:NO] forKey:tag];
		return NO;
	} else {
		[tagExistance setValue:[NSNumber numberWithBool:YES] forKey:tag];
		return YES;
	}
}
-(void)clearCache {
	[tagExistance release];
	[tagCache release];
}
-(void)addTag:(NSString*)tag location:(CLLocation*)loc {
	Tag * currentTag = [[Utilities toolbox] tagObjectforTag:tag];

	// Create an object to hold the location
	Location * newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" 
														   inManagedObjectContext:self.managedObjectContext];
	newLocation.location = loc;

	if (currentTag == nil) {

		NSLog(@"Creating a new tag");
		Tag * newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" 
													 inManagedObjectContext:self.managedObjectContext];
		
		newTag.name = tag;
						
		[newTag addLocationObject:newLocation];
		
	} else {
		
		NSLog(@"Using precreated tag");
		[currentTag addLocationObject:newLocation];
		
	}
	
	// Save the changes we have made
	[self privateSave];
	
}
-(Tag*)tagObjectforTag:(NSString*)tag {
	
	// Create the tags dictionary if it doesn't exist
	if (tagCache == nil) { tagCache = [[NSMutableDictionary alloc] init]; }
	// Hit cache
	if ([tagCache objectForKey:tag] != nil) {return [tagCache objectForKey:tag];}
	
	NSLog(@"No cache hit for tag object for %@", tag);
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" 
											  inManagedObjectContext:self.managedObjectContext]; 
	
	// Create a predicate
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name = %@", tag];
	
	// Create and setup the request
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:entity];
	[request setPredicate:predicate];
	
	NSError *error; 
		
	NSArray *localTags = [self.managedObjectContext executeFetchRequest:request error:&error]; 
	[request release];
	
	if (localTags == nil) 
	{ 
		NSLog(@"There was an error (that's what she said...): %@", error);
		return nil;
	}
	// Get a tag object and add it to the cache
	Tag * aTag = [localTags lastObject];
	if (aTag != nil) {[tagCache setObject:aTag forKey:tag];}
	
	// Return the tag
	return aTag;
}
-(NSArray*)tagStringToArray:(NSString*)tagString {
	
	// lowercase, or downcase all the tags
	NSString * lowerCaseTags = [tagString lowercaseString];
	
	// Remove all illegal punctuations and suchs
	NSString * tagsWithoutPunctuation = [lowerCaseTags stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];

	// Split by whitespace
	NSArray * localTags = [tagsWithoutPunctuation componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	return localTags;
	
}


#pragma mark
#pragma mark -
#pragma mark CoreData methods
- (void)privateSave {
	[self save:self.managedObjectContext];
}
- (void)save:(NSManagedObjectContext*)context {
	
	NSError *error;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
			// Handle error
			NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
	
}


#pragma mark
#pragma mark -
#pragma mark Singleton methods

+ (Utilities*)toolbox {
    @synchronized(self) {
        if (sharedUtilitiesToolbox == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedUtilitiesToolbox;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedUtilitiesToolbox == nil) {
            sharedUtilitiesToolbox = [super allocWithZone:zone];
            return sharedUtilitiesToolbox;  // assignment and return on first allocation
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
	[managedObjectContext release];
	[tagExistance release];
	[tagCache release];
	
	[super dealloc];
}


@end
