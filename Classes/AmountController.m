//
//  AmountController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "AmountController.h"
#import "TagSelector.h"
#import "Utilities.h"
#import "KleioCustomStyles.h"
#import "Location.h"
#import "Tag.h"
#import "CacheMasterSingleton.h"

@implementation ExpenseToggle

@synthesize delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Public

- (void) reset {
	[eiCtrl setSelectedSegmentIndex:0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private
- (void) setup {
	
	eiCtrl = [[[UISegmentedControl alloc] init] autorelease];
	[eiCtrl insertSegmentWithTitle:NSLocalizedString(@"Expense", nil) atIndex:0 animated:NO];
	[eiCtrl insertSegmentWithTitle:NSLocalizedString(@"Income", nil) atIndex:1 animated:NO];
	[eiCtrl setSegmentedControlStyle:UISegmentedControlStylePlain];
	[eiCtrl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	int padding = 10;
	eiCtrl.frame = CGRectMake(padding, padding, self.width - 2*padding, self.height - 2*padding);
	
	[self reset];
	
	[self addSubview:eiCtrl];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Callbacks

- (void) valueChanged:(UISegmentedControl*)sender {

	if ([self.delegate respondsToSelector:@selector(expenseToggleChangedToValue:)]) {
		TTLOG(@"Informing delegate about change of value for expense/income");
		if ([sender selectedSegmentIndex] == 0) {
			[self.delegate expenseToggleChangedToValue:KleioExpenseIncomeToggleSelectedExpense];
		} else {
			[self.delegate expenseToggleChangedToValue:KleioExpenseIncomeToggleSelectedIncome];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
		
		self.frame = CGRectMake(0, 0, 320, 57);
		self.style = TTSTYLEVAR(expenseInputField);
		
		[self setup];
	}
	return self;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AmountLabel

@synthesize amount = _amount, delegate = _delegate;
- (void) setAmount:(NSString *)theAmount {
	NSLog(@"setAmount: called for amountLabel");
	[theAmount retain];
	[_amount release];
	_amount = theAmount;
	[self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

-(IBAction)changeCurrency {
	/* 
	 Called when the user clicks on the amount
	 Let the user select another input currency
	 */ 
	
	CurrencySelectionDialog *currencySelectionDialog = [[CurrencySelectionDialog new] autorelease];
	// So we can report back the currency change
	currencySelectionDialog.delegate = _delegate;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:currencySelectionDialog] autorelease];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[_delegate presentModalViewController:navController animated:YES];
}

/*
 If it receives a touch, then we should display the 
 dialog where currencies can be changed. The amount label delegate
 handles the actual work when the value is returned...
 */
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[super touchesBegan:touches withEvent:event];
	
	[self changeCurrency];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.style = TTSTYLEVAR(amountFieldStyle);
		self.multipleTouchEnabled = YES;
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Puclib
- (void)drawContent:(CGRect)rect {

	int padding = 20;
	CGRect frame = self.frame;
	frame.size.width = frame.size.width - 2 * padding;
	frame.size.height = frame.size.height - 2 * padding;
	frame.origin.x = padding;
	frame.origin.y = padding;
	
	UIFont * font = [UIFont systemFontOfSize:50];

	CGPoint textPoint = CGPointMake(padding, padding);
	CGSize textSize = [_amount sizeWithFont:font];
	
	if (textSize.width < frame.size.width) {
		textPoint.x = padding + frame.size.width - textSize.width;
	} else {
		textSize.width = frame.size.width;
	}

	[[UIColor whiteColor] set];

	[_amount drawAtPoint:textPoint 
							forWidth:textSize.width
							withFont:font
					 minFontSize:12.f 
				actualFontSize:nil
				 lineBreakMode:UILineBreakModeHeadTruncation 
		baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation AmountController

@synthesize managedObjectContext = _managedObjectContext, amount = _amount, 
	bestLocation = _bestLocation, localCurrency = _localCurrency;

- (NSManagedObjectContext*)managedObjectContext {
	if (_managedObjectContext == nil) {
		_managedObjectContext = [[[Utilities toolbox] createObjectContext] retain];
	}
	return _managedObjectContext;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private methods
- (void) updateExpenseDisplay {

	// Show delete button if there is a value
	if ([currentTransaction needsDeleteButton]) {
		[keyboard enableClearButton];
	} else {
		[keyboard disableClearButton];
	}
	
	// Check if it can be added to?
	if ([currentTransaction canBeAddedTo] == YES) {
		[keyboard enableNumericButtons];
	} else {
		[keyboard disableNumericButtons];
	}

	NSString * text = [currentTransaction absAmountInLocalCurrency];
	[_amount setAmount:text];
}

- (void) layout {
	
	TTFlowLayout * flow = [[TTFlowLayout alloc] init];
	[flow layoutSubviews:self.view.subviews forView:self.view];
	
}

- (void) createAndSetupTransaction {
	// Get a clean slate by releasing previous transactions
	if (currentTransaction != nil) {
		TT_RELEASE_SAFELY(currentTransaction);
	}
	
	currentTransaction = [[NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext] retain];
	
	// If we have a local currency, then use it
	if (self.localCurrency != nil) {
		currentTransaction.currency = self.localCurrency;
	}
	
	[self updateExpenseDisplay];
	[_expenseIncomeControl reset];
}

-(void)currencySelected:(NSString*)currencyCode {
	currentTransaction.currency = currencyCode;
	[self updateExpenseDisplay];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject
- (id)init {
    if (self = [super init]) {
		
			[[Utilities toolbox] setBarColours:self];
			
			self.title = @"Add transaction";
			[self.tabBarItem setImage:[UIImage imageNamed:@"Add.png"]];
			
			[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
						
			// Get the location
			[LocationController sharedInstance].delegate = self;
			[LocationController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			[[LocationController sharedInstance].locationManager startUpdatingLocation];
			
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];	
	[[LocationController sharedInstance].locationManager stopUpdatingLocation];
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_managedObjectContext);
	TT_RELEASE_SAFELY(currentTransaction);
	TT_RELEASE_SAFELY(_amount);
	TT_RELEASE_SAFELY(_expenseIncomeControl);
	TT_RELEASE_SAFELY(_bestLocation);
	TT_RELEASE_SAFELY(_localCurrency);
	[super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void) loadView {
	[super loadView];
	
	// Setup next button
	TTButton * nextButton = [[TTButton buttonWithStyle:@"greenForwardButton:" title:@"Next"] autorelease];
	nextButton.font = [UIFont boldSystemFontOfSize:12];
	[nextButton sizeToFit];
	[nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];

	// Setup the amount label
	self.amount = [[AmountLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
	self.amount.delegate = self;
	
	_expenseIncomeControl = [[ExpenseToggle alloc] init];
	_expenseIncomeControl.delegate = self;

	[self createAndSetupTransaction];
	
	[self.view addSubview:_amount];
	[self.view addSubview:_expenseIncomeControl];

	self.view.backgroundColor = [UIColor blackColor];
	
	[self layout];
	
}
	
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	// CurrencyKeyboard
	keyboard = [[CurrencyKeyboard alloc] init];
	[keyboard setDelegate:self];
	[keyboard showKeyboardWithAnimation:NO];
	
	[self updateExpenseDisplay];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CurrencyKeyboardDelegate
- (void) numericButtonPressed:(NSInteger)key {
	[currentTransaction addNumber:key];
	[self updateExpenseDisplay];
}
- (void) deleteButtonPressed {
	[currentTransaction eraseOneNum];
	[self updateExpenseDisplay];
}
- (void) doubleZeroButtonPressed {
	[currentTransaction addNumber:0];
	[currentTransaction addNumber:0];
	[self updateExpenseDisplay];
}

- (CGFloat) viewHeight {
	return self.view.frame.size.height;
}				

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Change of state - ExpenseToggleDelegate method(s)

- (void)expenseToggleChangedToValue:(KleioExpenseIncomeToggle)value {
		switch (value) {
			case KleioExpenseIncomeToggleSelectedIncome:
				[currentTransaction setExpense:[NSNumber numberWithBool:NO]];
				break;
			case KleioExpenseIncomeToggleSelectedExpense:
				[currentTransaction setExpense:[NSNumber numberWithBool:YES]];
				break;
		}
}

- (IBAction) nextButtonAction {

	TagSelector * tagSelector = [[TagSelector alloc] init];
	tagSelector.delegate = self;
	[tagSelector setMode:TagSelectorModeTransaction];

	// Send the tags to the tagSelector if the transaction already has tags
	NSString * trimmedString = [currentTransaction.tags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSArray * tags = [trimmedString componentsSeparatedByString:@" "];
	tagSelector.tags = tags;
	
	[self.navigationController pushViewController:tagSelector animated:YES];
		
	[tagSelector release];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TagSelectorDelegate

- (void) tagSelectorFinishedWithTagWords:(NSArray*)tagsWords {
	TTLOG(@"Returned with tagswords");
	currentTransaction.tags = [NSString stringWithFormat:@" %@ ", [tagsWords componentsJoinedByString:@" "]];
}

- (void) save {
	TTLOG(@"Save...");
	
	currentTransaction.location = self.bestLocation;
	
	[[Utilities toolbox] save:self.managedObjectContext];
	[self createAndSetupTransaction];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Location Manager delegate methods
#pragma mark CoreLocation - LocationController delegate methods
-(void)locationUpdate:(CLLocation *)location {
	/*
	 Only use locations that are less than five minutes old
	 */
	if (abs([location.timestamp timeIntervalSinceNow]) > 3 * 60) { return; }
	
	if (self.bestLocation == nil) {
		self.bestLocation = location;
		
		// We have to geocode as well!
		[[Utilities toolbox] reverseGeoCode:location.coordinate forDelegate:self];
		
		[self performSelectorInBackground:@selector(findLocationTags) withObject:nil];
		
	} else {
		if (location.timestamp > self.bestLocation.timestamp) {
			self.bestLocation = location;
			
			// And we should do a reverse geocoding as well!
			
		}
	}
}
-(void)locationError:(NSString *)error {
	NSLog(@"Got location error: %@", error);
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)_placemark {
	/*
	 We have to find the currency corrensponding to the country!
	 */
	//self.placemark = _placemark;
	
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
	}
	
	if (!(currencyCode == nil)) {
		
		// Only if the user wants it!
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsUseLocalCurrency"] boolValue] == YES) {
			currentTransaction.currency = currencyCode;
			self.localCurrency = currencyCode;
			[self updateExpenseDisplay];
		}
		
	} else {
		NSLog(@"Couldn't find a currency for %@", countryCode);
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
			NSLog(@"Got strange error when trying to check distance of tag! %@", e);
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
	
	NSArray * suggestedTags;
	
	if ([tagsToSuggest count] > 0) {
		// save them so we have them for the answer
		suggestedTags = [tagsToSuggest copy];
		
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
	NSLog(@"didReceiveMemoryWarning: %@", self);
	
	[[CacheMasterSingleton sharedCacheMaster] clearCache];	
	
	// TODO: REMOVE this box! Fix memory problems instead!
	UIAlertView * alert = [[UIAlertView alloc] init];
	alert.message = NSLocalizedString(@"Your phone is critically low on memory! This application might soon crash. You should try restarting your phone.", @"Low memory alert message");
	[alert addButtonWithTitle:NSLocalizedString(@"OK", @"memory alert OK button")];
	alert.title = NSLocalizedString(@"Memory warning", @"Memory warning alert header");
	[alert show];
	[alert release];
	
	[super didReceiveMemoryWarning];
}

@end
