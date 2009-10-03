//
//  AmountController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "CurrencyKeyboard.h"
#import "Transaction.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TagSelector.h"
#import "CurrencyManager.h"
#import "LocationController.h"
#import "CurrencySelectionDialog.h"
#import "AmountEditor.h"

@interface AddTransactionController : TTViewController 
<TagSelectorDelegate, 
 KleioCoreLocationDelegate, 
 MKReverseGeocoderDelegate> {

	MKPlacemark * _placemark;
	 
	CurrencyKeyboard * keyboard;
	
	// CoreData stuff
	NSManagedObjectContext *_managedObjectContext;
	Transaction * currentTransaction;
	
	AmountEditor * _amountEditor;
	 	
	CLLocation * _bestLocation;
	NSString * _localCurrency;
	
	BOOL foundLocationTags;
}
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) CLLocation * bestLocation;
@property (nonatomic, retain) NSString * localCurrency;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Change of state
- (IBAction) nextButtonAction;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Normal methods
- (void) createAndSetupTransaction;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TagSelectorDelegate
- (void)tagSelectorFinishedWithTagWords:(NSArray*)tagsWords;
- (void) save;

@end
