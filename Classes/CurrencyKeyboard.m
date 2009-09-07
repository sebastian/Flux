//
//  CurrencyKeyboard.m
//  Finance
//
//  Created by Sebastian Probst Eide on 22.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "CurrencyKeyboard.h"
#import "Utilities.h"

@interface CurrencyKeyboard (Private)
-(void)moveKeyboardTo:(CGRect)keyboardFrame animated:(BOOL)animation;
-(void)startAnimation;
-(void)stopAnimation;
@end


@implementation CurrencyKeyboard

@synthesize button0, button1, button2, button3, button4, button5, button6, button7, button8, button9;
@synthesize buttonClear, button00;
@synthesize delegate;

#pragma mark
#pragma mark -
#pragma mark Init

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}
- (id) init {
	if (self = [super initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]]) {
	}
	return self;
}

#pragma mark
#pragma mark -
#pragma mark External methods for delegate

- (void)setDelegate:(id<CurrencyKeyboardDelegate>)_delegate {
	if (delegate != _delegate) {
		// Remove view from old delegate
		[self.view removeFromSuperview];
		
		// Assign new delegate
		delegate = _delegate;
		
		// Add myself to its view
		[delegate.view addSubview:self.view];	
		[delegate.view bringSubviewToFront:self.view];
	}
}

-(void)showKeyboard {
	[self showKeyboardWithAnimation:NO];
}
-(void)hideKeyboard {
	[self hideKeyboardWithAnimation:NO];
}
-(void)showKeyboardWithAnimation:(BOOL)animation {

	// Send notification
	NSNumber * height = [NSNumber numberWithInt:self.view.frame.size.height];
	NSDictionary * dict = [NSDictionary dictionaryWithObject:height forKey:@"height"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyKeyboardWillShow" object:self userInfo:dict];
	
	CGRect keyboardFrame = [self.view frame];
	CGRect delegateFrame = [self.delegate.view frame];
	delegateFrame.size.height = [delegate viewHeight];
	keyboardFrame.origin.y = delegateFrame.size.height;
	self.view.frame = keyboardFrame;
	
	// Update the keyboard location
	keyboardFrame.origin.y = [delegate viewHeight] - keyboardFrame.size.height; //delegateFrame.size.height - keyboardFrame.size.height;
	
	[delegate.view bringSubviewToFront:self.view];
	
	[self moveKeyboardTo:keyboardFrame animated:animation];
}
-(void)hideKeyboardWithAnimation:(BOOL)animation {
		
	// Send notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyKeyboardWillHide" object:self];
	
	CGRect keyboardFrame = [self.view frame];
	CGRect delegateFrame = [self.delegate.view frame];
	
	// Hide keyboard
	keyboardFrame.origin.y = delegateFrame.size.height;
	
	[self moveKeyboardTo:keyboardFrame animated:animation];

}
-(void)moveKeyboardTo:(CGRect)keyboardFrame animated:(BOOL)animation {

	if (animation) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:[[Utilities toolbox] keyboardAnimationDuration]];
		
		self.view.frame = keyboardFrame;
		
		[UIView commitAnimations];		
		
	} else {
		self.view.frame = keyboardFrame;
		
	}	
	
}

/*
 Disabling and enabling of keyboard buttons
 */
-(void)disableClearButton {[self.buttonClear setEnabled:NO];}
-(void)enableClearButton {[self.buttonClear setEnabled:YES];}

-(void)disableNumericButtons {
	[button0 setEnabled:NO];
	[button1 setEnabled:NO];
	[button2 setEnabled:NO];
	[button3 setEnabled:NO];
	[button4 setEnabled:NO];
	[button5 setEnabled:NO];
	[button6 setEnabled:NO];
	[button7 setEnabled:NO];
	[button8 setEnabled:NO];
	[button9 setEnabled:NO];	
	[button00 setEnabled:NO];
}
-(void)enableNumericButtons {
	[button0 setEnabled:YES];
	[button1 setEnabled:YES];
	[button2 setEnabled:YES];
	[button3 setEnabled:YES];
	[button4 setEnabled:YES];
	[button5 setEnabled:YES];
	[button6 setEnabled:YES];
	[button7 setEnabled:YES];
	[button8 setEnabled:YES];
	[button9 setEnabled:YES];	
	[button00 setEnabled:YES];
}	

#pragma mark
#pragma mark -
#pragma mark Misc
-(NSInteger)keyboardHeight {
	return self.view.frame.size.height;
}


#pragma mark
#pragma mark -
#pragma mark IBAction with callback to delegate

-(IBAction)numberButtonPushed:(UIButton *)button {
	[self.delegate numericButtonPressed:button.tag];
}
-(IBAction)doubleZeroButtonPushed:(id)sender {
	[self.delegate doubleZeroButtonPressed];
}
-(IBAction)deleteButtonPushed:(id)sender {
	[self.delegate deleteButtonPressed];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload {
		
	button0 = nil;
	button1 = nil;
	button2 = nil;
	button3 = nil;
	button4 = nil;
	button5 = nil;
	button6 = nil;
	button7 = nil;
	button8 = nil;
	button9 = nil;
	buttonClear = nil;
	button00 = nil;
	
}
- (void)dealloc {
	self.delegate = nil;
	[button0 release];
	[button1 release];
	[button2 release];
	[button3 release];
	[button4 release];
	[button5 release];
	[button6 release];
	[button7 release];
	[button8 release];
	[button9 release];
	[buttonClear release];
	[button00 release];
	
    [super dealloc];
	
}


@end
