//
//  TransactionAnnotation.h
//  Finance
//
//  Created by Sebastian Probst Eide on 27.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//
#import <Three20/Three20.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Transaction;

@interface MapAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	Transaction * currentTransaction;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Transaction * currentTransaction;

-(id)initWithTransaction:(Transaction*)tr;

- (NSString *)subtitle;
- (NSString *)title;

@end
