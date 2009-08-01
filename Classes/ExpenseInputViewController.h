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
#import "CurrencyKeyboard.h"
#import "LocationController.h"
#import "ControlViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MAX_TEXTFIELD_WIDTH = 300;
static const CGFloat MIN_TEXTFIELD_WIDTH = 40;
static const CGFloat TEXTFIELD_PADDING = 10;

@interface ExpenseInputViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, CurrencyKeyboardDelegate, KleioCoreLocationDelegate, ControlViewDelegate> {
	UILabel * amountLabel;
	ControlViewController * controller;

	UILabel * tagsAndDescription;
	UIView * tagsAndDescriptionView;
	UIImageView * tagsAndDescriptionBackgroundPicture;
	
	IBOutlet UIView * tagsEditView;
	IBOutlet UITextField * tagsField;
	IBOutlet UITextView * descriptionField;
		
	CGRect originalViewFrame;
	CGRect keyboardBounds;
	
	Transaction * newTransaction;
	
	NSManagedObjectContext *managedObjectContext;

	CLLocation * bestLocation;
	
	BOOL tagsAndDescriptionInDisplay;
	CGRect tagsAndDescriptionViewFrame;
	
	CurrencyKeyboard * currencyKeyboard;
	
	UILabel * headerLabel;
}

// CoreData
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// CoreLocation
-(void)locationUpdate:(CLLocation *)location;
-(void)locationError:(NSString *)error;
@property (nonatomic, retain) CLLocation * bestLocation;


// Outlets
@property (nonatomic, retain) IBOutlet UILabel * amountLabel;
@property (nonatomic, retain) IBOutlet UILabel * headerLabel;
@property (nonatomic, retain) IBOutlet UILabel * tagsAndDescription;
@property (nonatomic, retain) IBOutlet UIView * tagsAndDescriptionView;
@property (nonatomic, retain) IBOutlet UIImageView * tagsAndDescriptionBackgroundPicture;

@property (nonatomic, retain) ControlViewController * controller;
@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;
@property (nonatomic, retain) Transaction * newTransaction;

// ControlViewDelegate methods
-(void)addButtonPushed;
-(void)whatButtonPushed;
-(void)expenseIncomeSetToExpense:(BOOL)expense;

-(void)addExpense;
-(void)textFieldsResign;
-(void)updateTagsAndDescriptionLabel;
-(void)setupControllersForNewTransaction;

-(IBAction)doneKeyboardButtonAction;


// CurrencyKeyboardDelegate methods
- (void)numericButtonPressed:(NSInteger)key;
- (void)okButtonPressed;
- (void)deleteButtonPressed;
//- (void)decimalButtonPressed;


@end