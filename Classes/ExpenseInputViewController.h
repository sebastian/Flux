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
#import "LocationController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MAX_TEXTFIELD_WIDTH = 240;
static const CGFloat MIN_TEXTFIELD_WIDTH = 40;
static const CGFloat TEXTFIELD_PADDING = 10;

@interface ExpenseInputViewController : UIViewController <UITextFieldDelegate, CurrencyKeyboardDelegate, KleioCoreLocationDelegate> {
	UITextField * amount;
	UIView * textFieldBackground;
	UIView * deleteButtonView;
	
	CGRect originalViewFrame;
	CGRect keyboardBounds;
	
	Transaction * newTransaction;
	
	NSManagedObjectContext *managedObjectContext;

	CLLocation * bestLocation;
	
	CurrencyKeyboard * currencyKeyboard;
	
	UILabel * headerLabel;
	UIButton * expenseIncomeButton;
}

// CoreData
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// CoreLocation
-(void)locationUpdate:(CLLocation *)location;
-(void)locationError:(NSString *)error;
@property (nonatomic, retain) CLLocation * bestLocation;


// Outlets
@property (nonatomic, retain) IBOutlet UITextField * amount;
@property (nonatomic, retain) IBOutlet UIView * textFieldBackground;
@property (nonatomic, retain) IBOutlet UIView * deleteButtonView;
@property (nonatomic, retain) IBOutlet UIButton * expenseIncomeButton;
@property (nonatomic, retain) IBOutlet UILabel * headerLabel;

@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;
@property (nonatomic, retain) Transaction * newTransaction;



-(void)addExpense;
-(IBAction)deleteButtonPushed:(id)sender;
-(IBAction)toggleExpenseIncome:(id)sender;

// CurrencyKeyboardDelegate methods
- (void)numericButtonPressed:(NSInteger)key;
- (void)okButtonPressed;
- (void)decimalButtonPressed;

@end