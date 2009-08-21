//
//  DetailContentTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@class Transaction;
@interface DetailContentTableCell : ABTableViewCell {
	NSString * what;
	NSString * amount;
	NSString * time;
}

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * what;
@property (nonatomic, retain) NSString * amount;

// Methods
-(void)configureCellForTransaction:(Transaction*)trs;

@end
