//
//  EditAmountController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 30.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>

@class Transaction;
@class DateLabel;

@protocol EditDateControllerDelegate;

@interface EditDateController : UIViewController {
	Transaction * _currentTransaction;
	DateLabel * _dateLabel;
	UIDatePicker * _datePicker;
	
	id <EditDateControllerDelegate> _delegate;
}
@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, assign) id <EditDateControllerDelegate> delegate;

- (id) initWithTransaction:(Transaction*)trs;

@end

@protocol EditDateControllerDelegate
- (void) updateDate;
@end
