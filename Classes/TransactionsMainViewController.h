//
//  TestViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 02.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FilterField.h"
#import "KleioSearchBar.h"

@class TransactionsNavigationController;

@interface TransactionsMainViewController : UIViewController <FilterFieldDelegate, KleioSearchBarDelegate> {
	UIView * contentView;
	BOOL searchIsVisible;
	
	UIImageView * backgroundImage;
	
	TransactionsNavigationController * navController;
}

@property (nonatomic, retain) UIView * contentView;
@property (nonatomic, retain) TransactionsNavigationController * navController;
@property (nonatomic, retain) IBOutlet UIImageView * backgroundImage;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil andContext:(NSManagedObjectContext*)context;

// FilterFieldDelegate methods
- (BOOL)isVisible;
- (void)needExtraSpace;
- (void)finishedUsingExtraSpace;
- (void)wantsToBeShown;
- (void)wantsToBeHidden;
- (void)wantsToBeToggled;
@end
