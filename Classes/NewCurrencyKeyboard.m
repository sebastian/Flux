//
//  NewCurrencyKeyboard.m
//  Finance
//
//  Created by Sebastian Probst Eide on 03.10.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "NewCurrencyKeyboard.h"
#import "KleioCustomStyles.h"

@implementation NewCurrencyKeyboard

@synthesize delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (void) layout {
	
	TTFlowLayout * layout = [[TTFlowLayout alloc] init];
	layout.spacing = 3;
	layout.padding = 5;
	[layout layoutSubviews:self.view.subviews forView:self.view];
	[layout release];
	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
	}
	return self;
}

- (void) dealloc {
	
	TT_RELEASE_SAFELY(_clearButton);
	TT_RELEASE_SAFELY(_numericalButtons);
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void) loadView {
	[super loadView];
	
	_numericalButtons = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:

																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"1"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"2"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"3"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"4"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"5"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"6"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"7"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"8"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"9"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"00"],
																											[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"0"],
																											nil]];
	
	_clearButton = [[TTButton buttonWithStyle:@"numericKeyboardButton:" title:@"C"] retain];

	for (TTButton * button in _numericalButtons) {
		button.width = 100;
		button.height = 40;
		[button addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Button actions

- (void) buttonPushed:(TTButton*)sender {
	NSLog(@"Button pushed: %@", sender);
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Public

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
//-(NSInteger)keyboardHeight {
//	return self.view.height;
//}


@end
