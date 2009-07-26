//
//  TransactionsViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionsViewController.h"
#import "OverviewTableViewController.h"

@implementation TransactionsViewController

@synthesize managedObjectContext;

-(id)initWithContext:(NSManagedObjectContext*)context {
	
	OverviewTableViewController * overviewController = 
	[[[OverviewTableViewController alloc] initWithStyle:UITableViewStylePlain 
											 andContext:context] autorelease];
	
	self = [super initWithRootViewController:overviewController];
	if (self != nil) {	
		self.navigationBar.barStyle = UIBarStyleBlackOpaque;
		self.managedObjectContext = context;
		self.title = NSLocalizedString(@"Transactions", @"Transaction table view header");
	}
	return self;
}

- (void)dealloc {
	[managedObjectContext release];
    [super dealloc];
}


@end
