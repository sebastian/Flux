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
-(UIView*)view;
@end


@interface KleioSearchBar : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField * searchBarTextField;
	IBOutlet BubbleView * bubbleView;	
	
	id <KleioSearchBarDelegate> delegate;
	
	SearchBarTerm * searchBarTerm;
}

@property (nonatomic, assign) id <KleioSearchBarDelegate> delegate;

+ (KleioSearchBar*)searchBar;
@end
