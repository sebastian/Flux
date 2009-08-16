//
//  KleioSearchBar.m
//  TokenField
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "KleioSearchBar.h"
#import "Utilities.h"
#import "SearchBarTerm.h"

@implementation KleioSearchBar

static KleioSearchBar * sharedSearchBar = nil;
@synthesize delegate;



#pragma mark
#pragma mark -
#pragma mark Init and teardown
- (void)viewDidLoad {
    [super viewDidLoad];
	searchBarTerm = [[SearchBarTerm alloc] init];
	searchBarTerm.font = searchBarTextField.font;
	bubbleView.term = searchBarTerm;
	bubbleView.font = searchBarTextField.font;
	
	searchBarTextField.placeholder = NSLocalizedString(@"Tags to filter by", @"Placeholder text for search bar");
	[self hide];
}


#pragma mark
#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	NSString * textFieldText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	/* Subtract an additional X because of the clear button */
	if ([textFieldText sizeWithFont:textField.font].width > (textField.frame.size.width - 35)) { return NO; }
	
	[searchBarTerm setText:textFieldText];
	[bubbleView setNeedsDisplay];
	
	// Let the user do whatever he wants.
	return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self resignFirstResponder];
	return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[searchBarTerm clear];
	[bubbleView setNeedsDisplay];
	return YES;
}

#pragma mark
#pragma mark -
#pragma mark Methods that can be externally called
- (void) hide {
	[delegate wantsToBeHidden];
	[bubbleView setNeedsDisplay];
}
- (void) show {
	[delegate wantsToBeShown];
}
- (void) toggle {
	[delegate wantsToBeToggled];
}
- (void) hideButRetainState {
	[delegate wantsToBeHiddenWithoutClearingState];
}
- (void)resignFirstResponder { [searchBarTextField resignFirstResponder]; }
- (void)clearSearchState {
	
	// Clear the search when it is hidden
	searchBarTextField.text = @"";
	[searchBarTerm clear];
	[bubbleView setNeedsDisplay];
	
	// Send out notification that the filtering is over
	NSPredicate * filteringPredicate = [NSPredicate predicateWithValue:YES];
	NSDictionary * predicateDict = [NSDictionary dictionaryWithObject:filteringPredicate 
															   forKey:@"predicate"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KleioPredicateUpdated" 
														object:self 
													  userInfo:predicateDict];
}
- (void)setSearchString:(NSString*)text {
	[searchBarTextField becomeFirstResponder];
	[searchBarTextField setText:text];
	[searchBarTextField resignFirstResponder];
}
- (BOOL)isVisible {
	return [self.delegate isVisible];
}
- (NSString*)searchString {
	return searchBarTextField.text;
}




#pragma mark
#pragma mark -
#pragma mark Assigments
-(void)setDelegate:(id<KleioSearchBarDelegate>)newDelegate {
	[self.view removeFromSuperview];
	delegate = newDelegate;
	[[delegate view] addSubview:self.view];
}



#pragma mark
#pragma mark -
#pragma mark Singleton methods
+ (KleioSearchBar*)searchBar {
    @synchronized(self) {
        if (sharedSearchBar == nil) {
            [[self alloc] initWithNibName:@"KleioSearchBar" bundle:[NSBundle mainBundle]]; // assignment not done here
        }
    }
    return sharedSearchBar;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedSearchBar == nil) {
            sharedSearchBar = [super allocWithZone:zone];
            return sharedSearchBar;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release {
    //do nothing
}
- (id)autorelease{
    return self;
}

- (void)dealloc {
	
	[searchBarTerm release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}


@end
