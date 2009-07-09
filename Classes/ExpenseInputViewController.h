//
//  FirstViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MAX_TEXTFIELD_WIDTH = 180;
static const CGFloat MIN_TEXTFIELD_WIDTH = 40;
static const CGFloat TEXTFIELD_PADDING = 10;

@interface ExpenseInputViewController : UIViewController <UITextFieldDelegate> {
	UITextField * amount;
	UIView * textFieldBackground;
	UIView * addButtonView;
	
	CGRect originalViewFrame;
	CGRect keyboardBounds;
}

@property (nonatomic, retain) IBOutlet UITextField * amount;
@property (nonatomic, retain) IBOutlet UIView * textFieldBackground;
@property (nonatomic, retain) IBOutlet UIView * addButtonView;

-(IBAction)addExpense:(id)sender;

@end
