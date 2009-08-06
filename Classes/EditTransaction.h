//
//  EditTransaction.h
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

@class CurrencyKeyboard;

@interface EditTransaction : UIViewController {
	Transaction * currentTransaction;
	CurrencyKeyboard * currencyKeyboard;
}

@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, retain) CurrencyKeyboard * currencyKeyboard;

@end
