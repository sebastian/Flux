//
//  EditTransaction.h
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Transaction;
@class CurrencyKeyboard;

@interface EditTransaction : UIViewController {
	Transaction * currentTransaction;
	CurrencyKeyboard * currencyKeyboard;
	
	IBOutlet UIView * editView;
	IBOutlet UIScrollView * scrollview;
	
	IBOutlet UILabel * amountLabel;
	IBOutlet UIButton * amountButton;
	IBOutlet UILabel * baseCurrencyAmountLabel;
	
	IBOutlet UILabel * dateLabel;
	IBOutlet UIButton * dateButton;
	
	IBOutlet UILabel * locationLabel;
	IBOutlet UILabel * locationDataLabel;
	IBOutlet UISegmentedControl * locationClearButton;
	
	IBOutlet UILabel * tagsLabel;
	IBOutlet UITextField * tagsField;
	
	IBOutlet UILabel * descriptionLabel;
	IBOutlet UITextView * descriptionView;
	IBOutlet UISegmentedControl * saveButton;
	
}

@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;

- (IBAction)saveAction;

@end
