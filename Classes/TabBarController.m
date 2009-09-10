//
//  TabBarController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 07.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TabBarController.h"

@implementation TabBarController
///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidLoad {
  [self setTabURLs:[NSArray arrayWithObjects:@"kleio://addTransaction",
										@"kleio://testAddTransaction",
										@"kleio://listTransactions",
										nil]];	
	
}

@end