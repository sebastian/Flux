//
//  TestViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 02.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionsMainViewController.h"
#import "TransactionsNavigationController.h"
#import "Utilities.h"

@interface TransactionsMainViewController (PrivateMethods)
-(void)moveMainContentDown:(BOOL)down;
-(void)animateContentToFrame:(CGRect)frame;
-(void)hideSearch;
-(void)showSearch;
-(void)toggleSearch;
@end



@implementation TransactionsMainViewController

@synthesize contentView;

#pragma mark
#pragma mark -
#pragma mark Setup init and teardown
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andContext:(NSManagedObjectContext*)context {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		TransactionsNavigationController * transactionViewController = [[TransactionsNavigationController alloc] initWithContext:context];
		self.contentView = transactionViewController.view;
		
		// Register as the delegate of the filter field
		[[FilterField sharedFilterBar] setDelegate:self];
		
		// Add the filter field to the view
		[self.view addSubview:[FilterField sharedFilterBar].view];
		
		// Add the contentview to the subview
		[self.view addSubview:self.contentView];
		
		self.title = NSLocalizedString(@"Transactions",@"Tab bar title");
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self showSearch];
	
	[[FilterField sharedFilterBar] updateFilterByField];
}
-(void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
	[contentView release];

    [super dealloc];
}

// Move the main content in or out of view
-(void)moveMainContentDown:(BOOL)down {
	
	CGRect frame = self.contentView.frame;
	
	if (down == YES) {
		frame.origin.y = 70;
	} else {
		frame.origin.y = 44;
	}
	
	NSLog(@"Moving content to: %i", frame.origin.y);
	
	[self animateContentToFrame:frame];
}
-(void)animateContentToFrame:(CGRect)frame {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[Utilities toolbox] keyboardAnimationDuration]];
	self.contentView.frame = frame;
    [UIView commitAnimations];	
}
-(void)hideSearch {
			
	searchIsVisible = NO;
	
	[[FilterField sharedFilterBar] resignFirstResponder];
	
	CGRect frame = self.contentView.frame;
	frame.origin.y = 0;
	[self animateContentToFrame:frame];
	
	[[FilterField sharedFilterBar] clearSearchState];
			
}
-(void)showSearch {
	
	searchIsVisible = YES;
	
	CGRect frame = self.contentView.frame;
	frame.origin.y = 44;
	
	[self animateContentToFrame:frame];	
	
	[[FilterField sharedFilterBar] updateFilterByField];
	
}
-(void)toggleSearch {
	if (searchIsVisible) {
		[self hideSearch];
	} else {
		[self showSearch];
	}
}
-(void)hideSearch:(NSNotification*)notification {
	[self hideSearch];
}
-(void)showSearch:(NSNotification*)notification {

	if (notification != nil) {
		// Check if there is something of interest in the notification:
		
		//F.ex a search string
		NSString * searchString = [notification.userInfo objectForKey:@"searchString"];
		if (searchString != nil) {
			// There was a search string, use it! :)
			[[FilterField sharedFilterBar] setSearchString:searchString];
		}
	}
	
	[self showSearch];
}

#pragma mark
#pragma mark -
#pragma mark FilterFieldDelegate methods
- (BOOL)isVisible {
	return searchIsVisible;
}
- (void)needExtraSpace {
	[self moveMainContentDown:YES];
}
- (void)finishedUsingExtraSpace {
	[self moveMainContentDown:NO];
}
- (void)wantsToBeShown {
	[self showSearch];
}
- (void)wantsToBeHidden {
	[self hideSearch];
}
- (void)wantsToBeToggled {
	[self toggleSearch];
}
@end
