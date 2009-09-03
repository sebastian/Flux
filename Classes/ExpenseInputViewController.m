//
//  FirstViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "ExpenseInputViewController.h"

#import "FinanceCoreDataDelegate.h"
#import "ConfirmationView.h"
#import <QuartzCore/QuartzCore.h>
#import "ControlViewController.h"
#import "Utilities.h"
#import "CurrencyManager.h"
#import "Location.h"
#import "Tag.h"
#import "Transaction.h"
#import "CacheMasterSingleton.h"

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
-(CGFloat)viewHeight;
-(void)findLocationTags;
@end


@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amountLabel;
@synthesize headerLabel;
@synthesize tagsAndDescription, tagsAndDescriptionView;
@synthesize tagsAndDescriptionBackgroundPicture;

@synthesize currentTransaction;
@synthesize managedObjectContext;

@synthesize controller;
@synthesize currencyKeyboard;

@synthesize bestLocation;

@synthesize localCurrency;

@synthesize placemark;
@synthesize tagSuggester;

#pragma mark
#pragma mark -
#pragma mark Init, setup and teardown etc
-(id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle {
	self = [super initWithNibName:nibName bundle:bundle];
	if (self) {
		self.title = NSLocalizedString(@"Add", @"Add transaction view controller title");
		self.currentTransaction = nil;
		[self.tabBarItem setImage:[UIImage imageNamed:@"Add.png"]];
	}
	return self;	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Used to set the currency for new transactions
	self.localCurrency = [[CurrencyManager sharedManager] baseCurrency];
	
	// State that the tags and description is not shown by default
	tagsAndDescriptionInDisplay = NO;
	tagsAndDescriptionViewFrame = tagsAndDescriptionView.frame;
	tagsAndDescriptionViewFrame.origin.y = 10;
	
	// Set the same font for textview and textfield
	// I do it programatically because I can't find a way
	// To do it in Interface builder...
	descriptionField.font = tagsField.font;
		
	tagsFieldLabel.text = NSLocalizedString(@"Tags:",nil);
	descriptionFieldLabel.text = NSLocalizedString(@"Description:",nil);
	
	// Create the currency keyboard
	self.currencyKeyboard = [[CurrencyKeyboard alloc] initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]];
	self.currencyKeyboard.delegate = self;
	
	// Create the controller bar
	self.controller = [[ControlViewController alloc] initWithNibName:@"ControlViewController" bundle:[NSBundle mainBundle]];
	self.controller.delegate = self;
	[controller addControlBar];

	// if there is no transaction, then create a new one
	if (currentTransaction == nil) {
		// Try to get the location
		[LocationController sharedInstance].delegate = self;
		[LocationController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		
		// Create a new Transaction
		self.currentTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];		
	}
		
	// Setup controllers for transaction
	[self setupControllersForTransaction];

	/*
	 If the base currency is updated we have to delete our cache...
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baseCurrencyChanged) name:@"CurrencyManagerDidChangeBaseCurrency" object:nil];	
	
	
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[LocationController sharedInstance].locationManager startUpdatingLocation];
	
	// Show the currency keyboard
	[self.currencyKeyboard showKeyboard];
	[self updateExpenseDisplay];
	
	isVisible = YES;
	
}
- (void)viewDidUnload {
	// Save the context to make sure last minute changes get saved too
	[[Utilities toolbox] save:managedObjectContext];
	
	tagsAndDescriptionBackgroundPicture = nil;
	controller = nil;
	amountLabel = nil;
	[currencyKeyboard release];
	[currentTransaction release];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[LocationController sharedInstance].locationManager stopUpdatingLocation];
	
	// Hide the currency keyboard
	[self.currencyKeyboard hideKeyboard];
	
	isVisible = NO;
}

- (void)dealloc {
	self.controller = nil;
	self.tagSuggester = nil;
	self.tagsAndDescriptionBackgroundPicture = nil;
	self.placemark = nil;
	self.tagsAndDescriptionView = nil;
	self.tagsAndDescription = nil;
	self.headerLabel = nil;
	self.bestLocation = nil;
	self.amountLabel = nil;
	self.managedObjectContext = nil;
	self.localCurrency = nil;

    [super dealloc];
}


#pragma mark
#pragma mark -
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
	self.placemark = _placemark;
	
	NSString * countryCode = placemark.countryCode;
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
			self.currentTransaction.currency = currencyCode;
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
	
	if (([tagsToSuggest count] > 0) && (isVisible == YES)) {
		UIAlertView * alert = [[UIAlertView alloc] init];
		
		// save them so we have them for the answer
		suggestedTags = [tagsToSuggest copy];
		
		alert.title = NSLocalizedString(@"Found tags previously used in this area",nil);
		
		alert.message = NSLocalizedString(@"Do you want to use the following tags:",nil);
		
		NSString * tagNames = [NSString stringWithFormat:@" %@", ((Tag*)[tagsToSuggest objectAtIndex:0]).name];
		[tagsToSuggest removeObjectAtIndex:0];
		
		for (Tag * tag in tagsToSuggest) {
			tagNames = [tagNames stringByAppendingFormat:@", %@", tag.name];
		}
		tagNames = [tagNames stringByAppendingString:@"."];
		
		alert.message = [alert.message stringByAppendingString:tagNames];
		
		[alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
		
		alert.delegate = self;
		
		[alert show];
	}
	
	[tagsToSuggest release];
		
	[pool release];
	
}


#pragma mark
#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0) {
		// Wants to use the tags
		NSString * tagsPrepend = @"";
		if (![tagsField.text isEqualToString:@""]) {tagsPrepend = @" ";}
		
		NSString * tags = @"";
		
		for (Tag * tag in suggestedTags) {
			tags = [tags stringByAppendingFormat:@" %@", tag.name];
		}
		tags = [tags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		tags = [tagsPrepend stringByAppendingString:tags];
		
		tagsField.text = [tagsField.text stringByAppendingString:tags];
		
		// Set the tags and description field to mimic the newly typed in descriptions
		[self updateTagsAndDescriptionLabel];
	} 
	
	// Don't need the tags anymore :)
	[suggestedTags release];
}

#pragma mark
#pragma mark -
#pragma mark TagSuggesterDelegate methods
-(void)addTagWord:(NSString*)tag {
	tagsField.text = [tagsField.text stringByAppendingString:tag];
}
-(IBAction)textChanged {
	[self.tagSuggester setTagText:tagsField.text];
}
-(IBAction)startedEditing {
	self.tagSuggester = [[TagSuggesterViewController alloc] init];
	self.tagSuggester.delegate = self;
	[self.tagSuggester isForAddExpenseView];
}
-(IBAction)stoppedEditing {
	[self.tagSuggester remove];
	self.tagSuggester = nil;
}

#pragma mark
#pragma mark -
#pragma mark CurrencyKeyboardDelegate methods
- (void)numericButtonPressed:(NSInteger)key {
	[self.currentTransaction addNumber:key];
	[self updateExpenseDisplay];
}
- (void)okButtonPressed {
	[self addExpense];
}
- (void)doubleZeroButtonPressed {
	[self.currentTransaction addNumber:0];
	[self.currentTransaction addNumber:0];
	[self updateExpenseDisplay];
}
-(void)deleteButtonPressed {
	[self.currentTransaction eraseOneNum];
	[self updateExpenseDisplay];
}

-(void)addButtonPushed {
	[self addExpense];
}
-(void)whatButtonPushed {
	
	CGRect tempFrame = tagsAndDescriptionView.frame;
	CGRect newFrame = tagsAndDescriptionViewFrame;
	tagsAndDescriptionViewFrame = tempFrame;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.03];
	
	tagsAndDescriptionView.frame = newFrame;
	
	
	[UIView commitAnimations];
		
	if (tagsAndDescriptionInDisplay) {
		// Resign first responder from tags and description textfields
		[self textFieldsResign];

		// Set the tags and description field to mimic the newly typed in descriptions
		[self updateTagsAndDescriptionLabel];
		
		[currencyKeyboard showKeyboardWithAnimation:YES]; 

		changeCurrencyButton.hidden = NO;
		tagsAndDescription.hidden = NO;
		tagsEditView.hidden = YES;
		tagsAndDescriptionInDisplay = NO;
		tagsAndDescriptionBackgroundPicture.image = [UIImage imageNamed:@"TagDescriptionBackground.png"];
	} else {
		[currencyKeyboard hideKeyboardWithAnimation:YES];

		changeCurrencyButton.hidden = YES;
		tagsEditView.hidden = NO;
		tagsAndDescription.hidden = YES;
		tagsAndDescriptionInDisplay = YES;		
		tagsAndDescriptionBackgroundPicture.image = [UIImage imageNamed:@"TagDescriptionBackgroundActive.png"];

		[tagsField becomeFirstResponder];
	}
	
}
-(void)expenseIncomeSetToExpense:(BOOL)expense {
	currentTransaction.expense = [NSNumber numberWithBool:expense];
	[self updateExpenseDisplay];
}

//The height is changing for some reason or another, so we have to fake it
-(CGFloat)viewHeight {	
	return 411.f;
}

#pragma mark
#pragma mark -
#pragma mark TextField and TextViewDelegates
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[self textFieldsResign];
	[controller whatAction];
	return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField == tagsField) {
		NSString * text = [tagsField.text stringByReplacingCharactersInRange:range withString:string];
		[self.tagSuggester setTagText:text];
	}
	return YES;
}


#pragma mark
#pragma mark -
#pragma mark  Change the currency (CurrencySelectionDialogDelegate method)
-(IBAction)changeCurrency {
	/* 
	 Called when the user clicks on the amount
	 Let the user select another input currency
	 */ 
	
	CurrencySelectionDialog *currencySelectionDialog = [[CurrencySelectionDialog new] autorelease];
	// So we can report back the currency change
	currencySelectionDialog.delegate = self;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:currencySelectionDialog] autorelease];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self presentModalViewController:navController animated:YES];
}
-(void)currencySelected:(NSString*)currencyCode {
	// Set the currency in the current transaction
	self.currentTransaction.currency = currencyCode;
}


#pragma mark
#pragma mark -
#pragma mark Normal methods
-(void)updateExpenseDisplay {
	NSString * text = [self.currentTransaction amountInLocalCurrency];
	CGSize textSize = [text sizeWithFont:[amountLabel font]];
	
	float width = textSize.width + TEXTFIELD_PADDING;
	
	// always make space for at least two characters
	if (width < MIN_TEXTFIELD_WIDTH) {
		width = MIN_TEXTFIELD_WIDTH;
	} else if (width > MAX_TEXTFIELD_WIDTH) {
		width = MAX_TEXTFIELD_WIDTH;
	}
	
	CGRect viewFrame = [amountLabel frame];
	viewFrame.size.width = width;
		
	// Show delete button if there is a value
	if ([currentTransaction needsDeleteButton]) {
		[currencyKeyboard enableClearButton];
		[controller enableAddButton];
	} else {
		[currencyKeyboard disableClearButton];
		[controller disableAddButton];
	}
	
	// Check if it can be added to?
	if ([currentTransaction canBeAddedTo] == YES) {
		[currencyKeyboard enableNumericButtons];
	} else {
		[currencyKeyboard disableNumericButtons];
	}
	
	[amountLabel setText:text];
	
	// Things to be animated
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.03];
	
	[amountLabel setFrame:viewFrame];
		
	[UIView commitAnimations];
}
-(void)add:(NSString*)what toArray:(NSMutableArray*)array {
	if (self.placemark != nil) {
		if ([placemark valueForKey:what] != nil) {
			[array addObject:[placemark valueForKey:what]];
		}
	}
}
-(void)addExpense {

	// If it was in tag mode, then get out of it
	if (tagsAndDescriptionInDisplay) {
		//FIXME: Tight coupling nightmare!
		[controller whatAction];
	}
	
	// Set the location
	currentTransaction.location = self.bestLocation;
	
	// Set tags and description
	currentTransaction.tags = tagsField.text;
	
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
	NSDateComponents * components = [currentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit) fromDate:self.currentTransaction.date];
	
	NSString * month = [months objectAtIndex:components.month-1];
	NSString * weekday = [weekdays objectAtIndex:components.weekday-1];
	NSString * year = [NSString stringWithFormat:@"%i", components.year];
	
	[autotags addObject:month];
	[autotags addObject:weekday];
	[autotags addObject:year];
	
	NSString * newAutoTags = [autotags componentsJoinedByString:@" "];
	currentTransaction.autotags = [NSString stringWithFormat:@" %@ ", newAutoTags];
	

	currentTransaction.transactionDescription = descriptionField.text;
		
	// Save the expense
	[[Utilities toolbox] save:managedObjectContext];
	
	ConfirmationView *confirmationView = [ConfirmationView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
	
	[confirmationView 
		performSelector:@selector(removeView)
		withObject:nil
		afterDelay:1.0];
	

	// Now we should assign a fresh Transaction to add
	Transaction *trs = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	trs.currency = self.localCurrency;
	self.currentTransaction = trs;
	
	[self setupControllersForTransaction];	
}
-(void)textFieldsResign {
	[tagsField resignFirstResponder];
	[currencyKeyboard showKeyboard];
	[descriptionField resignFirstResponder];
	self.tagSuggester = nil;
}
-(void)updateTagsAndDescriptionLabel {
	NSMutableString * tagsDescription = [NSMutableString stringWithString:NSLocalizedString(@"Tags", @"Tags label in add expenses thing")];
	[tagsDescription appendString:@": "];
		
	// First check and see if there are tags and descriptions
	// from the transaction object
	if (![tagsField.text isEqualToString:@""]) {
		// There are tags... check if there are updated tags in the tags field
		if ([tagsField.text isEqualToString:currentTransaction.tags]) {
			// They are equal...
			// They are the same... hence we use what we have
			[tagsDescription appendFormat:@"%@", [currentTransaction trimmedTags]];
			tagsAndDescription.text = tagsDescription;
		} else {
			// They are not equal... That means that is must have been updated
			// because at launch they were set to equal.
			// Use the new one:
			[tagsDescription appendString:tagsField.text];
			tagsAndDescription.text = tagsDescription;			
		}
	} else {
		NSString * nothingThere = NSLocalizedString(@"(currently no tags assigned)", @"No tags");
		[tagsDescription appendString:nothingThere];
		tagsAndDescription.text = tagsDescription;
	}
	
}
-(void)setupControllersForTransaction {
	
	if (currentTransaction.expense == [NSNumber numberWithBool:YES]) {
		[controller setSelectExpenseIncomeSegment:0];
	} else {
		[controller setSelectExpenseIncomeSegment:1];
	}
	
	// Clear the tags and description fields for next use
	tagsField.text = [currentTransaction trimmedTags];
	descriptionField.text = currentTransaction.transactionDescription;
	
	[self updateExpenseDisplay];
	[self updateTagsAndDescriptionLabel];
}
-(void)baseCurrencyChanged {
	/*
	 This really is an edge case!
	 CASE: the user does not want to use the local currency
	 SCENARIO: The user changed his base currency. Hence the currency of the temporary
	 transaction should be updated to reflect that...
	 */
	// Only if the user wants it!
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsUseLocalCurrency"] boolValue] == YES) {
		self.currentTransaction.currency = [[CurrencyManager sharedManager] baseCurrency];
		self.localCurrency = [[CurrencyManager sharedManager] baseCurrency];
		[self updateExpenseDisplay];			
	}
}


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
