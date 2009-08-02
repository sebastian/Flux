//
//  TestViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 02.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TransactionFilterViewController : UIViewController <UISearchBarDelegate> {
	NSManagedObjectContext * managedObjectContext;
	
	IBOutlet UILabel * filteredTagsField;
	UISearchBar * searchBarField;	
	UIView * contentView;
	
	NSArray * tagsToFilterBy;
	NSMutableArray * realTags;
	
	BOOL searchIsVisible;
}

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, retain) NSMutableArray * realTags;
@property (nonatomic, retain) IBOutlet UISearchBar * searchBarField;
@property (nonatomic, retain) UIView * contentView;
@property (nonatomic, retain) NSArray * tagsToFilterBy;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil andContext:(NSManagedObjectContext*)context;

-(void)updateFilterByField;

@end
