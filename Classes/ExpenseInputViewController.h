//
//  FirstViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MAX_TEXTFIELD_WIDTH = 180;
static const CGFloat MIN_TEXTFIELD_WIDTH = 40;
static const CGFloat TEXTFIELD_PADDING = 10;

@protocol FinanceCoreDataDelegate;


@interface ExpenseInputViewController : UIViewController <UITextFieldDelegate> {
	UITextField * amount;
	UIView * textFieldBackground;
	UIView * deleteButtonView;
	
	CGRect originalViewFrame;
	CGRect keyboardBounds;
	
	Transaction * newTransaction;
	
	id <FinanceCoreDataDelegate> delegate;
}

// CoreData
@property (nonatomic, retain) id <FinanceCoreDataDelegate> delegate;


// Outlets
@property (nonatomic, retain) IBOutlet UITextField * amount;
@property (nonatomic, retain) IBOutlet UIView * textFieldBackground;
@property (nonatomic, retain) IBOutlet UIView * deleteButtonView;

@property (nonatomic, retain) Transaction * newTransaction;

-(IBAction)addExpense:(id)sender;
-(IBAction)numberButtonPushed:(id)sender;
-(IBAction)decimalButtonPushed:(id)sender;
-(IBAction)deleteButtonPushed:(id)sender;

@end



@protocol FinanceCoreDataDelegate

-(NSManagedObjectContext*)managedObjectContext;

@end

