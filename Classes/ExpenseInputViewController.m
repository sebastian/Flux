//
//  FirstViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 08.07.09.
//  Copyright Kle.io 2009. All rights reserved.
//

#import "ExpenseInputViewController.h"

@interface ExpenseInputViewController (Private)
-(void)updateExpenseDisplay;
@end


@implementation ExpenseInputViewController

#pragma mark Synthesized methods
@synthesize amount;
@synthesize textFieldBackground;
@synthesize deleteButtonView;

@synthesize newTransaction;
@synthesize delegate;

#pragma mark
#pragma mark -
#pragma mark Currency keyboard methods

-(IBAction)numberButtonPushed:(UIButton *)button {
	NSLog(@"Pushed the numeric key %i", button.tag);

	NSLog(@"Currenctly the kroner value is %i", [self.newTransaction.kroner integerValue]);
	NSInteger kroner = [self.newTransaction.kroner integerValue] * 10 + button.tag; 
	NSLog(@"New kroner value as calculated: %i", kroner);
	NSLog(@"The value now reads: %@", [self.newTransaction toString]);
	
	[self.newTransaction setKroner:[NSNumber numberWithInt:kroner]];	
	
	[self updateExpenseDisplay];
}
-(IBAction)decimalButtonPushed:(id)sender {
	NSLog(@"Decimal button pushed");
	
}
-(IBAction)deleteButtonPushed:(id)sender {
	NSLog(@"Backspace button pushed");
}

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

	// Is the textfield the amount text field?
	if (textField == amount) {
		UIFont * font = [UIFont fontWithName:@"Helvetica" size:24.0];
		NSString * text = [[textField text] stringByReplacingCharactersInRange:range withString:string];
		CGSize textSize = [text sizeWithFont:font];
		
		NSLog(@"It says the text should take %f size", textSize);
		
		float width = textSize.width + TEXTFIELD_PADDING;
		
		// always make space for at least two characters
		if (width < MIN_TEXTFIELD_WIDTH) {
			width = MIN_TEXTFIELD_WIDTH;
		} else if (width > MAX_TEXTFIELD_WIDTH) {
			width = MAX_TEXTFIELD_WIDTH;
		}
				
		CGRect viewFrame = [textFieldBackground frame];
		viewFrame.size.width = width;
		
		CGRect buttonFrame = [deleteButtonView frame];
		buttonFrame.origin.x = viewFrame.origin.x + width + 8;

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.05];
		
		[textFieldBackground setFrame:viewFrame];
		[deleteButtonView setFrame:buttonFrame];
		
		[UIView commitAnimations];
	}
	
	// We always want the text to change, so return YES
	return YES;
}


#pragma mark
#pragma mark -
#pragma mark Normal methods

-(void)updateExpenseDisplay {
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:24.0];
	NSString * text = [self.newTransaction toString];
	
	CGSize textSize = [text sizeWithFont:font];
	
	NSLog(@"It says the text should take %f size", textSize);
	
	float width = textSize.width + TEXTFIELD_PADDING;
	
	// always make space for at least two characters
	if (width < MIN_TEXTFIELD_WIDTH) {
		width = MIN_TEXTFIELD_WIDTH;
	} else if (width > MAX_TEXTFIELD_WIDTH) {
		width = MAX_TEXTFIELD_WIDTH;
	}
	
	CGRect viewFrame = [textFieldBackground frame];
	viewFrame.size.width = width;
	
	CGRect buttonFrame = [deleteButtonView frame];
	buttonFrame.origin.x = viewFrame.origin.x + width;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.05];
	
	[amount setText:text];
	[textFieldBackground setFrame:viewFrame];
	[deleteButtonView setFrame:buttonFrame];
	
	// Show delete button if there is a value
	if ([[self.newTransaction toString] isEqualToString:@"0,00"]) {
		[deleteButtonView setAlpha:0.0];
	} else {
		[deleteButtonView setAlpha:1.0];
	}
	
	[UIView commitAnimations];
}
-(IBAction)addExpense:(id)sender {
	[amount resignFirstResponder];
}
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

	Transaction *trs = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.delegate.managedObjectContext];
	self.newTransaction = trs;
	[trs release];
	
	[self updateExpenseDisplay];
	
	// Show keyboard
	//[amount becomeFirstResponder];
	

}

#pragma mark
#pragma mark -
#pragma mark Unloading etc

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	deleteButtonView = nil;
	amount = nil;
	textFieldBackground = nil;

	// TODO:
	// Delete somehow?
	newTransaction = nil;
}
- (void)dealloc {
	[newTransaction release];
	[deleteButtonView release];
	[amount release];
	[textFieldBackground release];
    [super dealloc];
}

@end
