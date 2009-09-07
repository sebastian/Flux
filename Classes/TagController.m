//
//  TagController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 03.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TagController.h"


@implementation TagController

@synthesize delegate;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id)init {
    if (self = [super initWithNibName:@"TagController" bundle:[NSBundle mainBundle]]) {
    }
    return self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Action methods
- (IBAction) saveTransaction {
	[self.delegate dismissModalViewControllerAnimated:YES];
}
- (IBAction) cancel {
	[self.delegate dismissModalViewControllerAnimated:YES];
}

@end
