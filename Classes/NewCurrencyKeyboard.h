//
//  NewCurrencyKeyboard.h
//  Finance
//
//  Created by Sebastian Probst Eide on 03.10.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>

@protocol CurrencyKeyboardDelegate
@required
- (void)numericButtonPressed:(NSInteger)key;
- (void)deleteButtonPressed;
- (void)doubleZeroButtonPressed;
- (CGFloat)viewHeight;
- (UIView*)view;
@end


@interface NewCurrencyKeyboard : UIViewController {

	id <CurrencyKeyboardDelegate> _delegate;

	NSArray * _numericalButtons;
	TTButton * _clearButton;
	
}
@property (nonatomic, assign) id <CurrencyKeyboardDelegate> delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Public methods

// External methods for delegate
//-(void)showKeyboard;
//-(void)hideKeyboard;
//-(void)showKeyboardWithAnimation:(BOOL)animation;
//-(void)hideKeyboardWithAnimation:(BOOL)animation;
//
//-(void)disableClearButton;
//-(void)enableClearButton;
//
//-(void)disableNumericButtons;
//-(void)enableNumericButtons;
//
//-(NSInteger)keyboardHeight;


@end
