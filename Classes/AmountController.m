//
//  AmountController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "AmountController.h"
#import "TagController.h"
#import "Utilities.h"

@implementation AmountController

@synthesize managedObjectContext = _managedObjectContext;
- (NSManagedObjectContext*)managedObjectContext {
	if (_managedObjectContext == nil) {
		_managedObjectContext = [[[Utilities toolbox] createObjectContext] retain];
	}
	return _managedObjectContext;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject


- (id)init {
    if (self = [super initWithNibName:@"AmountController" bundle:[NSBundle mainBundle]]) {
		self.title = @"Add transaction";

		currentTransaction = [[NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext] retain];
		
    }
    return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_managedObjectContext);
	[super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	// CurrencyKeyboard
	keyboard = [[CurrencyKeyboard alloc] init];
	[keyboard setDelegate:self];
	[keyboard showKeyboardWithAnimation:NO];
	
	[nextButton addTarget:@"kleio://tagSelector" action:@selector(openURL) forControlEvents:UIControlEventValueChanged];
	
	[self updateExpenseDisplay];
}
- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CurrencyKeyboardDelegate
- (void)numericButtonPressed:(NSInteger)key {
	[currentTransaction addNumber:key];
	[self updateExpenseDisplay];
}
-(void)deleteButtonPressed {
	[currentTransaction eraseOneNum];
	[self updateExpenseDisplay];
}
- (void)doubleZeroButtonPressed {
	[currentTransaction addNumber:0];
	[currentTransaction addNumber:0];
	[self updateExpenseDisplay];
}

- (CGFloat)viewHeight {
	return self.view.frame.size.height;
}				

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Change of state
- (IBAction) expenseIncomeAction {
	if ([expenseIncome selectedSegmentIndex] == 0) {
		[backgroundImageView setImage:[UIImage imageNamed:@"AddScreenExpense.png"]];
	} else {
		[backgroundImageView setImage:[UIImage imageNamed:@"AddScreenIncome.png"]];
	}
}
- (IBAction) nextButtonAction {
	
//	NSLog(@"Next button pushed");
//	[self 

	
//	TagController * tagController = [[TagController alloc] init];
//	tagController.delegate = self;
//	
//	tagController.modalTransitionStyle = UIModalTransitionStyleCoverVertical; // FlipHorizontal;
//	[self presentModalViewController:tagController animated:YES];
//	
//	[tagController release];
	
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Normal methods
-(void)updateExpenseDisplay {
	NSString * text = [currentTransaction amountInLocalCurrency];
	
	// Show delete button if there is a value
	if ([currentTransaction needsDeleteButton]) {
		[keyboard enableClearButton];
		[nextButton setEnabled:YES forSegmentAtIndex:0];
	} else {
		[keyboard disableClearButton];
		[nextButton setEnabled:NO forSegmentAtIndex:0];
	}
	
	// Check if it can be added to?
	if ([currentTransaction canBeAddedTo] == YES) {
		[keyboard enableNumericButtons];
	} else {
		[keyboard disableNumericButtons];
	}
	
	amountLabel.text = text;

}


@end
