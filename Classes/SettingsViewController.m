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
		[self.tabBarItem setImage:[UIImage imageNamed:@"tannhjul.png"]];
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
	
	// Local currency
	localCurrencyLabel.text = NSLocalizedString(@"Use local currency:",nil);
	localCurrencyDescriptionLabel.text = NSLocalizedString(@"Automatically uses the local currency when adding new transactions.", nil);
	localCurrencySwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsUseLocalCurrency"] boolValue];
	
	// Balance badge
	balanceLabel.text = NSLocalizedString(@"Show balance on icon:", nil);
	balanceDescriptionLabel.text = NSLocalizedString(@"When activated your current positive balance will be displayed on the application icon badge. Only positive balances up to 9999 will be displayed. This is because of limitations set by Apple", nil);
	balanceSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsBalanceBadge"] boolValue];
	
	// Location tags
	locationTagLabel.text = NSLocalizedString(@"Location tags:", nil);
	locationTagDescriptionLabel.text = NSLocalizedString(@"Location tags use your GPS to find your location and suggest tags you have previously used on the same location", nil);
	locationTagSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsLocationTags"] boolValue];
	
	// Auto tags
	autoTagLabel.text = NSLocalizedString(@"Auto tags:", nil);
	autoTagDescriptionLabel.text = NSLocalizedString(@"The application will automatically add tags for the country, street, weekday, month etc to make it easier to filter your transactions", nil);
	autoTagSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"KleioTransactionsAutoTags"] boolValue];
	
	
	// Setup the scrolling behaviuor
	scrollview.contentSize = CGSizeMake(settingsView.frame.size.width, settingsView.frame.size.height);
	[scrollview addSubview:settingsView];
	
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

- (IBAction) toggleLocationTag {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:locationTagSwitch.on]
											  forKey:@"KleioTransactionsLocationTags"];
	
}
- (IBAction) toggleAutoTag {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:autoTagSwitch.on]
											  forKey:@"KleioTransactionsAutoTags"];

}
- (IBAction) toggleLocalCurrency {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:localCurrencySwitch.on]
											  forKey:@"KleioTransactionsUseLocalCurrency"];
	
}
- (IBAction) toggleBalanceBadge {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:balanceSwitch.on]
											  forKey:@"KleioTransactionsBalanceBadge"];

}

@end
