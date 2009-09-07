//
//  TagController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmountController.h"

@interface TagController : UIViewController {
	AmountController * delegate;
	
	IBOutlet UISegmentedControl * saveButton;
	IBOutlet UISegmentedControl * backButton;
}
@property (nonatomic, assign) AmountController * delegate;

- (IBAction) saveTransaction;
- (IBAction) cancel;


@end
