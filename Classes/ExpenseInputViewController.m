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

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
-(void)save;
-(void)setHeader:(NSString*)heading;
@end


@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amount;
@synthesize headerLabel;
@synthesize tagsAndDescription, tagsAndDescriptionView;
@synthesize tagsAndDescriptionBackgroundPicture;

@synthesize newTransaction;
@synthesize managedObjectContext;

@synthesize controller;
@synthesize currencyKeyboard;

@synthesize bestLocation;


#pragma mark
#pragma mark -
#pragma mark Init, setup and teardown etc
-(id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle {
	self = [super initWithNibName:nibName bundle:bundle];
	if (self) {
		self.title = NSLocalizedString(@"Add transaction", @"Add transaction view controller title");
	}
	return self;	
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// State that the tags and description is not shown by default
	tagsAndDescriptionInDisplay = NO;
	tagsAndDescriptionViewFrame = tagsAndDescriptionView.frame;
	tagsAndDescriptionViewFrame.origin.y = 10;
	
	
	// Set the heading right
	newTransaction.expense = [NSNumber numberWithBool:NO];
	
	// Try to get the location
	[LocationController sharedInstance].delegate = self;
	[LocationController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Create a new Transaction
	self.newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	
	self.currencyKeyboard = [[CurrencyKeyboard alloc] initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]];
	self.currencyKeyboard.delegate = self;
	
	self.controller = [[ControlViewController alloc] initWithNibName:@"ControlViewController" bundle:[NSBundle mainBundle]];
	self.controller.delegate = self;
	[controller addControlBar];
	
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[LocationController sharedInstance].locationManager startUpdatingLocation];
	
	// Show the currency keyboard
	[self.currencyKeyboard showKeyboard];
	[self updateExpenseDisplay];
	
}
- (void)viewDidUnload {
	tagsAndDescriptionBackgroundPicture = nil;
	controller = nil;
	amount = nil;
	[currencyKeyboard release];
	[newTransaction release];
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
	
	[tagsAndDescriptionView release];
	[tagsAndDescription release];
	[headerLabel release];
	[bestLocation release];
	[amount release];
	[managedObjectContext release];
    [super dealloc];
}


#pragma mark
#pragma mark -
#pragma mark CoreLocation - LocationController delegate methods
-(void)locationUpdate:(CLLocation *)location {
	self.bestLocation = location;
}
-(void)locationError:(NSString *)error {
	NSLog(@"Got location error: %@", error);
}

#pragma mark
#pragma mark -
#pragma mark CurrencyKeyboardDelegate methods
- (void)numericButtonPressed:(NSInteger)key {
	[self.newTransaction addNumber:key];
	[self updateExpenseDisplay];
}
- (void)okButtonPressed {
	[self addExpense];
}
- (void)doubleZeroButtonPressed {
	[self.newTransaction addNumber:0];
	[self.newTransaction addNumber:0];
	[self updateExpenseDisplay];
}
-(IBAction)deleteButtonPressed {
	[self.newTransaction eraseOneNum];
	[self updateExpenseDisplay];
}

-(void)addButtonPushed {
	[self addExpense];
}
-(void)whatButtonPushed {

	CGRect tempFrame = tagsAndDescriptionView.frame;
	CGRect newFrame = tagsAndDescriptionViewFrame;
	tagsAndDescriptionViewFrame = tempFrame;
	
	if (tagsAndDescriptionInDisplay) {
		[tagsField resignFirstResponder];
		[descriptionField resignFirstResponder];
		
		[currencyKeyboard showKeyboardWithAnimation:YES]; 

		tagsAndDescription.hidden = NO;
		tagsEditView.hidden = YES;
		tagsAndDescriptionInDisplay = NO;
		tagsAndDescriptionBackgroundPicture.image = [UIImage imageNamed:@"TagDescriptionBackground.png"];
	} else {
		[currencyKeyboard hideKeyboardWithAnimation:YES];

		tagsEditView.hidden = NO;
		tagsAndDescription.hidden = YES;
		tagsAndDescriptionInDisplay = YES;		
		tagsAndDescriptionBackgroundPicture.image = [UIImage imageNamed:@"TagDescriptionBackgroundActive.png"];

		[tagsField becomeFirstResponder];
	}
	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.03];
	
	tagsAndDescriptionView.frame = newFrame;
	
	[UIView commitAnimations];
	
}



#pragma mark
#pragma mark -
#pragma mark Normal methods

-(void)updateExpenseDisplay {
	NSString * text = [self.newTransaction toString];
	CGSize textSize = [text sizeWithFont:[amount font]];
	
	float width = textSize.width + TEXTFIELD_PADDING;
	
	// always make space for at least two characters
	if (width < MIN_TEXTFIELD_WIDTH) {
		width = MIN_TEXTFIELD_WIDTH;
	} else if (width > MAX_TEXTFIELD_WIDTH) {
		width = MAX_TEXTFIELD_WIDTH;
	}
	
	CGRect viewFrame = [amount frame];
	viewFrame.size.width = width;
		
	tagsAndDescription.text = [newTransaction tagsAndDescription];

	// Show delete button if there is a value
	if ([self.newTransaction needsDeleteButton]) {
		[self.currencyKeyboard enableClearButton];
		[controller enableAddButton];
	} else {
		[self.currencyKeyboard disableClearButton];
		[controller disableAddButton];
	}
	
	// Check if it can be added to?
	if ([self.newTransaction canBeAddedTo] == YES) {
		[self.currencyKeyboard enableNumericButtons];
	} else {
		[self.currencyKeyboard disableNumericButtons];
	}
	
	[amount setText:text];
	
	// Things to be animated
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.03];
	
	[amount setFrame:viewFrame];
		
	[UIView commitAnimations];
}
-(void)addExpense {

	// TODO: Set up location
	newTransaction.location = bestLocation;
	
	// FIXME: use currency used on screen
	newTransaction.currency = @"€";
	
	// Save the expense
	[self save];
	
	// Now we should assign a fresh Transaction to add
	Transaction *trs = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	self.newTransaction = trs;
	
	ConfirmationView *confirmationView = [ConfirmationView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
	
	[confirmationView 
		performSelector:@selector(removeView)
		withObject:nil
		afterDelay:1.0];
		
	[self updateExpenseDisplay];
	
}
-(void)setHeader:(NSString*)heading {
	UIFont * font = [UIFont fontWithName:@"Verdana" size:36];
	CGSize textSize = [heading sizeWithFont:font];
	NSLog(@"Setting header label to %@. Size should be %i", heading, textSize.width);
	CGRect frame = headerLabel.frame;
	frame.size.width = textSize.width;
	headerLabel.frame = frame;
	headerLabel.text = heading;
}

#pragma mark
#pragma mark -
#pragma mark CoreData

- (void)save {
	
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}

@end
