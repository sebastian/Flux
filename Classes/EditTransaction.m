//
//  EditTransaction.m
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "EditTransaction.h"
#import "CurrencyKeyboard.h"
#import "Transaction.h"

@interface EditTransaction (PrivateMethods)
-(void)cancel;
@end



@implementation EditTransaction

@synthesize currentTransaction;
@synthesize currencyKeyboard;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:self 
																				   action:@selector(cancel)];
	self.navigationItem.rightBarButtonItem = cancelButton;
	[cancelButton release];
	
	self.view.backgroundColor = [UIColor clearColor];
	
	scrollview.contentSize = CGSizeMake(editView.frame.size.width, editView.frame.size.height);
	[scrollview addSubview:editView];
	
	// Setup controls
	amountLabel.text = NSLocalizedString(@"Amount:", nil);
	[amountButton setTitle:[self.currentTransaction amountInLocalCurrency] forState:UIControlStateNormal];
	baseCurrencyAmountLabel.text = [NSString stringWithFormat:@"(%@)", [self.currentTransaction amountInBaseCurrency]];
	
	dateLabel.text = NSLocalizedString(@"Date:", nil);
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[dateButton setTitle:[formatter stringFromDate:self.currentTransaction.date] forState:UIControlStateNormal];

	locationLabel.text = NSLocalizedString(@"Location:",nil);
	// FIXME: Get geo coded data for this address...
	locationDataLabel.text = @"A location";
	[locationClearButton setTitle:NSLocalizedString(@"Clear",nil) forSegmentAtIndex:0];

	tagsLabel.text = NSLocalizedString(@"Tags:", nil);
	tagsField.text = self.currentTransaction.tags;
	
	descriptionLabel.text = NSLocalizedString(@"Description:",nil);
	descriptionView.text = self.currentTransaction.transactionDescription;
	descriptionView.font = tagsField.font;
	
	[saveButton setTitle:NSLocalizedString(@"Save",nil) forSegmentAtIndex:0];
		
}

-(void)cancel {
	[self.navigationController popViewControllerAnimated:YES];	
}


- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)saveAction {
	
	// TODO: Save changes
	
}


- (void)dealloc {
	[currencyKeyboard release];
	[currentTransaction release];
    [super dealloc];
}


@end
