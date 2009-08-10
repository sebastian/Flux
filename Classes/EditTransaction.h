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
	
	IBOutlet UILabel * amountLabel;
	IBOutlet UILabel * tagsLabel;
	IBOutlet UILabel * descriptionLabel;
	IBOutlet UILabel * dateLabel;
	IBOutlet UILabel * locationLabel;
	
	IBOutlet UITextField * amountField;
	IBOutlet UITextField * tagsField;
	IBOutlet UITextField * descriptionField;
	IBOutlet UITextField * dateField;
	IBOutlet UITextField * locationField;
	
	IBOutlet UIButton * saveButton;
}

@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;

- (IBAction)saveAction;

@end
