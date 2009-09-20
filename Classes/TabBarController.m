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
  [self setTabURLs:[NSArray arrayWithObjects:@"kleio://testAddTransaction",
										//@"kleio://addTransaction",
										@"kleio://listTransactions",
										nil]];	
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

@end