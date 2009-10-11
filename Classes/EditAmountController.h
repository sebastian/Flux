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

@protocol EditAmountControllerDelegate;

@interface EditAmountController : UIViewController {
	Transaction * _currentTransaction;
	AmountEditor * _amountEditor;
	id <EditAmountControllerDelegate> _delegate;
	NSNumber * _previousAmount;
}
@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, assign) id <EditAmountControllerDelegate> delegate;

- (id) initWithTransaction:(Transaction*)trs;

@end

@protocol EditAmountControllerDelegate
@required
- (void) updateAmount;
@end
