//
//  TransactionDisplay.h
//  Finance
//
//  Created by Sebastian Probst Eide on 26.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class MapAnnotation;
@class Transaction;

@interface TransactionDisplay : UIViewController {
    IBOutlet UILabel *amount;
    IBOutlet UILabel *description;
    IBOutlet MKMapView *map;
	IBOutlet UIButton * mapZoomButton;
    IBOutlet UILabel *tags;
    IBOutlet UILabel *what;
    IBOutlet UILabel *when;
 	
	// For map
	MapAnnotation * annotation;
	MKCoordinateRegion region;
	
	MKReverseGeocoder * geoCoder;
	
	Transaction * currentTransaction;
	
	CGRect buttonLocation;
	CGRect mapLocation;
	BOOL mapHidden;
	BOOL mapInitialPosition;
}

@property (nonatomic, retain) Transaction * currentTransaction;
@property (nonatomic, retain) MapAnnotation * annotation;
@property (nonatomic, assign) MKCoordinateRegion region;


-(IBAction)scaleMap:(id)sender;

@end
