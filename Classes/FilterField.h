//
//  FilterField.h
//  Finance
//
//  Created by Sebastian Probst Eide on 03.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterFieldDelegate
@required
- (void)needExtraSpace;
- (void)finishedUsingExtraSpace;

- (void)wantsToBeShown;
- (void)wantsToBeHidden;
- (void)wantsToBeToggled;

- (BOOL)isVisible;

@optional
- (void)cancelClicked;
@end


@interface FilterField : UIViewController <UISearchBarDelegate> {

	id <FilterFieldDelegate> delegate;
	
	IBOutlet UILabel * filteredTagsField;
	IBOutlet UISearchBar * searchBarField;	
	
	NSArray * tagsToFilterBy;
	NSMutableArray * realTags;
	
}

@property (nonatomic, assign) id <FilterFieldDelegate> delegate;

// Outlets
@property (nonatomic, retain) NSMutableArray * realTags;
@property (nonatomic, retain) UISearchBar * searchBarField;

@property (nonatomic, retain) NSArray * tagsToFilterBy;

// Constructor
+ (FilterField*)sharedFilterBar;

// Methods
- (void)updateFilterByField;
- (void)resignFirstResponder;
- (void)clearSearchState;
- (void)setSearchString:(NSString*)text;
- (NSString*)searchString;
- (BOOL)isVisible;

- (void) hide;
- (void) show;
- (void) toggle;
@end
