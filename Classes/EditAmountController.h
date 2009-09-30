//
//  EditAmountController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 30.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmountEditor;
@class Transaction;

@interface EditAmountController : UIViewController {
	Transaction * _currentTransaction;
	AmountEditor * _amountEditor;
}
@property (nonatomic, retain) Transaction * currentTransaction;

- (id) initWithTransaction:(Transaction*)trs;

@end
