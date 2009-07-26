//
//  TransactionDisplay.m
//  Finance
//
//  Created by Sebastian Probst Eide on 26.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionDisplay.h"
#import "Transaction.h";


@implementation TransactionDisplay

@synthesize currentTransaction;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	mapHidden = YES;
	mapInitialPosition = YES;
	
	NSString * newTitle = NSLocalizedString(@"Show map", @"Show map on transacation detail page button text");
	[moveMapButton setTitle:newTitle forState:UIControlStateNormal];
	[newTitle release];
		
	//
	// Get the map location right
	CLLocationCoordinate2D location;
	location.latitude = [currentTransaction.lat floatValue];
	location.longitude = [currentTransaction.lng floatValue];
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.5;
	span.longitudeDelta = 0.5;
	
	MKCoordinateRegion region;
	region.center = location;
	region.span = span;
	
	[map setRegion:region];
	
	NSLog(@"Showing transaction object: %@", currentTransaction);
	
	// 
	// Set the textual data
	description.text = currentTransaction.transactionDescription;
	when.text = [currentTransaction formattedDate];
	amount.text = [currentTransaction toString];

	// TODO: Make nice bubble tags (display them as bubbles)
	tags.text = [NSLocalizedString(@"tags:", @"Tags for transaction detail page") stringByAppendingFormat:@" %@", currentTransaction.tags];
	
	if ([currentTransaction.expense boolValue] == YES) {
		what.text = NSLocalizedString(@"Expense", @"Transaction detail view. Expense");
	} else {
		what.text = NSLocalizedString(@"Income", @"Transaction detail view. Income");
	}
	
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction)scaleMap:(id)sender {

	// Is it the first time? In that case set up the shift register
	if (mapInitialPosition) {
		
		// Set locations the button and map can hold when expanded
		buttonLocation = moveMapButton.frame;
		buttonLocation.origin.y = -1;
		
		mapLocation = map.frame;
		mapLocation.origin.y = 19;
		mapLocation.size.height = self.view.frame.size.height - 19;
		
		mapInitialPosition = NO;
	}		
	if (mapHidden) {
		NSString * newTitle = NSLocalizedString(@"Hide map", @"Hide map on transacation detail page button text");
		[moveMapButton setTitle:newTitle forState:UIControlStateNormal];
		[newTitle release];
		[moveMapButton setBackgroundImage:[UIImage imageNamed:@"MapButtonTop.png"] forState:UIControlStateNormal];
		mapHidden = NO;
	} else {
		NSString * newTitle = NSLocalizedString(@"Show map", @"Show map on transacation detail page button text");
		[moveMapButton setTitle:newTitle forState:UIControlStateNormal];
		[newTitle release];
		
		[moveMapButton setBackgroundImage:[UIImage imageNamed:@"MapButtonBottom.png"] forState:UIControlStateNormal];
		mapHidden = YES;
	}
	
	
	CGRect currentButtonLocation = moveMapButton.frame;
	CGRect currentMapLocation = map.frame;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.10];
	
	moveMapButton.frame = buttonLocation;
	map.frame = mapLocation;
	
	[UIView commitAnimations];		
	
	buttonLocation = currentButtonLocation;
	mapLocation = currentMapLocation;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[currentTransaction release];
    [super dealloc];
}


@end
