//
//  KleioSearchBar.h
//  TokenField
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleView.h"

@class SearchBarTerm;

@protocol KleioSearchBarDelegate
@required
-(UIView*)view;

- (void)wantsToBeShown;
- (void)wantsToBeHidden;
- (void)wantsToBeHiddenWithoutClearingState;
- (void)wantsToBeToggled;

- (BOOL)isVisible;

@optional
- (void)cancelClicked;
@end


@interface KleioSearchBar : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField * searchBarTextField;
	IBOutlet BubbleView * bubbleView;	
	
	id <KleioSearchBarDelegate> delegate;
	
	SearchBarTerm * searchBarTerm;
}

@property (nonatomic, assign) id <KleioSearchBarDelegate> delegate;

#pragma mark
#pragma mark -
#pragma mark Public API
#pragma mark
#pragma mark -
#pragma mark Methods that can be externally called
- (void) hide;
- (void) show;
- (void) toggle;
- (void) hideButRetainState;
- (void)resignFirstResponder;
- (void)clearSearchState;
- (void)setSearchString:(NSString*)text;
- (BOOL)isVisible;
- (NSString*)searchString;

+ (KleioSearchBar*)searchBar;
@end
