//
//  ExpensesViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 09.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ExpensesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	UITableView * expensesTable;
	UISearchBar * searchBar;
}

@property (nonatomic, retain) IBOutlet UITableView * expensesTable;
@property (nonatomic, retain) IBOutlet UISearchBar * searchBar;


@end
