//
//  Utilities.h
//  Finance
//
//  Created by Sebastian Probst Eide on 30.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Tag;

@interface Utilities : NSObject {
	NSMutableDictionary * tagExistance;
	NSMutableDictionary * tagCache;
	NSManagedObjectContext * managedObjectContext;
	
	MKReverseGeocoder * geoCoder;
	
	NSDateFormatter * dateFormatter;
	
	NSArray * suggestedTagsForCurrentLocation;
	
	BOOL searchIsVisible;
	BOOL saving;
	BOOL reloadingTableAllowed;
	
	id tempVariable;
}


@property (nonatomic, retain) id tempVariable;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
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

// ReverseGeocoder methods
- (void)reverseGeoCode:(CLLocationCoordinate2D)coordinate forDelegate:(id<MKReverseGeocoderDelegate>)delegate;

-(void) setReloadingTableAllowed;
-(void) setReloadingTableNotAllowed;
-(BOOL) isReloadingTableAllowed;


// CoreData
- (void)save:(NSManagedObjectContext*)context;
- (void)privateSave;
- (void)setSavignIsFalse;
@end
