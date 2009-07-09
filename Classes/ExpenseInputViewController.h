//
//  FirstViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;

@interface ExpenseInputViewController : UIViewController <UITextViewDelegate> {
	UITextField * amount;
	
	CGRect originalViewFrame;
	CGRect keyboardBounds;
}

@property (nonatomic, retain) IBOutlet UITextField * amount;

@end
