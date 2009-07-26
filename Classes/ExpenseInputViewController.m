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

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
-(void)save;
@end


@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amount;
@synthesize textFieldBackground;
@synthesize deleteButtonView;

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
	NSLog(@"Got location: %@", location);
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
- (void)decimalButtonPressed {
	[self.newTransaction addDecimal];
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

	// Try to get the location
	[LocationController sharedInstance].delegate = self;
	
	self.newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	[self updateExpenseDisplay];
	
	self.currencyKeyboard = [[CurrencyKeyboard alloc] initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]];
	self.currencyKeyboard.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[LocationController sharedInstance].locationManager startUpdatingLocation];
	NSLog(@"Started location controller to find the location");
	
	// Show the currency keyboard
	[self.currencyKeyboard showKeyboard];
	
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[[LocationController sharedInstance].locationManager stopUpdatingLocation];
	
	// Hide the currency keyboard
	[self.currencyKeyboard hideKeyboard];
}
- (void)viewDidDisappear:(BOOL)animated {
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
	newTransaction.lat = [NSNumber numberWithFloat:fabs(bestLocation.coordinate.latitude)];
	newTransaction.lng = [NSNumber numberWithFloat:fabs(bestLocation.coordinate.longitude)];
	
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
	
	// Notify the table views that the data has changed
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"transactionsUpdated" object:nil]];

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
	[bestLocation release];
	[deleteButtonView release];
	[amount release];
	[textFieldBackground release];
	[managedObjectContext release];
    [super dealloc];
}



@end
