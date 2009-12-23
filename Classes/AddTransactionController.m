//
//  AmountController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>
#import "AddTransactionController.h"
#import "KleioCustomStyles.h"
#import "AmountEditor.h"

// Tags
#import "TagSelector.h"

// Models
#import "Transaction.h"
#import "Location.h"
#import "Tag.h"

// Currency
#import "CurrencyManager.h"
#import "CurrencyKeyboard.h"
#import "CurrencySelectionDialog.h"

// Singleton helpers
#import "CacheMasterSingleton.h"
// Utilities had to be included in header

@implementation AddTransactionController

@synthesize	localCurrency = _localCurrency, nextActionIndicatorView = _nextActionIndicatorView;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private methods

- (void) layout {
	
	TTFlowLayout * flow = [[TTFlowLayout alloc] init];
	[flow layoutSubviews:self.view.subviews forView:self.view];
	[flow release];
	
}

- (void) createAndSetupTransaction {
	
	// Get a clean slate by releasing previous transactions
	if (currentTransaction != nil) {
		TT_RELEASE_SAFELY(currentTransaction);
	}
	
	NSManagedObjectContext * context = [[Utilities toolbox] addTransactionManagedObjectContext];
	currentTransaction = [[NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:context] retain];
	
	// If we have a local currency, then use it
	if (self.localCurrency != nil) {
		currentTransaction.currency = self.localCurrency;
	}
	
	// Set the new transaction for the delegate
	_amountEditor.currentTransaction = currentTransaction;
		
}

-(void) add:(NSString*)what toArray:(NSMutableArray*)array {
	if (_placemark != nil) {
		if ([_placemark valueForKey:what] != nil) {
			[array addObject:[_placemark valueForKey:what]];
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject
- (id) init {
    if (self = [super init]) {
			[self.tabBarItem setImage:[UIImage imageNamed:@"Add.png"]];
    }
    return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_localCurrency);
	TT_RELEASE_SAFELY(_amountEditor);
	TT_RELEASE_SAFELY(_placemark);
	TT_RELEASE_SAFELY(currentTransaction);	
	TT_RELEASE_SAFELY(_nextActionIndicatorView);
	
	[super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void) loadView {
	[super loadView];
				
	[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
		
	// Setup next button
	TTButton * nextButton = [TTButton buttonWithStyle:@"greenForwardButton:" title:NSLocalizedString(@"Next",nil)];
	nextButton.font = [UIFont boldSystemFontOfSize:16.f];
	[nextButton sizeToFit];
	[nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
	//[self performSelectorInBackground:@selector(highlightedNextButton:) withObject:nextButton];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:nextButton] autorelease];
		
	_amountEditor = [[AmountEditor alloc] init];
	_amountEditor.delegate = self;
	
	[self createAndSetupTransaction];
	
	[self.view addSubview:_amountEditor.view];
	
	self.tabBarItem.title = NSLocalizedString(@"New", nil);
	
	self.title = NSLocalizedString(@"Add transaction",nil);
	
	// Get the location
	[[Utilities toolbox] startGeocoding];
	[[Utilities toolbox] setLocationDelegate:self];

}

- (void) highlightedNextButtonStage2:(TTButton*)nextButton {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	sleep(2);
		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1];
	
	[nextButton setStylesWithSelector:@"greenForwardButton:"];
	NSLog(@"normal");
	
	[UIView commitAnimations];	
	
	[self performSelectorInBackground:@selector(highlightedNextButton:) withObject:nextButton];		
	
	[pool release];
}
- (void) highlightedNextButton:(TTButton*)nextButton {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if (YES) {
		
		while (![currentTransaction needsDeleteButton]) {sleep(0.5);}
			
		sleep(2);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:1];
		
		[nextButton setStylesWithSelector:@"greenForwardButtonHighlighted:"];
		NSLog(@"highlighted");
		
		[UIView commitAnimations];		
		
		[self performSelectorInBackground:@selector(highlightedNextButtonStage2:) withObject:nextButton];
		
	}
	
	[pool release];
}

- (void) viewDidUnload {
	[super viewDidUnload];
	NSLog(@"Location manager stopped");
	[[LocationController sharedInstance].locationManager stopUpdatingLocation];
}

- (IBAction) nextButtonAction {

	TagSelector * tagSelector = [[TagSelector alloc] init];
	tagSelector.delegate = self;
	[tagSelector setMode:TagSelectorModeTransaction];

	// Send the tags to the tagSelector if the transaction already has tags
	tagSelector.tags = currentTransaction.tagsArray;
	
	[self.navigationController pushViewController:tagSelector animated:YES];
		
	[tagSelector release];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TagSelectorDelegate

- (void) tagSelectorFinishedWithTagWords:(NSArray*)tagsWords {
	currentTransaction.tagsArray = tagsWords;
}

- (void) save {
	NSLog(@"Save...");
	
	if ([[Utilities toolbox] bestLocation].horizontalAccuracy < 500.f) {
		currentTransaction.location = [[Utilities toolbox] bestLocation];
	}
	
	/*
	 Adding autotags
	 */
	NSMutableArray * autotags = [[NSMutableArray alloc] init];
	[self add:@"country" toArray:autotags];
	[self add:@"administrativeArea" toArray:autotags];
	[self add:@"locality" toArray:autotags];
	if ([[Utilities toolbox] bestLocation].horizontalAccuracy < 1500.f) {
		[self add:@"subAdministrativeArea" toArray:autotags];
		[self add:@"subLocality" toArray:autotags];
		[self add:@"thoroughfare" toArray:autotags];		
	}
	
	NSDateFormatter * dateFormatter = [[Utilities toolbox] dateFormatter];
	NSArray * weekdays = [dateFormatter weekdaySymbols];
	NSArray * months = [dateFormatter monthSymbols];
	
	// Set the month and year for easier searching and displaying and most importantly grouping!
	NSCalendar * currentCalendar = [NSCalendar currentCalendar];
	NSDateComponents * components = [currentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit) fromDate:currentTransaction.date];
	
	NSString * month = [months objectAtIndex:components.month-1];
	NSString * weekday = [weekdays objectAtIndex:components.weekday-1];
	NSString * year = [NSString stringWithFormat:@"%i", components.year];
	
	[autotags addObject:month];
	[autotags addObject:weekday];
	[autotags addObject:year];
	
	NSString * newAutoTags = [autotags componentsJoinedByString:@" "];
	currentTransaction.autotags = [NSString stringWithFormat:@" %@ ", newAutoTags];
	
	[[Utilities toolbox] save:[currentTransaction managedObjectContext]];
	[self createAndSetupTransaction];

}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UtilityLocationProtocol
- (void) baseCurrencyUpdatedTo:(NSString*)currency {

	// Only if the user wants it!
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsUseLocalCurrency"] boolValue] == YES) {
		currentTransaction.currency = currency;
		self.localCurrency = currency;
		[_amountEditor updateExpenseDisplay];
	}
	
}
- (void) setPlacemark:(MKPlacemark*)placemark {
	_placemark = [placemark retain];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	MISC
// FIXME: Before release this should be improved
- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
	
	[[CacheMasterSingleton sharedCacheMaster] clearCache];	
		
	[super didReceiveMemoryWarning];
}

@end
