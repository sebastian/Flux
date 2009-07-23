//
//  FirstViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "FinanceCoreDataDelegate.h"
#import "CurrencyKeyboardDelegateProtocol.h"
#import "CurrencyKeyboard.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MAX_TEXTFIELD_WIDTH = 240;
static const CGFloat MIN_TEXTFIELD_WIDTH = 40;
static const CGFloat TEXTFIELD_PADDING = 10;

@interface ExpenseInputViewController : UIViewController <UITextFieldDelegate, CurrencyKeyboardDelegate> {
	UITextField * amount;
	UIView * textFieldBackground;
	UIView * deleteButtonView;
	
	CGRect originalViewFrame;
	CGRect keyboardBounds;
	
	Transaction * newTransaction;
	
	NSManagedObjectContext *managedObjectContext;
		
	CurrencyKeyboard * currencyKeyboard;
}

// CoreData
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


// Outlets
@property (nonatomic, retain) IBOutlet UITextField * amount;
@property (nonatomic, retain) IBOutlet UIView * textFieldBackground;
@property (nonatomic, retain) IBOutlet UIView * deleteButtonView;

@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;
@property (nonatomic, retain) Transaction * newTransaction;

-(void)addExpense;
-(IBAction)deleteButtonPushed:(id)sender;

// CurrencyKeyboardDelegate methods
- (void)numericButtonPressed:(NSInteger)key;
- (void)okButtonPressed;
- (void)decimalButtonPressed;

@end