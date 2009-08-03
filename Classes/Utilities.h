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

@class Tag;

@interface Utilities : NSObject {
	NSMutableDictionary * tagExistance;
	NSMutableDictionary * tagCache;
	NSManagedObjectContext * managedObjectContext;
	
	BOOL searchIsVisible;
}

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;


// The one public init method
+ (Utilities*)toolbox;

-(double)sumAmountForTransactionArray:(NSArray*)transactions;
-(float)keyboardAnimationDuration;
-(BOOL)doesTagExist:(NSString*)tag;
-(void)addTag:(NSString*)tag location:(CLLocation*)loc;
-(Tag*)tagObjectforTag:(NSString*)tag;
-(NSArray*)tagStringToArray:(NSString*)tagString;
-(void)clearCache;

// CoreData
- (void)save:(NSManagedObjectContext*)context;
- (void)privateSave;
@end
