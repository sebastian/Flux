//
//  EditTransaction.h
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrencyKeyboard.h"
#import <MapKit/MapKit.h>
#import "TagSuggesterViewController.h"


@class Transaction;

@interface EditTransaction : UIViewController <TagSuggesterDelegate, UITextViewDelegate, UITextFieldDelegate, MKReverseGeocoderDelegate, CurrencyKeyboardDelegate> {
	Transaction * currentTransaction;
	
	CurrencyKeyboard * currencyKeyboard;
	
	UIBarButtonItem * saveButton;
	UIBarButtonItem * cancelButton;
	
	IBOutlet UIDatePicker * datePicker;
	IBOutlet UIView * datePickerView;
	
	IBOutlet UIView * editView;
	IBOutlet UIScrollView * scrollview;
	
	IBOutlet UILabel * amountLabel;
	IBOutlet UIButton * amountButton;
	IBOutlet UILabel * baseCurrencyAmountLabel;
	IBOutlet UISegmentedControl * expenseIncomeControl;
	
	IBOutlet UILabel * dateLabel;
	IBOutlet UIButton * dateButton;
	
	IBOutlet UILabel * locationLabel;
	IBOutlet UILabel * locationDataLabel;
	IBOutlet UISegmentedControl * locationClearButton;
	
	IBOutlet UILabel * tagsLabel;
	IBOutlet UITextField * tagsField;
	
	IBOutlet UILabel * descriptionLabel;
	IBOutlet UITextView * descriptionView;
	
	// temporary values for safe keeping
	NSString * transactionDescription;
	NSString * tags;
	NSString * autotags;
	NSNumber * kroner;
	NSNumber * expense;
	CLLocation * location;
	NSString * currency;
	NSDate * date;
	NSString * yearMonth;
	NSNumber * day;
		
	BOOL datePickerViewShowing;
	BOOL currencyKeyboardShowing;
	
	CGRect viewFrameCache;
	
	TagSuggesterViewController * tagSuggester;
}

@property (nonatomic, retain) TagSuggesterViewController * tagSuggester;
@property (nonatomic, retain) UIBarButtonItem * saveButton;
@property (nonatomic, retain) UIBarButtonItem * cancelButton;

// Safe keeping values
@property (nonatomic, retain) NSString * transactionDescription;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * autotags;
@property (nonatomic, retain) NSNumber * kroner;
@property (nonatomic, retain) NSNumber * expense;
@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * yearMonth;
@property (nonatomic, retain) NSNumber * day;

@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;

- (IBAction)clearLocationAction;
- (IBAction)amountButtonAction;
- (IBAction)dateButtonAction;
- (IBAction)dateChangedAction;
- (IBAction)expenseIncomeToggleAction;
- (IBAction)didStartEditingField;

- (void)adjustViewSizeWith:(NSInteger)fromNormal andScrollFor:(UIView*)view;
- (void) keyboardCheck;
- (void) setupControls;

#pragma mark
#pragma mark -
#pragma mark TagSuggesterDelegate methods
-(void)addTagWord:(NSString*)tag;
-(IBAction)textChanged;
-(IBAction)startedEditing;
-(IBAction)stoppedEditing;

@end
