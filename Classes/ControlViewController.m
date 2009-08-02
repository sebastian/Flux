//
//  ControlViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 31.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "ControlViewController.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

#define kleioExpenseSelectedSegment 0
#define kleioIncomeSelectedSegment 1

@interface ControlViewController (Private)
-(void)animateTo:(CGRect)frame;
-(void)startAnimation;
-(void)stopAnimation;
-(void)animateIn;
-(void)animateOut;

@end


@implementation ControlViewController

@synthesize delegate;

#pragma mark
#pragma mark -
#pragma mark Init, setup and teardown
- (id) initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle;
{
	self = [super initWithNibName:nibName bundle:bundle];
	if (self != nil) {
		// Anything to do?
	}
	return self;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	/* 
	 Reigstering for show and hide events
	 of the different keyboards so that it scales up and down
	 apropriately
	 */
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	// Apple keyboards
	[center
		addObserver:self
		selector:@selector(appleKeyboardShow:)
		name:UIKeyboardWillShowNotification
		object:nil];

	[center
		addObserver:self
		selector:@selector(keyboardHides:)
		name:UIKeyboardWillHideNotification
		object:nil];

	// Register for notification of showing and hiding of currency keyboard
	[center
		addObserver:self
		selector:@selector(currencyKeyboardShow:)
		name:@"CurrencyKeyboardWillShow"
		object:nil];

	[center
		addObserver:self
		selector:@selector(keyboardHides:)
		name:@"CurrencyKeyboardWillHide"
		object:nil];
	
	// Setup right names and titles
	addButton.titleLabel.text = NSLocalizedString(@"Add", @"Add button");
	whatButton.titleLabel.text = NSLocalizedString(@"What", @"What button");
	
	addActive.hidden = YES;
	addPulse.hidden = YES;
	whatActive.hidden = YES;
	
	addButton.enabled = NO;
}
- (void)viewDidUnload {
	// Unregister from the listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	delegate = nil;
	
	[self stopAnimation];
}
- (void)dealloc {
	[super dealloc];
}


#pragma mark
#pragma mark -
#pragma mark Keyboard hiding and showing. Message responders
-(void)appleKeyboardShow:(NSNotification*)notification {
		
	int screenHeight = 480 - 20; // Have to cheat on the size
	
	// Calculate the keyboard height
	NSDictionary*  dict = notification.userInfo;
    NSValue*       nval = [dict objectForKey:UIKeyboardBoundsUserInfoKey];
    CGRect         rect = CGRectZero;
    	
    [nval getValue:&rect];

	int appleKeyboardHeight = rect.size.height;
	
	// Set new frame location
	CGRect frame = self.view.frame;
	frame.origin.y = screenHeight - appleKeyboardHeight - frame.size.height;
	
	[self animateTo:frame];
}
-(void)currencyKeyboardShow:(NSNotification*)notification {
	
	NSDictionary * dict = notification.userInfo;
	NSNumber * keyboardHeight = [dict objectForKey:@"height"];
	
	CGRect parentViewFrame = delegate.view.frame;
	CGRect frame = self.view.frame;
	// Set new frame location
	frame.origin.y = parentViewFrame.size.height - frame.size.height - [keyboardHeight intValue];
	
	[self animateTo:frame];
}
-(void)animateTo:(CGRect)frame {

	frame.origin.y = frame.origin.y + 60;
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[Utilities toolbox] keyboardAnimationDuration]];
    
	self.view.frame = frame;
    
    [UIView commitAnimations];
}
-(void)keyboardHides:(NSNotification*)notification {
	
	/*
	 The only thing we have to do now is move the controller 
	 down to the bottom of the screen!
	 */
	
	CGRect parentViewFrame = delegate.view.frame;
	CGRect frame = self.view.frame;
	// Set new frame location
	frame.origin.y = parentViewFrame.size.height - frame.size.height;
	
	// We don't need the hide action actually. So we don't activate the animation...
	//[self animateTo:frame];
}


#pragma mark
#pragma mark -
#pragma mark Animators
-(void)startAnimation {
	// Start animation unless it is already animating
	if (animateOKButton) {return;}

	animateOKButton = YES;
	[self 
	 performSelector:@selector(animateOut)
	 withObject:nil
	 afterDelay:0.0];
}
-(void)stopAnimation {
	animateOKButton = NO;
}

-(void)animateIn {
	if (animateOKButton == NO) {return;}
	
	addPulse.hidden = NO;
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:1.0];
	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];	
	
	[self 
	 performSelector:@selector(animateOut)
	 withObject:nil
	 afterDelay:3.0];
	
}
-(void)animateOut {
	if (animateOKButton == NO) {return;}
	
	addPulse.hidden = YES;
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:1.0];
	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];	
	
	[self 
	 performSelector:@selector(animateIn)
	 withObject:nil
	 afterDelay:3.0];
}

#pragma mark
#pragma mark -
#pragma mark Methods
-(void)addControlBar {
	
	// Add the view to the bottom of the delegate view
	CGRect parentFrame = delegate.view.frame;
	CGRect myFrame = self.view.frame;
	myFrame.origin.y = parentFrame.size.height - myFrame.size.height;
	self.view.frame = myFrame;
	
	[delegate.view addSubview:self.view];
	
}	
-(void)enableAddButton {
	addActive.hidden = NO;
	addButton.enabled = YES;
	[self startAnimation];
}
-(void)disableAddButton {
	[self stopAnimation];
	addActive.hidden = YES;
	addPulse.hidden = YES;
	addButton.enabled = NO;
}
-(void)setSelectExpenseIncomeSegment:(NSInteger)segment {
	switch (segment) {
		case kleioIncomeSelectedSegment:
			[expenseIncomeControl setSelectedSegmentIndex:segment];
			break;
		case kleioExpenseSelectedSegment:
			[expenseIncomeControl setSelectedSegmentIndex:segment];
			break;
		default:
			NSLog(@"Illegal segment chosen");
			break;
	}	
}

#pragma mark
#pragma mark -
#pragma mark IBAction's
-(IBAction)addAction {
	[delegate addButtonPushed];
}
-(IBAction)whatAction {
	whatActive.hidden = !whatActive.hidden;
	[delegate whatButtonPushed];
}
-(IBAction)expenseIncomeAction {
	if ([expenseIncomeControl selectedSegmentIndex] == kleioIncomeSelectedSegment) {
		[delegate expenseIncomeSetToExpense:NO];
	} else if ([expenseIncomeControl selectedSegmentIndex] == kleioExpenseSelectedSegment) {
		[delegate expenseIncomeSetToExpense:YES];
	} else {
		NSLog(@"Nonexistent segment selected in Expense/Income toggle");
	}
}

@end
