//
//  TestViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 02.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionFilterViewController.h"
#import "TransactionsViewController.h"
#import "Utilities.h"

@interface TransactionFilterViewController (PrivateMethods)
-(void)moveMainContentDown:(BOOL)down;
-(void)animateContentToFrame:(CGRect)frame;
-(void)hideSearch;
-(void)showSearch;
-(void)toggleSearch:(NSNotification*)notification;
-(void)clearSearchState;
@end



@implementation TransactionFilterViewController

@synthesize searchBarField;
@synthesize contentView;
@synthesize tagsToFilterBy;
@synthesize managedObjectContext;
@synthesize realTags;

#pragma mark
#pragma mark -
#pragma mark Setup init and teardown
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andContext:(NSManagedObjectContext*)context {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

		self.managedObjectContext = context;
		
		TransactionsViewController * transactionViewController = [[TransactionsViewController alloc] initWithContext:context];
		self.contentView = transactionViewController.view;
		
		// Add the contentview to the subview
		[self.view addSubview:self.contentView];
		
		self.tagsToFilterBy = [[NSArray alloc] init];
		
		self.realTags = [[NSMutableArray alloc] init];
		
		self.title = NSLocalizedString(@"Transactions",@"Tab bar title");
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self showSearch];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(toggleSearch:)
	 name:@"KleioToggleFilterView"
	 object:nil];
	
	searchBarField.placeholder = NSLocalizedString(@"Tags to filter by", @"Placeholder text for search bar");

	[self updateFilterByField];
}
-(void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
	[realTags release];
	[managedObjectContext release];
	[tagsToFilterBy release];
	[contentView release];
	[searchBarField release];

    [super dealloc];
}


#pragma mark
#pragma mark -
#pragma mark Selected tags display
-(void)updateFilterByField {
	NSMutableString * filteredByString = [NSMutableString stringWithString:NSLocalizedString(@"Filtered by tags",@"")];
	[filteredByString appendString:@": "];
		
	if ([realTags count] == 0) {
		[filteredByString appendString:NSLocalizedString(@"(currently none)",@"")];
		
		// Move the main content so the label is hidden
		[self moveMainContentDown:NO];
		
	} else {
		
		// Move the main content so that the label shows
		[self moveMainContentDown:YES];
		
		for (NSString * tag in realTags) {
			[filteredByString appendFormat:@" %@", tag];
		}
	}
	
	filteredTagsField.text = filteredByString;	
}
// Move the main content in or out of view
-(void)moveMainContentDown:(BOOL)down {
	
	CGRect frame = self.contentView.frame;
	
	if (down == YES) {
		frame.origin.y = 70;
	} else {
		frame.origin.y = 44;
	}
	
	NSLog(@"Moving content to: %i", frame.origin.y);
	
	[self animateContentToFrame:frame];
}
-(void)animateContentToFrame:(CGRect)frame {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[Utilities toolbox] keyboardAnimationDuration]];
	self.contentView.frame = frame;
    [UIView commitAnimations];	
}
-(void)hideSearch {
	
	searchIsVisible = NO;
	
	[searchBarField resignFirstResponder];
	
	CGRect frame = self.contentView.frame;
	frame.origin.y = 0;
	[self animateContentToFrame:frame];
	
	[self clearSearchState];
		
}
-(void)showSearch {
	
	searchIsVisible = YES;
	
	CGRect frame = self.contentView.frame;
	frame.origin.y = 44;
	
	[self animateContentToFrame:frame];	

	//[filteredTagsField setNeedsLayout];
	
	[self updateFilterByField];
}
-(void)toggleSearch:(NSNotification*)notification {
	if (searchIsVisible) {
		[self hideSearch];
	} else {
		[self showSearch];
	}
}
-(void)clearSearchState {

	// Clear the search when it is hidden
	searchBarField.text = @"";
	self.tagsToFilterBy = nil;
	[self.realTags removeAllObjects];
		
	// Send out notification that the filtering is over
	NSPredicate * filteringPredicate = [NSPredicate predicateWithValue:YES];
	NSDictionary * predicateDict = [NSDictionary dictionaryWithObject:filteringPredicate 
															   forKey:@"predicate"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KleioPredicateUpdated" 
														object:self 
													  userInfo:predicateDict];
}

#pragma mark
#pragma mark -
#pragma mark UISearchBarDelegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
	NSPredicate * filteringPredicate;
		
	NSArray * tags = [[Utilities toolbox] tagStringToArray:searchText];
	
	if ([tags isEqualToArray:tagsToFilterBy]) {
		// No new filtering to do!
		NSLog(@"No new filtering to do...");
		
	} else {
		// Update the tags to filter by variable
		self.tagsToFilterBy = tags;
		
		[self updateFilterByField];
		
		// Check the special case of the tags being empty
		if ([tags count] == 0) {
			filteringPredicate = [NSPredicate predicateWithValue:YES];
		} else {
			
			[realTags removeAllObjects];
			
			NSMutableArray * tagPredicates = [[NSMutableArray alloc] init];
			for (NSString * tag in tags) {
				// Add predicates for the valid tags to an array
				if ([[Utilities toolbox] doesTagExist:tag]) {
					
					// Add to array of tags that are in use
					[realTags addObject:tag];
					
					// Create a predicate
					NSPredicate * tagPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] %@", tag];

					// Add to predicate list
					[tagPredicates addObject:tagPredicate];

				}
			}
			
			NSPredicate * filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:tagPredicates];
			filteringPredicate = filterPredicate;
			
		}

		NSDictionary * predicateDict = [NSDictionary dictionaryWithObject:filteringPredicate 
																   forKey:@"predicate"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"KleioPredicateUpdated" 
															object:self 
														  userInfo:predicateDict];
		
	}		
	
	
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBarField resignFirstResponder];
}
// TODO: Make the search bar lose focus, and clear it
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = @"";
	[searchBar resignFirstResponder];

	[self hideSearch];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[self updateFilterByField];
}

@end
