//
//  BetaViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 26.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Transaction;

@interface BetaViewController : UIViewController <UIActionSheetDelegate> {
	NSManagedObjectContext * managedObjectContext;
	NSFetchedResultsController * resultsController;
	UIProgressView * progressBar;
	UIButton * addDataButton;
	UIButton * clearDataButton;
	
	Transaction * betaTransaction;
	NSMutableString * currentString;
	BOOL storingCharacters;
	NSInteger numberOfTransactionsAdded;
	
	BOOL run;
}

@property (nonatomic, assign) NSInteger numberOfTransactionsAdded;
@property (nonatomic, assign) BOOL run;

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController * resultsController;

// IBOutlets
@property (nonatomic, retain) IBOutlet UIProgressView * progressBar;
@property (nonatomic, retain) IBOutlet UIButton * addDataButton;
@property (nonatomic, retain) IBOutlet UIButton * clearDataButton;

-(IBAction)addData:(id)sender;
-(IBAction)clearData:(id)sender;
+(void)increaseProgressBar:(BetaViewController*)view;
-(void)sendDataUpdatedNotification;
@end