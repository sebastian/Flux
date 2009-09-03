//
//  DetailTableCell.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailHeaderView : UIView {
	NSString * date;
	NSString * amount;
	NSString * monthYear;
}

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * amount;
@property (nonatomic, retain) NSString * monthYear;

- (void) setDate:(NSString*)_date amount:(NSString*)_amount andMonthYear:(NSString*)_monthYear;

@end
