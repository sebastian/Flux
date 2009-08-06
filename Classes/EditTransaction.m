//
//  EditTransaction.m
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "EditTransaction.h"
#import "CurrencyKeyboard.h"

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
}

-(void)cancel {
	[self.navigationController popViewControllerAnimated:YES];	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[currencyKeyboard release];
	[currentTransaction release];
    [super dealloc];
}


@end
