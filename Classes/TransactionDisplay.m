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


@implementation TransactionDisplay

@synthesize currentTransaction;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//
	// Setup the view
	mapHidden = YES;
	mapInitialPosition = YES;
	
	NSString * newTitle = NSLocalizedString(@"Show map", @"Show map on transacation detail page button text");
	[moveMapButton setTitle:newTitle forState:UIControlStateNormal];
		

	//
	// Get the map location right
	CLLocationCoordinate2D location ;
	location = currentTransaction.location.coordinate;
	NSLog(@"The transactions location: %@", currentTransaction.location);
	
	
	// FIXME: Is this really needed here? Prob not...
	// Get geocoder
//	geoCoder=[[MKReverseGeocoder alloc] initWithCoordinate:currentTransaction.location.coordinate];
//	geoCoder.delegate=self;
//	[geoCoder start];
	
	MapAnnotation * expenseAnnotation = [[MapAnnotation alloc] initWithTransaction:currentTransaction];
	[map addAnnotation:expenseAnnotation];
	[expenseAnnotation release];

	MKCoordinateSpan span;
	span.latitudeDelta = 0.0015;
	
	MKCoordinateRegion region;
	region.center = location;
	region.span = span;
	
	[map setRegion:region];
	
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
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
- (void)dealloc {
	[currentTransaction release];
	[geoCoder release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


//
// Scales the map up or down
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
		[moveMapButton setBackgroundImage:[UIImage imageNamed:@"MapButtonTop.png"] forState:UIControlStateNormal];
		mapHidden = NO;
	} else {
		NSString * newTitle = NSLocalizedString(@"Show map", @"Show map on transacation detail page button text");
		[moveMapButton setTitle:newTitle forState:UIControlStateNormal];
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



#pragma mark
#pragma mark -
#pragma mark MKMapViewDelegate methods
// Shows annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	static NSString * Identifier = @"transactionAnnotationView";
	
	NSLog(@"Wants annotation view for annotation: %@", annotation);
	MKAnnotationView * annView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier] autorelease];
	//MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
	//annView.animatesDrop=NO;
	[annView setSelected:YES];
	
	return annView;
}

#pragma mark
#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
	NSLog(@"Reverse Geocoder Errored");
	NSLog(@"Error: %@", error);
	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
	NSLog(@"Reverse Geocoder completed");
	//[map addAnnotation:placemark];
}


@end
