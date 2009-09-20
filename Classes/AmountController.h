//
//  AmountController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "CurrencyKeyboard.h"
#import "Transaction.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TagSelector.h"
#import "CurrencyManager.h"
#import "LocationController.h"
#import "CurrencySelectionDialog.h"

@protocol ExpenseToggleDelegate;

typedef enum {
	KleioExpenseIncomeToggleSelectedExpense = 0,
	KleioExpenseIncomeToggleSelectedIncome = 1
} KleioExpenseIncomeToggle;


@interface ExpenseToggle : TTView
{
	id <ExpenseToggleDelegate> _delegate;
	UISegmentedControl * eiCtrl;
}
@property (nonatomic, assign) id <ExpenseToggleDelegate> delegate;

// Public
- (void) reset;

@end

@protocol ExpenseToggleDelegate <NSObject>
- (void)expenseToggleChangedToValue:(KleioExpenseIncomeToggle)value;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface AmountLabel : TTView
{
	NSString * _amount;
	UIViewController<CurrencySelectionDialogDelegate> * _delegate;
}
@property (nonatomic, retain) NSString * amount;
@property (nonatomic, assign) UIViewController * delegate;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface AmountController : TTViewController 
<CurrencyKeyboardDelegate, TagSelectorDelegate, 
 ExpenseToggleDelegate, KleioCoreLocationDelegate, 
 MKReverseGeocoderDelegate, CurrencySelectionDialogDelegate> {

	CurrencyKeyboard * keyboard;
	
	// CoreData stuff
	NSManagedObjectContext *_managedObjectContext;
	Transaction * currentTransaction;
	
	AmountLabel * _amount;
	ExpenseToggle * _expenseIncomeControl;
	
	CLLocation * _bestLocation;
	NSString * _localCurrency;
	
}
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) AmountLabel * amount;
@property (nonatomic, retain) CLLocation * bestLocation;
@property (nonatomic, retain) NSString * localCurrency;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CurrencyKeyboardDelegate
- (void)numericButtonPressed:(NSInteger)key;
- (void)deleteButtonPressed;
- (void)doubleZeroButtonPressed;
- (CGFloat)viewHeight;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Change of state
- (IBAction) nextButtonAction;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Normal methods
-(void)updateExpenseDisplay;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TagSelectorDelegate
- (void)tagSelectorFinishedWithTagWords:(NSArray*)tagsWords;
- (void) save;

@end
