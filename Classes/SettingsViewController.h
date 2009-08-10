//
//  SettingsViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 10.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrencySelectionDialog.h"

@interface SettingsViewController : UIViewController <CurrencySelectionDialogDelegate> {
	IBOutlet UILabel * settingsHeaderLabel;
	
	IBOutlet UISegmentedControl *currencySelectionControl;
	IBOutlet UILabel * baseCurrencyLabel;
	IBOutlet UILabel * baseCurrencyDescriptionLabel;

	IBOutlet UISwitch * autoTagSwitch;
	IBOutlet UILabel * autoTagLabel;
	IBOutlet UILabel * autoTagDescriptionLabel;
}

- (IBAction) changeCurrency;
- (void)baseCurrencyChanged;

- (IBAction) toggleAutoTag;

// CurrencySelectionDialogDelegate method
-(void)currencySelected:(NSString*)currencyCode;
@end
