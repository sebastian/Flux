//
//  Utilities.h
//  Finance
//
//  Created by Sebastian Probst Eide on 30.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

// For KleioCoreLocationDelegate
#import "LocationController.h"

@protocol UtilityLocationProtocol 
- (void) baseCurrencyUpdatedTo:(NSString*)currency;
- (void) setPlacemark:(MKPlacemark*)placemark;
@end

@class Transaction;
@class Tag;

@interface Utilities : NSObject <KleioCoreLocationDelegate, MKReverseGeocoderDelegate> {
	NSMutableDictionary * tagExistance;
	NSMutableDictionary * tagCache;
	
	NSManagedObjectContext * _tagManagedObjectContext;
	NSManagedObjectContext * managedObjectContext;
	NSManagedObjectContext * _addTransactionManagedObjectContext;
	
	MKReverseGeocoder * geoCoder;
	
	NSDateFormatter * dateFormatter;
	
	NSArray * suggestedTagsForCurrentLocation;
	NSArray * _topTags;
	
	BOOL searchIsVisible;
	BOOL reloadingTableAllowed;
	
	id tempVariable;
	Transaction * _tempTransaction;
	
	// Core Location
	CLLocation * _bestLocation;
	BOOL foundLocationTags;
	BOOL _didGeoCoding;
	id<UtilityLocationProtocol> _locationDelegate;
}

@property (nonatomic, retain) Transaction * tempTransaction;
@property (nonatomic, retain) id tempVariable;
@property (nonatomic, retain) NSDateFormatter * dateFormatter;
@property (nonatomic, retain) MKReverseGeocoder * geoCoder;

// The one public init method
+ (Utilities*)toolbox;

-(double)sumAmountForTransactionArray:(NSArray*)transactions;
-(float)keyboardAnimationDuration;

-(void)clearCache;
-(CGSize)sizeOfTextOfField:(UITextField*)field;
-(CGSize)sizeOfTextOfLabel:(UILabel*)label;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Miscelaneous
- (void) setBarColours:(TTViewController*)sender;
- (void) setBarColours:(TTViewController*)sender colour:(UIColor*)colour;
- (NSString *)applicationDocumentsDirectory;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Tags
@property (nonatomic, retain) NSArray * suggestedTagsForCurrentLocation;
-(BOOL)doesTagExist:(NSString*)tag;
-(void)addTag:(NSString*)tag autotag:(BOOL)autotag location:(CLLocation*)loc;
-(Tag*)tagObjectforTag:(NSString*)tag;
-(NSArray*)twoTagsStartingWith:(NSString*)start;
-(NSArray*)tagStringToArray:(NSString*)tagString;
-(NSArray*)allTagNames;
-(NSArray*)allTagNamesIncludingAutotags:(BOOL)autotags;
-(NSArray*)topTagsIncludingAutotags:(BOOL)autotags;
-(void)findLocationTags;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CoreData
// CoreData
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext * addTransactionManagedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext * tagManagedObjectContext;
- (void)save:(NSManagedObjectContext*)context;

/*
 * Handles the creation of new manage object contexts that can be used
 * throught the app
 */
- (NSManagedObjectContext*) createObjectContext;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	GeoCoding
@property (nonatomic, retain) CLLocation * bestLocation;
@property (nonatomic, assign) id<UtilityLocationProtocol> locationDelegate;
- (void)reverseGeoCode:(CLLocationCoordinate2D)coordinate forDelegate:(id<MKReverseGeocoderDelegate>)delegate;
-(void) startGeocoding;

-(void) setReloadingTableAllowed;
-(void) setReloadingTableNotAllowed;
-(BOOL) isReloadingTableAllowed;

@end
