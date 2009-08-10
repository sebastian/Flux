//
//  TransactionDisplay.m
//  Finance
//
//  Created by Sebastian Probst Eide on 26.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionDisplay.h"
#import "Transaction.h";
#import "MapAnnotation.h"
#import "EditTransaction.h"
#import "MapFullScreen.h"
#import "CurrencyManager.h"

@interface TransactionDisplay (PrivateMethods)
- (void) edit;
@end


@implementation TransactionDisplay

@synthesize currentTransaction, annotation, region;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Add edit button
	UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
																				 target:self 
																				 action:@selector(edit)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	
	// Get the map location right
	CLLocationCoordinate2D location ;
	location = currentTransaction.location.coordinate;
		
	self.annotation = [[MapAnnotation alloc] initWithTransaction:currentTransaction];
	[map addAnnotation:self.annotation];

	MKCoordinateSpan span;
	span.latitudeDelta = 0.0015;
	
	MKCoordinateRegion theRegion;
	theRegion.center = location;
	theRegion.span = span;
	self.region = theRegion;
	
	[map setRegion:self.region];
	
}
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Set the textual data
	description.text = currentTransaction.transactionDescription;
	when.text = [currentTransaction formattedDate];
	amount.text = [currentTransaction amountInLocalCurrency];
	
	// Add in base currency if different
	if (![currentTransaction.currency isEqualToString:[[CurrencyManager sharedManager] baseCurrency]]) {
		amount.text = [amount.text stringByAppendingFormat:@" (%@)", [currentTransaction amountInBaseCurrency]];
	}
	
	self.title = currentTransaction.transactionDescription;
	if ([currentTransaction.transactionDescription isEqualToString:@""]) {
		self.title = NSLocalizedString(@"Details", @"Header for Transaction Detail page");
	}
	
	// TODO: Make nice bubble tags (display them as bubbles)
	tags.text = [NSLocalizedString(@"tags:", @"Tags for transaction detail page") stringByAppendingFormat:@" %@", currentTransaction.tags];
	
	if ([currentTransaction.expense boolValue] == YES) {
		what.text = NSLocalizedString(@"Expense", @"Transaction detail view. Expense");
	} else {
		what.text = NSLocalizedString(@"Income", @"Transaction detail view. Income");
	}
	
	
}
- (void)viewDidUnload {
	map = nil;
}
- (void)dealloc {
	[currentTransaction release];
	[annotation release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning {
    NSLog(@"Did receive memory warning in %@", self);
	[super didReceiveMemoryWarning];
}

// Display map in full screen
-(IBAction)scaleMap:(id)sender {

	MapFullScreen * bigMap = [[MapFullScreen alloc] initWithNibName:@"MapFullScreen" bundle:[NSBundle mainBundle]];
	bigMap.annotation = self.annotation;
	bigMap.region = self.region;

	[self.navigationController pushViewController:bigMap animated:YES];
	[bigMap release];
}

// edit view
- (void) edit {

	EditTransaction * editController = [[EditTransaction alloc] initWithNibName:@"EditTransaction" bundle:[NSBundle mainBundle]];
	editController.currentTransaction = self.currentTransaction;
	[self.navigationController pushViewController:editController animated:YES];
	[editController	release];
	
}




@end
