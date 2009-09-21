//
//  DetailContentTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "ABTableViewCell.h"

@class Transaction;
@interface DetailContentTableCell : ABTableViewCell {
	TTStyledTextLabel * what;
	NSString * amount;
	NSString * time;
	NSArray * tags;
	
	// Positions
	CGPoint topCorner;
	CGRect cellSepRect;
	CGRect amountFrame;
	CGPoint timeStartPoint;
}

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) TTStyledTextLabel * what;
@property (nonatomic, retain) NSString * amount;
@property (nonatomic, retain) NSArray * tags;

// Methods
-(void)configureCellForTransaction:(Transaction*)trs;

@end
