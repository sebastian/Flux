//
//  AmountController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "AddTransactionController.h"
#import "TagSelector.h"
#import "Utilities.h"
#import "KleioCustomStyles.h"
#import "Location.h"
#import "Tag.h"
#import "CacheMasterSingleton.h"

#define MIN_DISTANCE 200

@implementation AddTransactionController

@synthesize managedObjectContext = _managedObjectContext, 
	bestLocation = _bestLocation, localCurrency = _localCurrency;

- (NSManagedObjectContext*)managedObjectContext {
	if (_managedObjectContext == nil) {
		_managedObjectContext = [[[Utilities toolbox] createObjectContext] retain];
	}
	return _managedObjectContext;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private methods

- (void) layout {
	
	TTFlowLayout * flow = [[TTFlowLayout alloc] init];
	[flow layoutSubviews:self.view.subviews forView:self.view];
	[flow release];
	
}

- (void) createAndSetupTransaction {
	
	// Get a clean slate by releasing previous transactions
	if (currentTransaction != nil) {
		TT_RELEASE_SAFELY(currentTransaction);
	}
	
	NSManagedObjectContext * context = [[[Utilities toolbox] createObjectContext] retain];
	currentTransaction = [[NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:context] retain];
	
	// If we have a local currency, then use it
	if (self.localCurrency != nil) {
		currentTransaction.currency = self.localCurrency;
	}
	
	// Set the new transaction for the delegate
	_amountEditor.currentTransaction = currentTransaction;
		
}

-(void)add:(NSString*)what toArray:(NSMutableArray*)array {
	if (_placemark != nil) {
		if ([_placemark valueForKey:what] != nil) {
			[array addObject:[_placemark valueForKey:what]];
		}
	}
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject
- (id)init {
    if (self = [super init]) {
		
			[[Utilities toolbox] setBarColours:self];
			
			self.title = @"Add transaction";
			[self.tabBarItem setImage:[UIImage imageNamed:@"Add.png"]];
			
			[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
			
			foundLocationTags = NO;
    }
    return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_managedObjectContext);
	TT_RELEASE_SAFELY(currentTransaction);
	TT_RELEASE_SAFELY(_bestLocation);
	TT_RELEASE_SAFELY(_localCurrency);
	TT_RELEASE_SAFELY(_amountEditor);
	TT_RELEASE_SAFELY(_placemark);
	[super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void) loadView {
	[super loadView];
	
	// Get the location
	[LocationController sharedInstance].delegate = self;
	[LocationController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[[LocationController sharedInstance].locationManager startUpdatingLocation];
		
	// Setup next button
	TTButton * nextButton = [TTButton buttonWithStyle:@"greenForwardButton:" title:@"Next"];
	nextButton.font = [UIFont boldSystemFontOfSize:16.f];
	[nextButton sizeToFit];
	[nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:nextButton] autorelease];
		
	_amountEditor = [[AmountEditor alloc] init];
	_amountEditor.delegate = self;
	[self createAndSetupTransaction];

	[self.view addSubview:_amountEditor.view];
	
	self.tabBarItem.title = NSLocalizedString(@"New", nil);
	
}
	
- (void) viewDidUnload {
	[super viewDidUnload];
	TTLOG(@"Location manager stopped");
	[[LocationController sharedInstance].locationManager stopUpdatingLocation];
}

- (IBAction) nextButtonAction {

	TagSelector * tagSelector = [[TagSelector alloc] init];
	tagSelector.delegate = self;
	[tagSelector setMode:TagSelectorModeTransaction];

	// Send the tags to the tagSelector if the transaction already has tags
	tagSelector.tags = currentTransaction.tagsArray;
	
	[self.navigationController pushViewController:tagSelector animated:YES];
		
	[tagSelector release];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TagSelectorDelegate

- (void) tagSelectorFinishedWithTagWords:(NSArray*)tagsWords {
	currentTransaction.tagsArray = tagsWords;
}

- (void) save {
	TTLOG(@"Save...");
	
	currentTransaction.location = self.bestLocation;
	
	/*
	 Adding autotags
	 */
	NSMutableArray * autotags = [[NSMutableArray alloc] init];
	[self add:@"country" toArray:autotags];
	[self add:@"administrativeArea" toArray:autotags];
	[self add:@"locality" toArray:autotags];
	[self add:@"subAdministrativeArea" toArray:autotags];
	[self add:@"subLocality" toArray:autotags];
	[self add:@"thoroughfare" toArray:autotags];
	
	NSDateFormatter * dateFormatter = [[Utilities toolbox] dateFormatter];
	NSArray * weekdays = [dateFormatter weekdaySymbols];
	NSArray * months = [dateFormatter monthSymbols];
	
	// Set the month and year for easier searching and displaying and most importantly grouping!
	NSCalendar * currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents * components = [currentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit) fromDate:currentTransaction.date];
	
	NSString * month = [months objectAtIndex:components.month-1];
	NSString * weekday = [weekdays objectAtIndex:components.weekday-1];
	NSString * year = [NSString stringWithFormat:@"%i", components.year];
	
	[autotags addObject:month];
	[autotags addObject:weekday];
	[autotags addObject:year];
	
	NSString * newAutoTags = [autotags componentsJoinedByString:@" "];
	currentTransaction.autotags = [NSString stringWithFormat:@" %@ ", newAutoTags];
	
	/*
	 This method also calls createAndSetupTransaction 
	 so that it is done after the save has been performed
	 */
	[[Utilities toolbox] delayedSave:currentTransaction];
	[self createAndSetupTransaction];

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Location Manager delegate methods
#pragma mark CoreLocation - LocationController delegate methods
-(void)locationUpdate:(CLLocation *)location {
	/*
	 Only use locations that are less than five minutes old
	 */
	NSLog(@"Received new location update: %@", location);
	if (abs([location.timestamp timeIntervalSinceNow]) > 3 * 60) { return; }
	
	if (self.bestLocation == nil) {
		self.bestLocation = location;
				
	} else {
		if (location.timestamp > self.bestLocation.timestamp) {
			self.bestLocation = location;
						
		}
	}
	
	// And we should do a reverse geocoding as well!
	if ((foundLocationTags == NO) && (location.horizontalAccuracy < 100.f) && (location.horizontalAccuracy > 0.f)) {
		
		NSLog(@"It is good enough for geocoding");
				
		foundLocationTags = YES;
		
		// We don't need more location updates
		[[LocationController sharedInstance].locationManager stopUpdatingLocation];
				
		// We have to geocode as well!
		[[Utilities toolbox] reverseGeoCode:location.coordinate forDelegate:self];
				
		[self performSelectorInBackground:@selector(findLocationTags) withObject:nil];
				
	}
	
}
-(void)locationError:(NSString *)error {
	TTLOG(@"Got location error: %@", error);
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)daPlacemark {
	/*
	 We have to find the currency corrensponding to the country!
	 */
	
	_placemark = [daPlacemark retain];
	
	NSString * countryCode = _placemark.countryCode;
	NSString * currencyCode = [[[CurrencyManager sharedManager] countryToCurrency] objectForKey:countryCode];
	
	/*
	 If this is the first time this app has been run
	 Then this is the first place where we have gotten the users geolocation.
	 We should set the base currency to match that location
	 */
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"KleioFinanceFirstRunBaseCurrency"] == nil) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
																							forKey:@"KleioFinanceFirstRunBaseCurrency"];
		
		[[CurrencyManager sharedManager] setBaseCurrency:currencyCode];
		
		/*
		 This is probably (hopefully) the first time the app runs.
		 We now have to set the transactions currency to the same currency as well,
		 and update the display!
		 */
		currentTransaction.currency = currencyCode;
		[_amountEditor updateExpenseDisplay];
		[[CacheMasterSingleton sharedCacheMaster] clearCache];
	}
	
	if (!(currencyCode == nil)) {
		
		// Only if the user wants it!
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsUseLocalCurrency"] boolValue] == YES) {
			currentTransaction.currency = currencyCode;
			self.localCurrency = currencyCode;
			[_amountEditor updateExpenseDisplay];
		}
		
	} else {
		TTLOG(@"Couldn't find a currency for %@", countryCode);
	}
	
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	// Nothing much to do...
}
-(void)findLocationTags {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSError *error;
	
	// Get all the transactions
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// TODO: limit tag lookup
	/*
	 Should look for tags with location that are within a certain latitudal range.
	 1 degree in latitude is approx 111 km
	 Hence I should store lat in the location class and then I can look for
	 within a range... To speed up the lookup.
	 */
	
	double diff = 0.0005;
	double plusLatDelta = self.bestLocation.coordinate.latitude + diff;
	double minusLatDelta = self.bestLocation.coordinate.latitude - diff;
	
	/* the longitutes are dependent on location, so I make the delta bigger to make sure I get something! */
	double lngDiff = 0.005;
	double plusLngDelta = self.bestLocation.coordinate.longitude + lngDiff;
	double minusLngDelta = self.bestLocation.coordinate.longitude - lngDiff;
	
	NSPredicate * deltaLatPredicate = [NSPredicate predicateWithFormat:@"latitude BETWEEN {%f, %f}", minusLatDelta, plusLatDelta];
	NSPredicate * deltaLngPredicate = [NSPredicate predicateWithFormat:@"longitude BETWEEN {%f, %f}", minusLngDelta, plusLngDelta];
	NSPredicate * notAutotags = [NSPredicate predicateWithFormat:@"tag.autotag = NO"];
	NSPredicate * locationPredicate = 
	[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:deltaLatPredicate, deltaLngPredicate, notAutotags, nil]];
	
	[fetchRequest setPredicate:locationPredicate];
	
	
	NSArray * fetchedLocations = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	NSMutableArray * tagsToSuggest = [[NSMutableArray alloc] init];
	
	for (Location * location in fetchedLocations) {
		CLLocationDistance distance;
		@try {
			distance = [self.bestLocation getDistanceFrom:location.location];
		}
		@catch (NSException * e) {
			TTLOG(@"Got strange error when trying to check distance of tag! %@", e);
			distance = 3000; // Some strange error... just set it to something we won't use...
		}
		/* If the tag is closer than 50 meters then use it */
		if (distance < 150.f) {
			/*
			 This is a tag we can use! Add it unless, it has already been added
			 */
			if (![tagsToSuggest containsObject:location.tag]) {
				[tagsToSuggest addObject:location.tag];
			}
		}
		
	}
		
	if ([tagsToSuggest count] > 0) {
		
		NSMutableArray * tagNames = [[NSMutableArray alloc] init];
		for (Tag * tag in tagsToSuggest) {
			[tagNames addObject:tag.name];
		}
		
		[Utilities toolbox].suggestedTagsForCurrentLocation = tagNames;
		
		TTLOG(@"Added suggested tags...");
		
		TT_RELEASE_SAFELY(tagNames);
	}
	
	[tagsToSuggest release];
	
	[pool release];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	MISC
// FIXME: Before release this should be improved
- (void)didReceiveMemoryWarning {
	TTLOG(@"didReceiveMemoryWarning: %@", self);
	
	[[CacheMasterSingleton sharedCacheMaster] clearCache];	
		
	[super didReceiveMemoryWarning];
}

@end
