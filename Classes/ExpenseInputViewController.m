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

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
@end


@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amountLabel;
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
	
	// Set the same font for textview and textfield
	// I do it programatically because I can't find a way
	// To do it in Interface builder...
	descriptionField.font = tagsField.font;
			
	// Try to get the location
	[LocationController sharedInstance].delegate = self;
	[LocationController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Create the currency keyboard
	self.currencyKeyboard = [[CurrencyKeyboard alloc] initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]];
	self.currencyKeyboard.delegate = self;
	
	// Create the controller bar
	self.controller = [[ControlViewController alloc] initWithNibName:@"ControlViewController" bundle:[NSBundle mainBundle]];
	self.controller.delegate = self;
	[controller addControlBar];

	// Create a new Transaction
	self.newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	
	// Setup controllers for transaction
	[self setupControllersForNewTransaction];

	
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
	[amountLabel release];
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
-(void)deleteButtonPressed {
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
	
}
-(void)expenseIncomeSetToExpense:(BOOL)expense {
	newTransaction.expense = [NSNumber numberWithBool:expense];
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
#pragma mark Normal methods

-(void)updateExpenseDisplay {
	NSString * text = [self.newTransaction toString];
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
	if ([newTransaction needsDeleteButton]) {
		[currencyKeyboard enableClearButton];
		[controller enableAddButton];
	} else {
		[currencyKeyboard disableClearButton];
		[controller disableAddButton];
	}
	
	// Check if it can be added to?
	if ([newTransaction canBeAddedTo] == YES) {
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
	newTransaction.location = bestLocation;
	
	// Set tags and description
	newTransaction.tags = tagsField.text;
	newTransaction.transactionDescription = descriptionField.text;
	
	// FIXME: use currency used on screen
	newTransaction.currency = @"€";
	
	// Save the expense
	[[Utilities toolbox] save:managedObjectContext];
	
	// Now we should assign a fresh Transaction to add
	Transaction *trs = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	self.newTransaction = trs;
	
	ConfirmationView *confirmationView = [ConfirmationView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
	
	[confirmationView 
		performSelector:@selector(removeView)
		withObject:nil
		afterDelay:1.0];
	
	[self setupControllersForNewTransaction];	
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
		if ([tagsField.text isEqualToString:newTransaction.tags]) {
			// They are equal...
			// They are the same... hence we use what we have
			[tagsDescription appendFormat:@"%@", newTransaction.tags];
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
-(void)setupControllersForNewTransaction {
	
	if (newTransaction.expense == [NSNumber numberWithBool:YES]) {
		[controller setSelectExpenseIncomeSegment:0];
	} else {
		[controller setSelectExpenseIncomeSegment:1];
	}
	
	// Clear the tags and description fields for next use
	tagsField.text = @"";
	descriptionField.text = @"";
	
	[self updateExpenseDisplay];
	[self updateTagsAndDescriptionLabel];
}

-(IBAction)doneKeyboardButtonAction {
	NSLog(@"Keyboard pushed DONE");
}


@end
