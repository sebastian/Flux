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
		[[OverviewTableViewController alloc] initWithStyle:UITableViewStylePlain andContext:context];
	self = [super initWithRootViewController:overviewController];
	[overviewController release];
	
	if (self != nil) {	
		self.navigationBar.barStyle = UIBarStyleBlackOpaque;
		self.managedObjectContext = context;
		self.title = NSLocalizedString(@"Transactions", @"Transaction table view header");
	}
	
	return self;
}

-(void)viewDidLoad {
	[super viewDidLoad];
		
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(objectContextUpdated:)
	 name:NSManagedObjectContextDidSaveNotification
	 object:nil];
	
}
-(void)viewDidUnload {
	// Remove as observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidUnload];
}

- (void)objectContextUpdated:(NSNotification *)notification {
	NSLog(@"merging new changes into the managedObjectContext");
	[managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

- (void)dealloc {
	self.managedObjectContext = nil; // release
    [super dealloc];
}

@end
