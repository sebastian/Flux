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
#import "CurrencySelectionDialog.h"
#import <MapKit/MapKit.h>

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MAX_TEXTFIELD_WIDTH = 280;
static const CGFloat MIN_TEXTFIELD_WIDTH = 40;
static const CGFloat TEXTFIELD_PADDING = 10;

@interface ExpenseInputViewController : UIViewController <UIAlertViewDelegate, CurrencySelectionDialogDelegate, MKReverseGeocoderDelegate, UITextFieldDelegate, UITextViewDelegate, CurrencyKeyboardDelegate, KleioCoreLocationDelegate, ControlViewDelegate> {
	
	UILabel * amountLabel;
	UILabel * tagsAndDescription;
	UIView * tagsAndDescriptionView;
	UIImageView * tagsAndDescriptionBackgroundPicture;
	IBOutlet UIView * tagsEditView;
	IBOutlet UITextField * tagsField;
	IBOutlet UITextView * descriptionField;
	
	IBOutlet UILabel * tagsFieldLabel;
	IBOutlet UILabel * descriptionFieldLabel;
	
	IBOutlet UIButton * changeCurrencyButton;
	UILabel * headerLabel;

	// Controller that lets the user switch between income and expense
	ControlViewController * controller;
	
	NSManagedObjectContext *managedObjectContext;
	Transaction * currentTransaction;
	
	CLLocation * bestLocation;
	MKPlacemark * placemark;
	
	BOOL tagsAndDescriptionInDisplay;
	CGRect tagsAndDescriptionViewFrame;
	
	CurrencyKeyboard * currencyKeyboard;
	
	NSString * localCurrency;

	// For fading in and out the what field...
	CGRect originalViewFrame;
	CGRect keyboardBounds;
	
	NSArray * suggestedTags;
}

@property (nonatomic, retain) NSString * localCurrency;
@property (nonatomic, retain) MKPlacemark * placemark;

// CoreData
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// CoreLocation
-(void)locationUpdate:(CLLocation *)location;
-(void)locationError:(NSString *)error;
@property (nonatomic, retain) CLLocation * bestLocation;

// Base currency
-(void)baseCurrencyChanged;

// Outlets
@property (nonatomic, retain) IBOutlet UILabel * amountLabel;
@property (nonatomic, retain) IBOutlet UILabel * headerLabel;
@property (nonatomic, retain) IBOutlet UILabel * tagsAndDescription;
@property (nonatomic, retain) IBOutlet UIView * tagsAndDescriptionView;
@property (nonatomic, retain) IBOutlet UIImageView * tagsAndDescriptionBackgroundPicture;

@property (nonatomic, retain) ControlViewController * controller;
@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;
@property (nonatomic, retain) Transaction * currentTransaction;

// ControlViewDelegate methods
-(void)addButtonPushed;
-(void)whatButtonPushed;
-(void)expenseIncomeSetToExpense:(BOOL)expense;

-(void)addExpense;
-(void)textFieldsResign;
-(void)updateTagsAndDescriptionLabel;
-(void)setupControllersForTransaction;

//-(IBAction)doneKeyboardButtonAction;

-(IBAction)changeCurrency;


// CurrencyKeyboardDelegate methods
- (void)numericButtonPressed:(NSInteger)key;
- (void)okButtonPressed;
- (void)deleteButtonPressed;
//- (void)decimalButtonPressed;


@end