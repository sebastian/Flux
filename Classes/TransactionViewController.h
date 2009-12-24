//
//  TransactionViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "TagSelector.h"
#import <MapKit/MapKit.h>
#import "EditAmountController.h"
#import "EditDateController.h"

@class Transaction;
@class KleioTagCluster;
@class ItemView;

@interface TransactionViewController : TTViewController <TagSelectorDelegate, TTPostControllerDelegate, MKReverseGeocoderDelegate, EditAmountControllerDelegate, EditDateControllerDelegate, UIActionSheetDelegate > {
	Transaction * _currentTransaction;

	ItemView * _tags;
	ItemView * _dateItem;
	ItemView * _locationItem;
	ItemView * _descriptionItem;
	ItemView * _amountItem;
	
	TTButton * _descriptionButton;
}

@property (nonatomic, retain) Transaction * currentTransaction;

- (id) initWithSection:(NSString*)_section andRow:(NSString*)_row;

@end
