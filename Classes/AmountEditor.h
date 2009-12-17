#import <Three20/Three20.h>
#import "CurrencySelectionDialog.h"
#import "CurrencyKeyboard.h"

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


@protocol AmountLabelDelegate;


@interface AmountLabel : TTView
{
	NSString * _amount;
	id <CurrencySelectionDialogDelegate, AmountLabelDelegate> _delegate;
}
@property (nonatomic, retain) NSString * amount;
@property (nonatomic, assign) id <CurrencySelectionDialogDelegate, AmountLabelDelegate> delegate;
@end

@protocol AmountLabelDelegate 
- (void) presentCurrencyTable;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class Transaction;
@class CurrencyKeyboard;

@protocol AmountEditorDelegate;

@interface AmountEditor : UIViewController <CurrencyKeyboardDelegate, ExpenseToggleDelegate, CurrencySelectionDialogDelegate, AmountLabelDelegate> {
	TTViewController * _delegate;
	
	Transaction * _currentTransaction;

	CurrencyKeyboard * _keyboard;
	
	AmountLabel * _amount;
	ExpenseToggle * _expenseIncomeControl;

}
@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, assign) TTViewController * delegate;

- (void) updateExpenseDisplay;

@end