//
//  EditAmountController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 30.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "EditDateController.h"
#import "Utilities.h"
#import "Transaction.h"

@interface DateLabel : TTView {
	NSString * _dateText;
	Transaction * _currentTransaction;
}
@property (nonatomic, retain) Transaction * currentTransaction;

@end

@implementation DateLabel
@synthesize currentTransaction = _currentTransaction;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (void) updateText {
	[_dateText release];
	_dateText = [[_currentTransaction longFormattedDate] retain];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.style = TTSTYLEVAR(amountFieldStyle);

		_dateText = nil;
	}
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_currentTransaction);
	TT_RELEASE_SAFELY(_dateText);
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Puclib

- (void) setNeedsDisplay {
	[self updateText];
	[super setNeedsDisplay];
}

- (void)drawContent:(CGRect)rect {
	
	if (_dateText == nil) {[self updateText];}
	
	int padding = 20;
	CGRect frame = self.frame;
	frame.size.width = frame.size.width - 2 * padding;
	frame.size.height = frame.size.height - 2 * padding;
	frame.origin.x = padding;
	frame.origin.y = padding;
	
	UIFont * font = [UIFont systemFontOfSize:50];
	
	CGPoint textPoint = CGPointMake(padding, padding);
	CGSize textSize = [_dateText sizeWithFont:font];
	
	if (textSize.width < frame.size.width) {
		textPoint.x = padding + frame.size.width - textSize.width;
	} else {
		textSize.width = frame.size.width;
	}
	
	[[UIColor whiteColor] set];
	
	[_dateText drawAtPoint:textPoint 
							forWidth:textSize.width
							withFont:font
					 minFontSize:12.f 
				actualFontSize:nil
				 lineBreakMode:UILineBreakModeHeadTruncation 
		baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation EditDateController

@synthesize currentTransaction = _currentTransaction, delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

-(void) changedDate:(UIDatePicker*)sender {
	_currentTransaction.date = sender.date;
	[_dateLabel setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithTransaction:(Transaction*)trs {
	if (self = [super init]) {
		_currentTransaction = [trs retain];
		_delegate = nil;
	}
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_currentTransaction);
	TT_RELEASE_SAFELY(_dateLabel);
	TT_RELEASE_SAFELY(_datePicker);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void)loadView {
	[super loadView];

	self.view.frame = TTToolbarNavigationFrame();
	
	// Buttons
	UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = saveButton;
	
	[cancelButton release];
	[saveButton release];
	
	_dateLabel = [[DateLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];
	_dateLabel.currentTransaction = _currentTransaction;
	[self.view addSubview:_dateLabel];
	
	_datePicker = [[UIDatePicker alloc] init];
	_datePicker.date = _currentTransaction.date;
	_datePicker.datePickerMode = UIDatePickerModeDateAndTime;
	[_datePicker addTarget:self action:@selector(changedDate:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_datePicker];
	
	_datePicker.bottom = self.view.bottom;
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	BarButtonItemButton actions

- (void) dismiss {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) save {
	[[Utilities toolbox] save:_currentTransaction.managedObjectContext];
	[_delegate updateDate];
	[self dismiss];
}

- (void) cancel {
	[self dismiss];
}




@end
