//
//  TestViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 02.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "KleioSearchBar.h"

@class TransactionsNavigationController;

@interface TransactionsMainViewController : TTViewController <KleioSearchBarDelegate> {
	UIView * contentView;
	BOOL searchIsVisible;
	
	UIImageView * backgroundImage;
	
	TransactionsNavigationController * navController;
}

@property (nonatomic, retain) UIView * contentView;
@property (nonatomic, retain) TransactionsNavigationController * navController;
@property (nonatomic, retain) IBOutlet UIImageView * backgroundImage;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil;

// KleioSearchBarDelegate methods
- (BOOL)isVisible;
//- (void)needExtraSpace;
//- (void)finishedUsingExtraSpace;
- (void)wantsToBeShown;
- (void)wantsToBeHidden;
- (void)wantsToBeToggled;
@end
