//
//  TransactionTableViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 24.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TagFilterDisplay;

@interface TransactionTableViewController : UITableViewController  
	<	UITableViewDelegate, UITableViewDataSource, 
		NSFetchedResultsControllerDelegate> 
{
	
	NSFetchedResultsController * resultsController;
	NSManagedObjectContext *managedObjectContext;
	NSArray * filteredSearchResults;
	NSPredicate * filteringPredicate;

}

-(void)loadDataWithSortDescriptors:(NSArray*)sortDescriptors predicates:(NSPredicate*)predicate sectionNameKeyPath:(NSString*)sectionGroupingName cacheName:(NSString*)cacheName;

-(id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context;
-(void)updateData;

@property (nonatomic, retain) NSArray * filteredSearchResults;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController * resultsController;
@property (nonatomic, retain) NSPredicate * filteringPredicate;

@end
