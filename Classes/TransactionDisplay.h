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

@class Transaction;

@interface TransactionDisplay : UIViewController <MKMapViewDelegate, MKReverseGeocoderDelegate>{
    IBOutlet UILabel *amount;
    IBOutlet UILabel *description;
    IBOutlet MKMapView *map;
    IBOutlet UILabel *tags;
    IBOutlet UILabel *what;
    IBOutlet UILabel *when;
	IBOutlet UIButton *moveMapButton;
	
	MKReverseGeocoder * geoCoder;
	
	Transaction * currentTransaction;
	
	CGRect buttonLocation;
	CGRect mapLocation;
	BOOL mapHidden;
	BOOL mapInitialPosition;
}

@property (nonatomic, retain) Transaction * currentTransaction;

-(IBAction)scaleMap:(id)sender;

@end
