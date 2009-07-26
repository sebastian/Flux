//
//  DetailTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailHeaderView : UIView {
	UILabel * date;
	UILabel * amount;
	UILabel * monthYear;
}

@property (nonatomic, retain) IBOutlet UILabel * monthYear;
@property (nonatomic, retain) IBOutlet UILabel * date;
@property (nonatomic, retain) IBOutlet UILabel * amount;

@end
