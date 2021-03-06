//
//  EditAmountController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 30.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "EditAmountController.h"
#import "AmountEditor.h"
#import "Utilities.h"
#import "Transaction.h"

@implementation EditAmountController

@synthesize currentTransaction = _currentTransaction, delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithTransaction:(Transaction*)trs {
	if (self = [super init]) {
		_currentTransaction = [trs retain];
		_previousAmount = [_currentTransaction.kroner retain];
		_delegate = nil;
	}
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_previousAmount);
	TT_RELEASE_SAFELY(_currentTransaction);
	TT_RELEASE_SAFELY(_amountEditor);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void)loadView {
	[super loadView];
	
	// Buttons
	UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = saveButton;
	
	[cancelButton release];
	[saveButton release];
	
	// Interface
	_amountEditor = [[AmountEditor alloc] init];
	_amountEditor.delegate = self;
	_amountEditor.currentTransaction = self.currentTransaction;
	[self.view addSubview:_amountEditor.view];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	BarButtonItemButton actions

- (void) dismiss {
	[self removeFromSupercontrollerAnimated:YES];
}

- (void) save {
	[[Utilities toolbox] save:_currentTransaction.managedObjectContext];
	[_delegate updateAmount];
	[self dismiss];
}

- (void) cancel {
	_currentTransaction.kroner = _previousAmount;
	[self dismiss];
}




@end
