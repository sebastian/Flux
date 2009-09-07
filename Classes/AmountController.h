//
//  AmountController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CurrencyKeyboard.h"
#import "Transaction.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AmountController : UIViewController <CurrencyKeyboardDelegate> {

	CurrencyKeyboard * keyboard;
	
	// CoreData stuff
	NSManagedObjectContext *managedObjectContext;
	Transaction * currentTransaction;
	
	IBOutlet UILabel * amountLabel;
	IBOutlet UISegmentedControl * nextButton;
	IBOutlet UISegmentedControl * expenseIncome;
	IBOutlet UIImageView * backgroundImageView;
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CurrencyKeyboardDelegate
- (void)numericButtonPressed:(NSInteger)key;
- (void)deleteButtonPressed;
- (void)doubleZeroButtonPressed;
- (CGFloat)viewHeight;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Change of state
- (IBAction) expenseIncomeAction;
- (IBAction) nextButtonAction;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Normal methods
-(void)updateExpenseDisplay;

@end
