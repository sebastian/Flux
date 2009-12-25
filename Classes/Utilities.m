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
#import "FluxAppDelegate.h"
#import "AddTransactionController.h"
#import "CacheMasterSingleton.h"
#import "LocationController.h"
#import "CurrencyManager.h"

@implementation Utilities

@synthesize dateFormatter;
@synthesize geoCoder;
@synthesize tempVariable;
@synthesize tempTransaction = _tempTransaction;

static Utilities *sharedUtilitiesToolbox = nil;


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
//	Miscelaneous
- (void) setBarColours:(TTViewController*)sender colour:(UIColor*)colour{
	sender.navigationBarStyle = UIBarStyleDefault;
	sender.navigationBarTintColor = colour;
	sender.navigationController.navigationBar.tintColor = colour;
	sender.statusBarStyle = UIStatusBarStyleBlackOpaque;
}
- (void) setBarColours:(TTViewController*)sender {
	[self setBarColours:sender colour:[UIColor blackColor]];
}

- (NSString *)applicationDocumentsDirectory {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return basePath;
}


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
																												 inManagedObjectContext:self.tagManagedObjectContext];
	newLocation.location = loc;
	
	if (currentTag == nil) {
		
		Tag * newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" 
																								 inManagedObjectContext:self.tagManagedObjectContext];
		
		newTag.autotag = [NSNumber numberWithBool:autotag];
		newTag.name = tag;
		
		// Add the tag to the tag cache
		[tagCache setObject:newTag forKey:tag];
		
		[newTag addLocationObject:newLocation];
		
	} else {
		
		[currentTag addLocationObject:newLocation];
		
	}
	
	// Save the changes we have made
	[self save:self.tagManagedObjectContext];
	
}
-(Tag*)tagObjectforTag:(NSString*)tag {
	
	tag = [[tag lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// Create the tags dictionary if it doesn't exist
	if (tagCache == nil) { tagCache = [[NSMutableDictionary alloc] init]; }
	// Hit cache
	if ([tagCache objectForKey:tag] != nil) {return [tagCache objectForKey:tag];}
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" 
																						inManagedObjectContext:self.tagManagedObjectContext]; 
	
	// Create a predicate
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name = %@", tag];
	
	// Create and setup the request
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:entity];
	[request setPredicate:predicate];
	
	NSError *error; 
	
	NSArray *localTags = [self.tagManagedObjectContext executeFetchRequest:request error:&error]; 
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
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.tagManagedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate * tagPredicate = [NSPredicate predicateWithFormat:@"autotag == NO AND name BEGINSWITH %@", start];
	[fetchRequest setPredicate:tagPredicate];
	[fetchRequest setFetchLimit:2];
	
	NSArray * fetchedTags = [self.tagManagedObjectContext executeFetchRequest:fetchRequest error:&error];
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
																						inManagedObjectContext:self.tagManagedObjectContext]; 
	
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
	
	NSArray *tags = [self.tagManagedObjectContext executeFetchRequest:request error:&error]; 
	[request release];
	
	NSMutableArray * tagNames = [[NSMutableArray alloc] init];
	for (Tag * tag in tags) {
		[tagNames addObject:tag.name];
	}
	
	return [tagNames autorelease];
	
}
-(NSArray*)topTagsIncludingAutotags:(BOOL)autotags {

	if (!_topTags) {
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" 
																							inManagedObjectContext:self.tagManagedObjectContext]; 
		[request setEntity:entity];
		
		
		NSSortDescriptor * sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
		[request setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
		TT_RELEASE_SAFELY(sortByDate);
		
		[request setFetchLimit:150];
		[request setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"tag"]];
		
		NSError *error; 
		
		NSArray * allLocations = [self.tagManagedObjectContext executeFetchRequest:request error:&error]; 
		TT_RELEASE_SAFELY(request);
				
		NSMutableDictionary * tagDict = [[NSMutableDictionary alloc] init];
		
		for (Location * location in allLocations) {
			
			if (autotags || ![location.tag.autotag boolValue]) {
				
				NSString * tagName = location.tag.name;
				NSNumber * valForKey = [tagDict valueForKey:tagName];
				if (valForKey != nil) {
					valForKey = [NSNumber numberWithInt:[valForKey intValue] + 1];
				} else {
					valForKey = [NSNumber numberWithInt:1];
				}
				
				[tagDict setValue:valForKey forKey:tagName];
			}
			
		}
		
		_topTags = [[tagDict keysSortedByValueUsingSelector:@selector(compare:)] retain];
		
		[tagDict release];
	} 
		
	return _topTags;
	
}

-(void)clearCache {
	TT_RELEASE_SAFELY(tagExistance);
	TT_RELEASE_SAFELY(tagCache);
	TT_RELEASE_SAFELY(dateFormatter);
	TT_RELEASE_SAFELY(_topTags);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// GeoCoding
#pragma mark
#pragma mark -
#pragma mark GeoCoding
@synthesize bestLocation = _bestLocation, locationDelegate = _locationDelegate;

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
- (void) stopGeocoding:(NSTimer*)theTimer {
	NSLog(@"Stop geocoding timer called");
	[[LocationController sharedInstance].locationManager stopUpdatingLocation];
}
- (void) startGeocoding {

	_didGeoCoding = NO;
	foundLocationTags = NO;
	
	[LocationController sharedInstance].delegate = self;
	[LocationController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[[LocationController sharedInstance].locationManager startUpdatingLocation];
	
	// Stop geocoding after 15 seconds. Don't want to waste battery
	NSTimer * timer = [NSTimer timerWithTimeInterval:15.f target:self selector:@selector(stopGeocoding:) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	GeoCoding - Location Manager delegate methods
#pragma mark CoreLocation - LocationController delegate methods
-(void)locationUpdate:(CLLocation *)location {
	// We have to reverse geo code in order to get a location we can use for the currency

	if (!_didGeoCoding) {
		_didGeoCoding = YES;
		[self reverseGeoCode:location.coordinate forDelegate:self];
	}
	
	/*
	 Only use locations that are less than five minutes old
	 */
	if (abs([location.timestamp timeIntervalSinceNow]) > 3 * 60) { return; }
	
	if (self.bestLocation == nil) {
		self.bestLocation = location;
		
	} else {
		if (location.timestamp > self.bestLocation.timestamp) {
			self.bestLocation = location;
			
		}
	}
	
	// And we should do a reverse geocoding as well!
	if ((foundLocationTags == NO) && (location.horizontalAccuracy < 1500.f) && (location.horizontalAccuracy > 0.f)) {
		
		// We don't need more location updates
		[[LocationController sharedInstance].locationManager stopUpdatingLocation];
				
		[self findLocationTags];
		
	}
	
}
-(void)locationError:(NSString *)error {
	NSLog(@"Got location error: %@", error);
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"KleioFinanceFirstRunBaseCurrency"] == nil) {
		NSLog(@"We should do something here... Like ask the user to set his or her currency!");
	}
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)daPlacemark {
	/*
	 We have to find the currency corrensponding to the country!
	 */
	
	@try {[_locationDelegate setPlacemark:daPlacemark];}
	@catch (NSException * e) {}
	
	NSString * countryCode = daPlacemark.countryCode;
	NSString * currencyCode = [[[CurrencyManager sharedManager] countryToCurrency] objectForKey:countryCode];
	
	if (!(currencyCode == nil)) {
		
		// We run off the previous local currency, to speed things up.
		// If it has changed, then we update it
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLocalCurrency"] != currencyCode) {

			// If the local currency has changed, and has changed back to the base
			// currency, then the user is back home :)
			if (([[CurrencyManager sharedManager] baseCurrency] == currencyCode) && 
					([[NSUserDefaults standardUserDefaults] objectForKey:@"KleioFinanceFirstRunBaseCurrency"] == nil)) {

				// Welcome home princess / tiger (depending on gender)
				// I could greet the user here, but maybe only americans would actually appreciate that...
				
			}
			
			[[NSUserDefaults standardUserDefaults] setObject:currencyCode
																								forKey:@"CurrentLocalCurrency"];
			
			@try {[_locationDelegate baseCurrencyUpdatedTo:currencyCode];}
			@catch (NSException * e) {}
			
		}
		
	} else {
		NSLog(@"Couldn't find a currency for %@", countryCode);
	}
	
	
	/*
	 If this is the first time this app has been run
	 Then this is the first place where we have gotten the users geolocation.
	 We should set the base currency to match that location
	 */
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"KleioFinanceFirstRunBaseCurrency"] == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
																							forKey:@"KleioFinanceFirstRunBaseCurrency"];
		
		[[CurrencyManager sharedManager] setBaseCurrency:currencyCode];
		
	}
		
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	// Nothing much to do...
	NSLog(@"ERROR... We couldn't fint the location! Unless the base currency has been set we should tell the user!");
}
-(void)findLocationTags {
	
	NSError *error;
	
	// Get all the transactions
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Location" 
																						 inManagedObjectContext:[[Utilities toolbox] addTransactionManagedObjectContext]];
	[fetchRequest setEntity:entity];
	
	// TODO: limit tag lookup
	/*
	 Should look for tags with location that are within a certain latitudal range.
	 1 degree in latitude is approx 111 km
	 Hence I should store lat in the location class and then I can look for
	 within a range... To speed up the lookup.
	 */
	
	double diff = 0.01;
	double plusLatDelta = self.bestLocation.coordinate.latitude + diff;
	double minusLatDelta = self.bestLocation.coordinate.latitude - diff;
	
	/* the longitutes are dependent on location, so I make the delta bigger to make sure I get something! */
	double lngDiff = 0.5;
	double plusLngDelta = self.bestLocation.coordinate.longitude + lngDiff;
	double minusLngDelta = self.bestLocation.coordinate.longitude - lngDiff;
	
	NSPredicate * deltaLatPredicate = [NSPredicate predicateWithFormat:@"latitude BETWEEN {%f, %f}", minusLatDelta, plusLatDelta];
	NSPredicate * deltaLngPredicate = [NSPredicate predicateWithFormat:@"longitude BETWEEN {%f, %f}", minusLngDelta, plusLngDelta];
	NSPredicate * notAutotags = [NSPredicate predicateWithFormat:@"tag.autotag = NO"];
	NSPredicate * locationPredicate = 
	[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:deltaLatPredicate, deltaLngPredicate, notAutotags, nil]];
	
	[fetchRequest setPredicate:locationPredicate];
	
	
	NSArray * fetchedLocations = [[[Utilities toolbox] addTransactionManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	NSMutableArray * tagsToSuggest = [[NSMutableArray alloc] init];
	
	for (Location * location in fetchedLocations) {
		CLLocationDistance distance;
		@try {
			distance = [self.bestLocation getDistanceFrom:location.location];
		}
		@catch (NSException * e) {
			NSLog(@"Got strange error when trying to check distance of tag! %@", e);
			distance = 3000; // Some strange error... just set it to something we won't use...
		}
		/* If the tag is closer than 50 meters then use it */
		if (distance < 1000.f) {
			/*
			 This is a tag we can use! Add it unless, it has already been added
			 */
			if (![tagsToSuggest containsObject:location.tag]) {
				[tagsToSuggest addObject:location.tag];
			}
		}
		
	}
	
	if ([tagsToSuggest count] > 0) {
		
		
		/* We want to sort the list by popularity */
		[tagsToSuggest sortUsingSelector:@selector(compareAmountOfLocations:)];
		
		// We only want the N most recent geo tags
		NSMutableArray * tagNames = [[NSMutableArray alloc] init];
		for (Tag * tag in tagsToSuggest) {
			if ([tagNames count] == 5) {break;}
			[tagNames addObject:tag.name];
		}
		
		[Utilities toolbox].suggestedTagsForCurrentLocation = tagNames;
		
		TT_RELEASE_SAFELY(tagNames);
	}
	
	[tagsToSuggest release];
	
	foundLocationTags = YES;
		
}

#pragma mark
#pragma mark -
#pragma mark CoreData methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CoreData
@synthesize managedObjectContext, addTransactionManagedObjectContext = _addTransactionManagedObjectContext, tagManagedObjectContext = _tagManagedObjectContext;
- (NSManagedObjectContext*)managedObjectContext {
	if (managedObjectContext == nil) {
		managedObjectContext = [[self createObjectContext] retain];
		[[CacheMasterSingleton sharedCacheMaster] registerForManagedObjectContextNotifications];
	}
	return managedObjectContext;
}
- (NSManagedObjectContext*)addTransactionManagedObjectContext {
	if (_addTransactionManagedObjectContext == nil) {
		_addTransactionManagedObjectContext = [[self createObjectContext] retain];
	}
	return _addTransactionManagedObjectContext;
}
- (NSManagedObjectContext*)tagManagedObjectContext {
	if (_tagManagedObjectContext == nil) {
		_tagManagedObjectContext = [[self createObjectContext] retain];
	}
	return _tagManagedObjectContext;
}
- (void)save:(NSManagedObjectContext*)context {
		
	if (context != nil) {

		if ([context hasChanges]) {
	
			NSError *error;
			if (![context save:&error]) {
				// Handle error
				NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
				exit(-1);  // Fail
			} 
			
		} 
	}	
}
- (NSManagedObjectContext*) createObjectContext {

	FluxAppDelegate * appDelegate = (FluxAppDelegate*)[[UIApplication sharedApplication] delegate];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	TT_RELEASE_SAFELY(geoCoder);
	TT_RELEASE_SAFELY(dateFormatter);
	TT_RELEASE_SAFELY(managedObjectContext);
	TT_RELEASE_SAFELY(_addTransactionManagedObjectContext);
	TT_RELEASE_SAFELY(tagExistance);
	TT_RELEASE_SAFELY(tagCache);
	
	[super dealloc];
}


@end
