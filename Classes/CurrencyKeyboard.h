//
//  CurrencyKeyboard.h
//  Finance
//
//  Created by Sebastian Probst Eide on 22.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CurrencyKeyboardDelegate
@required
- (void)numericButtonPressed:(NSInteger)key;
- (void)deleteButtonPressed;
- (void)doubleZeroButtonPressed;
- (CGFloat)viewHeight;
- (UIView*)view;
@end

@interface CurrencyKeyboard : UIViewController {

	id <CurrencyKeyboardDelegate> delegate;
	
	UIButton * button1;
	UIButton * button2; 
	UIButton * button3;
	UIButton * button4;
	UIButton * button5;
	UIButton * button6;
	UIButton * button7;
	UIButton * button8;
	UIButton * button9;
	UIButton * button0;
	UIButton * buttonClear;
	UIButton * button00;
	
}

// External methods for delegate
-(void)showKeyboard;
-(void)hideKeyboard;
-(void)showKeyboardWithAnimation:(BOOL)animation;
-(void)hideKeyboardWithAnimation:(BOOL)animation;

-(void)disableClearButton;
-(void)enableClearButton;

-(void)disableNumericButtons;
-(void)enableNumericButtons;

-(NSInteger)keyboardHeight;

// IBActions
-(IBAction)numberButtonPushed:(id)sender;
-(IBAction)doubleZeroButtonPushed:(id)sender;
-(IBAction)deleteButtonPushed:(id)sender;

// Delegate
@property (nonatomic, assign) IBOutlet id <CurrencyKeyboardDelegate> delegate;

// Keyboard buttons
@property (nonatomic, retain) IBOutlet UIButton * button1;
@property (nonatomic, retain) IBOutlet UIButton * button2;
@property (nonatomic, retain) IBOutlet UIButton * button3;
@property (nonatomic, retain) IBOutlet UIButton * button4;
@property (nonatomic, retain) IBOutlet UIButton * button5;
@property (nonatomic, retain) IBOutlet UIButton * button6;
@property (nonatomic, retain) IBOutlet UIButton * button7;
@property (nonatomic, retain) IBOutlet UIButton * button8;
@property (nonatomic, retain) IBOutlet UIButton * button9;
@property (nonatomic, retain) IBOutlet UIButton * button0;
@property (nonatomic, retain) IBOutlet UIButton * buttonClear;
@property (nonatomic, retain) IBOutlet UIButton * button00;


@end
