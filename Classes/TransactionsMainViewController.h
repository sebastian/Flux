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

@interface TransactionsMainViewController : UIViewController <FilterFieldDelegate> {
	UIView * contentView;
	BOOL searchIsVisible;
}

@property (nonatomic, retain) UIView * contentView;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil andContext:(NSManagedObjectContext*)context;

// FilterFieldDelegate methods
- (BOOL)isVisible;
- (void)needExtraSpace;
- (void)finishedUsingExtraSpace;
- (void)wantsToBeShown;
- (void)wantsToBeHidden;
- (void)wantsToBeToggled;
@end
