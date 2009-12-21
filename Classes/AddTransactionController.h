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
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Utilities.h"

// For TagSelectorDelegateProtocol
#import "TagSelector.h"

@class AmountEditor, Transaction, CurrencyKeyboard;

@interface AddTransactionController : TTViewController <TagSelectorDelegate, UtilityLocationProtocol> {

	CurrencyKeyboard * keyboard;
	
	MKPlacemark * _placemark;
	
	// CoreData stuff
	Transaction * currentTransaction;
	
	AmountEditor * _amountEditor;
	 	
	NSString * _localCurrency;
			 
	TTView *_nextActionIndicatorView;
}

@property (nonatomic, retain) NSString * localCurrency;
@property (nonatomic, retain) TTView * nextActionIndicatorView;

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

///////////////////////////////////////////////////////////////////////////////////////////////////
// UtilityLocationProtocol
- (void) baseCurrencyUpdatedTo:(NSString*)currency;
- (void) setPlacemark:(MKPlacemark*)placemark;
@end
