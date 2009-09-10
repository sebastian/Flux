//
//  TransactionsViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TransactionsNavigationController : UINavigationController <UINavigationControllerDelegate>
{
	NSManagedObjectContext *managedObjectContext;
	
	UIImageView * backgroundImageView;
}

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

- (void)objectContextUpdated:(NSNotification *)notification;

@end
