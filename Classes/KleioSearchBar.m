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
}


#pragma mark
#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	NSString * textFieldText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if ([textFieldText sizeWithFont:textField.font].width > (textField.frame.size.width)) { return NO; }
	
	[searchBarTerm setText:textFieldText];
	[bubbleView setNeedsDisplay];
	
	// Let the user do whatever he wants.
	return YES;
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
