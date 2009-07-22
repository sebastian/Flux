//
//  DetailContentTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailContentTableCell : UITableViewCell {
	UILabel * what;
	UILabel * amount;
	
	UIColor * amountBackgroundColor;
}

@property (nonatomic, retain) IBOutlet UILabel * what;
@property (nonatomic, retain) IBOutlet UILabel * amount;

@property (nonatomic, retain) UIColor * amountBackgroundColor;

-(void)setBackgroundColorForCellNumber:(NSInteger)number;

@end
