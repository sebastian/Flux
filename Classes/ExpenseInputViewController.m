//
//  FirstViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "ExpenseInputViewController.h"

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
-(void)save;
@end


@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amount;
@synthesize textFieldBackground;
@synthesize deleteButtonView;

@synthesize expenseConfirmation;

@synthesize newTransaction;
@synthesize managedObjectContext;
@synthesize currencyKeyboard;

#pragma mark
#pragma mark -
#pragma mark Actions
-(IBAction)deleteButtonPushed:(id)sender {
	NSLog(@"Backspace button pushed");
	[self.newTransaction eraseOneNum];
	[self updateExpenseDisplay];
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
		NSLog(@"From Expense input view controller init with nib");
		self.title = NSLocalizedString(@"Add transaction", @"Add transaction view controller title");
	}
	return self;	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"View did load");	
	
	NSLog(@"Created a new transaction object");
	self.newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	[self updateExpenseDisplay];
	
	self.currencyKeyboard = [[CurrencyKeyboard alloc] initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]];
	self.currencyKeyboard.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSLog(@"View did appear. No additional action taken.");
	
	// Show the currency keyboard
	[self.currencyKeyboard showKeyboard];
	
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	// Hide the currency keyboard
	[self.currencyKeyboard hideKeyboard];
}
- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"View did disappear. No additional action taken.");
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

	// Save the expense
	[self save];
	
	// Now we should assign a fresh Transaction to add
	Transaction *trs = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
	self.newTransaction = trs;

	[self.view bringSubviewToFront:expenseConfirmation];
	expenseConfirmation.hidden = NO;	
	
	CGRect newFrame = expenseConfirmation.frame;
	expenseConfirmation.frame = newFrame;
	newFrame.origin.x = [self.view frame].size.width / 2 - newFrame.size.width / 2;
	newFrame.origin.y = [self.view frame].size.height / 2 - newFrame.size.height / 2;
	
	newFrame.size.width = 1;
	newFrame.size.height = 1;
	
	// Animate the changes
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeinAnimationDidStop:finished:context:)];
	
	expenseConfirmation.transform = CGAffineTransformMakeScale(1.0, 1.0);
	
	NSLog(@"Performing animation. Fade in");
	[UIView commitAnimations];
	
	[self updateExpenseDisplay];
}
- (void)fadeinAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:3.0];
	
	expenseConfirmation.transform = CGAffineTransformMakeScale(0.001, 0.001);
	
	NSLog(@"Performing animation. Fade out");
	[UIView commitAnimations];
	
	expenseConfirmation.hidden = YES;
	
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
	NSLog(@"viewDidUnload...");
	
	deleteButtonView = nil;
	amount = nil;
	textFieldBackground = nil;
	
	[currencyKeyboard release];
	
	NSLog(@"Released newTransaction in viewDidUnload");
	[newTransaction release];
	
	expenseConfirmation = nil;
}
- (void)dealloc {
	[expenseConfirmation release];
	
	[deleteButtonView release];
	[amount release];
	[textFieldBackground release];
	[managedObjectContext release];
    [super dealloc];
}



@end
