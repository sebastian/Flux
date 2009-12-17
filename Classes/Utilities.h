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

@class Transaction;
@class Tag;

@interface Utilities : NSObject {
	NSMutableDictionary * tagExistance;
	NSMutableDictionary * tagCache;
	NSManagedObjectContext * managedObjectContext;
	NSManagedObjectContext * _addTransactionManagedObjectContext;
	
	MKReverseGeocoder * geoCoder;
	
	NSDateFormatter * dateFormatter;
	
	NSArray * suggestedTagsForCurrentLocation;
	
	BOOL searchIsVisible;
	BOOL saving;
	BOOL reloadingTableAllowed;
	
	id tempVariable;
	Transaction * _tempTransaction;
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


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CoreData
// CoreData
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext * addTransactionManagedObjectContext;
- (void)save:(NSManagedObjectContext*)context;
- (void)privateSave;
- (void)setSavignIsFalse;
- (void)delayedSave:(Transaction*)transaction;

/*
 * Handles the creation of new manage object contexts that can be used
 * throught the app
 */
- (NSManagedObjectContext*) createObjectContext;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	GeoCoding
- (void)reverseGeoCode:(CLLocationCoordinate2D)coordinate forDelegate:(id<MKReverseGeocoderDelegate>)delegate;

-(void) setReloadingTableAllowed;
-(void) setReloadingTableNotAllowed;
-(BOOL) isReloadingTableAllowed;


@end
