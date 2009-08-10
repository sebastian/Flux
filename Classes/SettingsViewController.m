//
//  SettingsViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 10.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "SettingsViewController.h"
#import "CurrencySelectionDialog.h"
#import "CurrencyManager.h"

@implementation SettingsViewController

#pragma mark
#pragma mark -
#pragma mark Init, setup and teardown
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = NSLocalizedString(@"Settings", @"Settings view controller title");
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Header label
	settingsHeaderLabel.text = self.title;
	
	// Base currency
	baseCurrencyLabel.text = NSLocalizedString(@"Your base currency:", @"settings label, select your base currency");
	baseCurrencyDescriptionLabel.text = NSLocalizedString(@"When you add transactions in currencies other than your own, they will be converted to and displayed in your base currency.", @"explanation of what base currency is");
	
	// Auto tags
	autoTagLabel.text = NSLocalizedString(@"Auto tags:", nil);
	autoTagDescriptionLabel.text = NSLocalizedString(@"When using autotags the application will suggest tags matching to the location you are at when adding a transaction.", nil);
	autoTagSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsAutoTags"] boolValue];
	
	// Set the segment control to show the right currency
	[self baseCurrencyChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baseCurrencyChanged) name:@"CurrencyManagerDidChangeBaseCurrency" object:nil];
	
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc {
    [super dealloc];
}


#pragma mark
#pragma mark -
#pragma mark Base currency methods
- (IBAction) changeCurrency {
	
	CurrencySelectionDialog *currencySelectionDialog = [[CurrencySelectionDialog new] autorelease];
	// So we can report back the currency change
	currencySelectionDialog.delegate = self;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:currencySelectionDialog] autorelease];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self presentModalViewController:navController animated:YES];
	
}
// CurrencySelectionDialogDelegate method
-(void)currencySelected:(NSString*)currencyCode {
	// Set the new base currency
	[[CurrencyManager sharedManager] setBaseCurrency:currencyCode];
}

- (void)baseCurrencyChanged {
	[currencySelectionControl setTitle:[NSString stringWithFormat:NSLocalizedString(@"Currency: %@",nil), [[CurrencyManager sharedManager] baseCurrencyDescription]] forSegmentAtIndex:0];
}

- (IBAction) toggleAutoTag {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:autoTagSwitch.on]
											  forKey:@"KleioTransactionsAutoTags"];

}

@end
