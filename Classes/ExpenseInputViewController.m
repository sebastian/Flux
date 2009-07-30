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

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
-(void)save;
-(void)setHeader:(NSString*)heading;
@end


@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amount;
@synthesize textFieldBackground;
@synthesize deleteButtonView;
@synthesize expenseIncomeButton;
@synthesize headerLabel;

@synthesize newTransaction;
@synthesize managedObjectContext;
@synthesize currencyKeyboard;

@synthesize bestLocation;

#pragma mark
#pragma mark -
#pragma mark Actions
-(IBAction)deleteButtonPushed:(id)sender {
	[self.newTransaction eraseOneNum];
	[self updateExpenseDisplay];
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

#pragma mark
#pragma mark -
#pragma mark Init methods

-(id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle {
	self = [super initWithNibName:nibName bundle:bundle];
	if (self) {
		self.title = NSLocalizedString(@"Add transaction", @"Add transaction view controller title");
	}
	return self;	
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// Set the heading right
	newTransaction.expense = [NSNumber numberWithBool:NO];
	[self toggleExpenseIncome:nil];
	
	// Try to get the location
	[LocationController sharedInstance].delegate = self;
	[LocationController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Create a new Transaction
	self.newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	[self updateExpenseDisplay];
	
	self.currencyKeyboard = [[CurrencyKeyboard alloc] initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]];
	self.currencyKeyboard.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[LocationController sharedInstance].locationManager startUpdatingLocation];
	
	// Show the currency keyboard
	[self.currencyKeyboard showKeyboard];
	
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[[LocationController sharedInstance].locationManager stopUpdatingLocation];
	
	// Hide the currency keyboard
	[self.currencyKeyboard hideKeyboard];
}


#pragma mark
#pragma mark -
#pragma mark Normal methods

-(void)updateExpenseDisplay {
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:24.0];
	NSString * text = [self.newTransaction toString];
	
	CGSize textSize = [text sizeWithFont:font];
	
	float width = textSize.width + TEXTFIELD_PADDING;
	
	// always make space for at least two characters
	if (width < MIN_TEXTFIELD_WIDTH) {
		width = MIN_TEXTFIELD_WIDTH;
	} else if (width > MAX_TEXTFIELD_WIDTH) {
		width = MAX_TEXTFIELD_WIDTH;
	}
	
	CGRect viewFrame = [textFieldBackground frame];
	viewFrame.size.width = width;
	
	CGRect buttonFrame = [deleteButtonView frame];
	buttonFrame.origin.x = viewFrame.origin.x + width;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.05];
	
	[amount setText:text];
	[textFieldBackground setFrame:viewFrame];
	[deleteButtonView setFrame:buttonFrame];
	
	// Show delete button if there is a value
	if ([self.newTransaction needsDeleteButton]) {
		[deleteButtonView setAlpha:1.0];
	} else {
		[deleteButtonView setAlpha:0.0];
	}
	
	// Check if the keyboard is needed
	// Decimal button needed?
	if ([self.newTransaction hasDecimals] == YES) {
		[self.currencyKeyboard disableCommaButton];
	} else {
		[self.currencyKeyboard enableCommaButton];
	}
	
	if ([self.newTransaction canBeAddedTo] == YES) {
		[self.currencyKeyboard enableNumericButtons];
	} else {
		[self.currencyKeyboard disableNumericButtons];
	}
		
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
-(IBAction)toggleExpenseIncome:(id)sender {
	if (newTransaction.expense == [NSNumber numberWithBool:YES]) {
		[self setHeader:NSLocalizedString(@"Income", @"Add expenses screen header")];
		newTransaction.expense = [NSNumber numberWithBool:NO];
		[expenseIncomeButton setImage:[UIImage imageNamed:@"SwitchIncome.png"] forState:UIControlStateNormal];
	} else {
		[self setHeader:NSLocalizedString(@"Expense", @"Add expenses screen header")];
		newTransaction.expense = [NSNumber numberWithBool:YES];
		[expenseIncomeButton setImage:[UIImage imageNamed:@"SwitchExpense.png"] forState:UIControlStateNormal];
	}
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

#pragma mark
#pragma mark -
#pragma mark Unloading etc

- (void)viewDidUnload {
	deleteButtonView = nil;
	amount = nil;
	textFieldBackground = nil;
	
	[currencyKeyboard release];
	
	[newTransaction release];
}
- (void)dealloc {
	[headerLabel release];
	[expenseIncomeButton release];
	[bestLocation release];
	[deleteButtonView release];
	[amount release];
	[textFieldBackground release];
	[managedObjectContext release];
    [super dealloc];
}



@end
