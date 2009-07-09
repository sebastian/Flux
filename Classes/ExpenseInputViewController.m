//
//  FirstViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "ExpenseInputViewController.h"

@interface ExpenseInputViewController (Private)
-(void)moveTabBarUp;
@end



@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amount;

#pragma mark
#pragma mark -
#pragma mark TextFieldDelegegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	CGRect screen = [[UIScreen mainScreen] bounds];
	
	CGRect viewFrame = self.view.window.frame;
	
	// Save it for easy reverting
	originalViewFrame = viewFrame;
	
	// Adjust the size
	viewFrame.size.height = screen.size.height - keyboardBounds.size.height;
		
	// Move the frame
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
		
	[self.view.window setFrame:viewFrame];

	[UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
	// Revert the scaling :)
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view.window setFrame:originalViewFrame];
    
    [UIView commitAnimations];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	// We always want the text to change, so return YES
	return YES;
}


#pragma mark
#pragma mark -
#pragma mark Normal methods

- (void)keyboardNotification:(NSNotification*)notification {  
    NSDictionary *userInfo = [notification userInfo];  
    NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];  
    [keyboardBoundsValue getValue:&keyboardBounds];  
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self  
											 selector:@selector(keyboardNotification:)  
												 name:UIKeyboardWillShowNotification  
											   object:nil]; 
		
	// Show keyboard
	[amount becomeFirstResponder];
	

}

#pragma mark
#pragma mark -
#pragma mark Unloading etc

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	amount = nil;
}
- (void)dealloc {
	[amount release];
    [super dealloc];
}

@end
