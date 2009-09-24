//
//  TransactionViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "TagSelector.h"

@class Transaction;
@class KleioTagCluster;
@class ItemView;

@interface TransactionViewController : TTViewController <TagSelectorDelegate, TTPostControllerDelegate> {
	Transaction * _currentTransaction;

	ItemView * _tags;
	ItemView * _dateItem;
	ItemView * _locationItem;
	ItemView * _descriptionItem;
	
	TTButton * _descriptionButton;
}

@property (nonatomic, retain) Transaction * currentTransaction;

@end
