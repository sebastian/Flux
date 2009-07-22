//
//  CurrencyKeyboard.h
//  Finance
//
//  Created by Sebastian Probst Eide on 22.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrencyKeyboardDelegateProtocol.h"


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
	UIButton * buttonAdd;
	UIButton * buttonComma;
	
}

// External methods for delegate
-(void)showKeyboard;
-(void)hideKeyboard;

-(void)disableCommaButton;
-(void)enableCommaButton;

-(void)disableNumericButtons;
-(void)enableNumericButtons;


// IBActions
-(IBAction)numberButtonPushed:(id)sender;
-(IBAction)decimalButtonPushed:(id)sender;
-(IBAction)okButtonPushed:(id)sender;

// Delegate
@property (nonatomic, retain) IBOutlet id <CurrencyKeyboardDelegate> delegate;

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
@property (nonatomic, retain) IBOutlet UIButton * buttonAdd;
@property (nonatomic, retain) IBOutlet UIButton * buttonComma;


@end
