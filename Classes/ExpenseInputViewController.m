//
//  FirstViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "ExpenseInputViewController.h"
#import "ConfirmationView.h"
#import "LocationController.h"
#import <QuartzCore/QuartzCore.h>
#import "ControlViewController.h"
#import "Utilities.h"
#import "CurrencyManager.h"

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
-(CGFloat)viewHeight;
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

@synthesize geoCoder;
@synthesize localCurrency;


#pragma mark
#pragma mark -
#pragma mark Init, setup and teardown etc
-(id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle {
	self = [super initWithNibName:nibName bundle:bundle];
	if (self) {
		self.title = NSLocalizedString(@"Add transaction", @"Add transaction view controller title");
		self.currentTransaction = nil;
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
}

- (void)dealloc {
	self.controller = nil;
	self.tagsAndDescriptionBackgroundPicture = nil;
	
	self.geoCoder = nil;
	
	[tagsAndDescriptionView release];
	[tagsAndDescription release];
	[headerLabel release];
	[bestLocation release];
	[amountLabel release];
	[managedObjectContext release];
	[localCurrency release];
    [super dealloc];
}


#pragma mark
#pragma mark -
#pragma mark CoreLocation - LocationController delegate methods
-(void)locationUpdate:(CLLocation *)location {
	/*
	 Only use locations that are less than five minutes old
	 */
	NSLog(@"Got a timestamp! (%i)", [location.timestamp timeIntervalSinceNow]);
	if (abs([location.timestamp timeIntervalSinceNow]) > 5 * 60) { return; }
	NSLog(@"It was less than fivem minutes old, use it! (%i)", [location.timestamp timeIntervalSinceNow]);
	NSLog(@"The location: %@", location);
	
	
	if (self.bestLocation == nil) {
		self.bestLocation = location;
		
		NSLog(@"Starting geocoding");
		// We have to geocode as well!
		self.geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
		geoCoder.delegate = self;
		[geoCoder start];
		
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
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	/*
	 We have to find the currency corrensponding to the country!
	 */
	NSString * countryCode = placemark.countryCode;
	NSLog(@"Found countrycode: %@", countryCode);
	
	NSString * currencyCode = [[[CurrencyManager sharedManager] countryToCurrency] objectForKey:countryCode];
	
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
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	// Nothing much to do...
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
-(void)addExpense {

	// If it was in tag mode, then get out of it
	if (tagsAndDescriptionInDisplay) {
		//FIXME: Tight coupling nightmare!
		[controller whatAction];
	}
	
	// Set the location
	currentTransaction.location = bestLocation;
	
	// Set tags and description
	currentTransaction.tags = tagsField.text;
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
			[tagsDescription appendFormat:@"%@", currentTransaction.tags];
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
	tagsField.text = currentTransaction.tags;
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
    [super didReceiveMemoryWarning];
}

@end
