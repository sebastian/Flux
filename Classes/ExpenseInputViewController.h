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


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MAX_TEXTFIELD_WIDTH = 240;
static const CGFloat MIN_TEXTFIELD_WIDTH = 40;
static const CGFloat TEXTFIELD_PADDING = 10;

@interface ExpenseInputViewController : UIViewController <UITextFieldDelegate> {
	UITextField * amount;
	UIView * textFieldBackground;
	UIView * deleteButtonView;
	
	CGRect originalViewFrame;
	CGRect keyboardBounds;
	
	Transaction * newTransaction;
	
	NSManagedObjectContext *managedObjectContext;
	
	UIButton * button1;
	UIButton * button2; 
	UIButton * button3;
	UIButton * button4;
	UIButton * button5;
	UIButton * button6;
	UIButton * button7;
	UIButton * button8;
	UIButton * button9;
	UIButton * button0;
	UIButton * buttonAdd;
	UIButton * buttonComma;
	
	UIImageView * expenseConfirmation;
}

// CoreData
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


// Outlets
@property (nonatomic, retain) IBOutlet UITextField * amount;
@property (nonatomic, retain) IBOutlet UIView * textFieldBackground;
@property (nonatomic, retain) IBOutlet UIView * deleteButtonView;
@property (nonatomic, retain) IBOutlet UIImageView * expenseConfirmation;


@property (nonatomic, retain) Transaction * newTransaction;

-(IBAction)addExpense:(id)sender;
-(IBAction)numberButtonPushed:(id)sender;
-(IBAction)decimalButtonPushed:(id)sender;
-(IBAction)deleteButtonPushed:(id)sender;

// Keyboard buttons
@property (nonatomic, retain) IBOutlet UIButton * button1;
@property (nonatomic, retain) IBOutlet UIButton * button2;
@property (nonatomic, retain) IBOutlet UIButton * button3;
@property (nonatomic, retain) IBOutlet UIButton * button4;
@property (nonatomic, retain) IBOutlet UIButton * button5;
@property (nonatomic, retain) IBOutlet UIButton * button6;
@property (nonatomic, retain) IBOutlet UIButton * button7;
@property (nonatomic, retain) IBOutlet UIButton * button8;
@property (nonatomic, retain) IBOutlet UIButton * button9;
@property (nonatomic, retain) IBOutlet UIButton * button0;
@property (nonatomic, retain) IBOutlet UIButton * buttonAdd;
@property (nonatomic, retain) IBOutlet UIButton * buttonComma;

-(id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle andManagedObjectContext:(NSManagedObjectContext*) context;

@end