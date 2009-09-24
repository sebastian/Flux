//
//  MapFullScreen.h
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapAnnotation.h"

@interface MapFullScreen : UIViewController {
	IBOutlet MKMapView * map;
	
	MapAnnotation * annotation;
	MKCoordinateRegion region;
	
}

@property (nonatomic, retain) MapAnnotation * annotation;
@property (nonatomic, assign) MKCoordinateRegion region;

- (id) initWithTransaction:(Transaction*)trs;

@end
