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
#import "FinanceAppDelegate.h"

@interface Utilities (PrivateMethods)
- (void)doSave:(NSManagedObjectContext*)context;
- (void)doSaveStart:(NSManagedObjectContext*)context;
@end



@implementation Utilities

@synthesize dateFormatter;
@synthesize geoCoder;
@synthesize tempVariable;

static Utilities *sharedUtilitiesToolbox = nil;

- (id) init {
	self = [super init];
	if (self != nil) {
		[self setSavignIsFalse];
	}
	return self;
}
- (void)setSavignIsFalse {
	saving = NO;
}

-(double)sumAmountForTransactionArray:(NSArray*)transactions {

	double dKroner;
	@try {
		dKroner = [(NSNumber*)[transactions valueForKeyPath:@"@sum.kronerInBaseCurrency"] doubleValue];
	}
	@catch (NSException * e) {
		NSLog(@"Error summing kroner for transactions");
		NSLog(@"Error: %@", e);
		dKroner = 0.0;
	}
	
	return dKroner;
	
}
-(float)keyboardAnimationDuration {return 0.3;}

-(NSDateFormatter*)dateFormatter {
	if (dateFormatter == nil) { 
		NSDateFormatter * df = [[NSDateFormatter alloc] init];
		self.dateFormatter = df;
		[df setTimeStyle:NSDateFormatterShortStyle];
	}
	return dateFormatter;
}
-(CGSize)sizeOfTextOfField:(UITextField*)field {
	NSString * text = field.text;
	CGSize size = [text sizeWithFont:field.font];
	return size;
}
-(CGSize)sizeOfTextOfLabel:(UILabel*)label {
	NSString * text = label.text;
	CGSize size = [text sizeWithFont:label.font];
	return size;
}
-(void) setReloadingTableAllowed {
	reloadingTableAllowed = YES;
}
-(void) setReloadingTableNotAllowed {
	reloadingTableAllowed = NO;
}
-(BOOL) isReloadingTableAllowed {return reloadingTableAllowed;}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Tag
@synthesize suggestedTagsForCurrentLocation;
-(BOOL)doesTagExist:(NSString*)tag {
	
	// Lowercase it so that we can normalize it here
	tag = [tag lowercaseString];
	
	// Create the tag existance dictionary if it doesn't exist
	if (tagExistance == nil) { tagExistance = [[NSMutableDictionary alloc] init]; }
	// Look up in cache
	if ([tagExistance objectForKey:tag] != nil) {return [((NSNumber*)[tagExistance objectForKey:tag]) boolValue];}
	
	if ([[Utilities toolbox] tagObjectforTag:tag] == nil) {
		[tagExistance setValue:[NSNumber numberWithBool:NO] forKey:tag];
		return NO;
	} else {
		[tagExistance setValue:[NSNumber numberWithBool:YES] forKey:tag];
		
		return YES;
		
	}
}
-(void)addTag:(NSString*)tag autotag:(BOOL)autotag location:(CLLocation*)loc {
	
	tag = [tag lowercaseString];
	
	Tag * currentTag = [[Utilities toolbox] tagObjectforTag:tag];
	
	// Create an object to hold the location
	Location * newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" 
																												 inManagedObjectContext:self.managedObjectContext];
	newLocation.location = loc;
	
	if (currentTag == nil) {
		
		Tag * newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" 
																								 inManagedObjectContext:self.managedObjectContext];
		
		newTag.autotag = [NSNumber numberWithBool:autotag];
		newTag.name = tag;
		
		// Add the tag to the tag cache
		[tagCache setObject:newTag forKey:tag];
		
		[newTag addLocationObject:newLocation];
		
	} else {
		
		[currentTag addLocationObject:newLocation];
		
	}
	
	// Save the changes we have made
	[self save:self.managedObjectContext];
	
}
-(Tag*)tagObjectforTag:(NSString*)tag {
	
	tag = [[tag lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Create the tags dictionary if it doesn't exist
	if (tagCache == nil) { tagCache = [[NSMutableDictionary alloc] init]; }
	// Hit cache
	if ([tagCache objectForKey:tag] != nil) {return [tagCache objectForKey:tag];}
	
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
-(NSArray*)twoTagsStartingWith:(NSString*)start {
	
	NSError *error;
	
	// Get all the transactions
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:[[Utilities toolbox] managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	NSPredicate * tagPredicate = [NSPredicate predicateWithFormat:@"autotag == NO AND name BEGINSWITH %@", start];
	[fetchRequest setPredicate:tagPredicate];
	[fetchRequest setFetchLimit:2];
	
	NSArray * fetchedTags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	/*
	 Now we add the tags to the tags cache so that we don't have to look
	 them up again later, consider the user will probably use them!
	 */
	if (tagCache == nil) { tagCache = [[NSMutableDictionary alloc] init]; }
	for (Tag * tag in fetchedTags) {
		[tagCache setObject:tag forKey:tag.name];
	}
	
	return fetchedTags;
}
-(NSArray*)tagStringToArray:(NSString*)tagString {
	
	// lowercase, or downcase all the tags
	//NSString * lowerCaseTags = [tagString lowercaseString];
	NSString * lowerCaseTags = tagString;
	
	// Split by whitespace
	NSArray * localTags = [lowerCaseTags componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Remove white space and only return tags that are not empty
	NSMutableArray * strippedTags = [[[NSMutableArray alloc] init] autorelease];
	
	for (NSString * tag in localTags) {
		
		// Remove all illegal punctuations and suchs
		NSString * tagsWithoutPunctuation = [tag stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
		
		// Remove white space from ends
		NSString * strippedTag  = [tagsWithoutPunctuation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if (![strippedTag isEqualToString:@""]) {
			[strippedTags addObject:strippedTag];
		}
	}
	
	return strippedTags;
	
}
-(NSArray*)allTagNames {
	return [self allTagNamesIncludingAutotags:NO];
}
-(NSArray*)allTagNamesIncludingAutotags:(BOOL)autotags {
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" 
																						inManagedObjectContext:self.managedObjectContext]; 
	
	NSPredicate * autotagPredicate;
	if (autotags) {
		autotagPredicate = [NSPredicate predicateWithValue:YES];
	} else {
		autotagPredicate = [NSPredicate predicateWithFormat:@"autotag = NO"];
	}
	
	// Create and setup the request
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:entity];
	[request setPredicate:autotagPredicate];
	
	NSError *error; 
	
	NSArray *tags = [self.managedObjectContext executeFetchRequest:request error:&error]; 
	[request release];
	
	NSMutableArray * tagNames = [[NSMutableArray alloc] init];
	for (Tag * tag in tags) {
		[tagNames addObject:tag.name];
	}
	
	return [tagNames autorelease];
	
}
-(NSArray*)topTagsIncludingAutotags:(BOOL)autotags {

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" 
																						inManagedObjectContext:self.managedObjectContext]; 
	
	NSPredicate * autotagPredicate;
	if (autotags) {
		autotagPredicate = [NSPredicate predicateWithValue:YES];
	} else {
		autotagPredicate = [NSPredicate predicateWithFormat:@"autotag = NO"];
	}

//	NSPredicate * onlyPopularTags = [NSPredicate predicateWithFormat:@"location.@count > @avg.(location.@count)"];
	NSPredicate * andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:autotagPredicate, nil]];
	
	//- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending;
//	NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:@"location.@count" ascending:NO];
	
//	NSArray * sortDescriptors = [NSArray arrayWithObject:sort];
//	[sort release];
	
	// Create and setup the request
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:entity];
//	[request setSortDescriptors:sortDescriptors];
	[request setPredicate:andPredicate];
	[request setFetchLimit:10];
	
	NSError *error; 
	
	NSArray *tags = [self.managedObjectContext executeFetchRequest:request error:&error]; 
	[request release];
	
	NSMutableArray * tagNames = [[NSMutableArray alloc] init];
	for (Tag * tag in tags) {
		[tagNames addObject:tag.name];
	}
	
	return [tagNames autorelease];
	
	
}

-(void)clearCache {
	[tagExistance removeAllObjects];
	[tagCache removeAllObjects];
	[dateFormatter release];
}

#pragma mark
#pragma mark -
#pragma mark GeoCoding
- (void)reverseGeoCode:(CLLocationCoordinate2D)coordinate forDelegate:(id<MKReverseGeocoderDelegate>)delegate {

	if (self.geoCoder != nil) {
		/*
		 There is currently a geocoder
		 Finish its work
		 */
		
		// Cancel querying if it is doing work
		if ([self.geoCoder isQuerying]) {
			// Terminate the current geocoding
			if (self.geoCoder.delegate != nil) {
				[self.geoCoder.delegate reverseGeocoder:self.geoCoder didFailWithError:[NSError errorWithDomain:@"GeoCoderKleioOtherUserWantedToGeoCode" code:1 userInfo:nil]];
				
			}
			[self.geoCoder cancel];
		}
		
		self.geoCoder = nil;
		
	} 
	
	NSLog(@"Creating a new geocoder");
	
	// Create a new geocoder for the given coordinate
	self.geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];	
	
	// Assign new delegate
	self.geoCoder.delegate = delegate;
	
	// And off we go :)
	[self.geoCoder start];
}


#pragma mark
#pragma mark -
#pragma mark CoreData methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CoreData
@synthesize managedObjectContext;
- (NSManagedObjectContext*)managedObjectContext {
	if (managedObjectContext == nil) {
		managedObjectContext = [[self createObjectContext] retain];
	}
	return managedObjectContext;
}
- (void)privateSave {
	if (saving == NO) {
		saving = YES;
		[self performSelectorInBackground:@selector(doSaveStart:) withObject:self.managedObjectContext];
	}
	//[self save:self.managedObjectContext];
}
- (void)save:(NSManagedObjectContext*)context {
	NSError *error;
    if (context != nil) {
		if ([context hasChanges]) {
			if (![context save:&error]) {
				// Handle error
				NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
				exit(-1);  // Fail
			} 
		} 
    }	
	
}
- (void)doSaveStart:(NSManagedObjectContext*)context {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self doSave:context];
	[pool release];
}
- (void)doSave:(NSManagedObjectContext*)context {
	NSError *error;
    if (context != nil) {
		if ([context hasChanges]) {

			if (![context save:&error]) {
				// Handle error
				NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
				exit(-1);  // Fail
			
			} else {
				// Trying to perform another save in 2 seconds time
				sleep(2);
				[self doSave:context];
			}
		} else {
			saving = NO;
		}
    }	
}
- (NSManagedObjectContext*) createObjectContext {

	FinanceAppDelegate * appDelegate = (FinanceAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
	[newContext setPersistentStoreCoordinator: [appDelegate persistentStoreCoordinator]];
	if (!newContext) { 
		NSLog(@"Couldn't create a managedObjectContext in the Utilities helper function");
	}

	return [newContext autorelease];
	
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
	[geoCoder release];
	[dateFormatter release];
	[managedObjectContext release];
	[tagExistance release];
	[tagCache release];
	
	[super dealloc];
}


@end
