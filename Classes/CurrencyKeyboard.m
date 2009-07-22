//
//  CurrencyKeyboard.m
//  Finance
//
//  Created by Sebastian Probst Eide on 22.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "CurrencyKeyboard.h"


@implementation CurrencyKeyboard

@synthesize button0, button1, button2, button3, button4, button5, button6, button7, button8, button9;
@synthesize buttonAdd, buttonComma;
@synthesize delegate;

#pragma mark
#pragma mark -
#pragma mark Init

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        NSLog(@"CurrencyKeyboard initialized");
    }
    return self;
}

#pragma mark
#pragma mark -
#pragma mark External methods for delegate

-(void)showKeyboard {
	CGRect keyboardFrame = [self.view frame];
	CGRect delegateFrame = [self.delegate.view frame];
	keyboardFrame.origin.y = delegateFrame.size.height;
	self.view.frame = keyboardFrame;
	[self.delegate.view addSubview:self.view];
	
	// Update the keyboard location
	keyboardFrame.origin.y = delegateFrame.size.height - keyboardFrame.size.height;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.08];
	
	self.view.frame = keyboardFrame;
	
	NSLog(@"Performing animation. Keyboard slide in");
	[UIView commitAnimations];	
}
-(void)hideKeyboard {
	CGRect keyboardFrame = [self.view frame];
	CGRect delegateFrame = [self.delegate.view frame];

	// Hide keyboard
	keyboardFrame.origin.y = delegateFrame.size.height;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.03];
	
	self.view.frame = keyboardFrame;
	
	NSLog(@"Performing animation. Keyboard slide in");
	[UIView commitAnimations];
}
-(void)disableCommaButton {[self.buttonComma setEnabled:NO];}
-(void)enableCommaButton {[self.buttonComma setEnabled:YES];}

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
}	


#pragma mark
#pragma mark -
#pragma mark IBAction with callback to delegate

-(IBAction)numberButtonPushed:(UIButton *)button {
	NSLog(@"Pushed the numeric key %i. Delegate will be notified.", button.tag);
	[self.delegate numericButtonPressed:button.tag];
}
-(IBAction)decimalButtonPushed:(id)sender {
	NSLog(@"Pushed the decimal button. Delegate will be notified.");
	[self.delegate decimalButtonPressed];
}
-(IBAction)okButtonPushed:(id)sender {
	NSLog(@"Pushed the OK button. Delegate will be notified.");		
	[self.delegate okButtonPressed];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload {
	NSLog(@"keyboard unloaded...");
		
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
	buttonAdd = nil;
	buttonComma = nil;
	
}
- (void)dealloc {
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
	[buttonAdd release];
	[buttonComma release];
	
    [super dealloc];
	
	NSLog(@"CurrencyKeyboard deallocated");
}


@end
