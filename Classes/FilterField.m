//
//  FilterField.m
//  Finance
//
//  Created by Sebastian Probst Eide on 03.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "FilterField.h"
#import "Utilities.h"


@implementation FilterField

@synthesize delegate;
@synthesize searchBarField;
@synthesize tagsToFilterBy;
@synthesize realTags;

static FilterField * sharedFilterField = nil;

- (id) initWithNibName:(NSString*)nibname bundle:(NSBundle*)bundle {
	self = [super initWithNibName:nibname bundle:bundle];
	if (self != nil) {
		self.tagsToFilterBy = [[NSArray alloc] init];
		self.realTags = [[NSMutableArray alloc] init];	
	}
	return self;
}

-(void)viewDidLoad {
	self.searchBarField.placeholder = NSLocalizedString(@"Tags to filter by", @"Placeholder text for search bar");
	[self hide];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark
#pragma mark -
#pragma mark Selected tags display
- (void)updateFilterByField {
	NSMutableString * filteredByString = [NSMutableString stringWithString:NSLocalizedString(@"Filtered by tags",@"")];
	[filteredByString appendString:@": "];
	
	if ([realTags count] == 0) {
		[filteredByString appendString:NSLocalizedString(@"(currently none)",@"")];
		
		filteredTagsField.hidden = YES;
		
		// Move the main content so the label is hidden
		//[delegate finishedUsingExtraSpace];
		
		
	} else {
		
		// Move the main content so that the label shows
		//filteredTagsField.hidden = NO;
		//[delegate needExtraSpace];
		
		for (NSString * tag in realTags) {
			[filteredByString appendFormat:@" %@", tag];
		}
	}
	
	filteredTagsField.text = filteredByString;	
}
- (void)resignFirstResponder { [searchBarField resignFirstResponder]; }
- (void)clearSearchState {
	
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
- (void)setSearchString:(NSString*)text {
	[searchBarField becomeFirstResponder];
	[searchBarField setText:text];
	[searchBarField resignFirstResponder];
}
- (BOOL)isVisible {
	return [self.delegate isVisible];
}
- (NSString*)searchString {
	return searchBarField.text;
}

- (void) hide {
	[delegate wantsToBeHidden];
}
- (void) show {
	[delegate wantsToBeShown];
}
- (void) toggle {
	[delegate wantsToBeToggled];
}
- (void) hideButRetainState {
	[delegate wantsToBeHiddenWithoutClearingState];
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
	
	[self.delegate cancelClicked];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[self updateFilterByField];
}


#pragma mark
#pragma mark -
#pragma mark Singleton methods

+ (FilterField*)sharedFilterBar {
    @synchronized(self) {
        if (sharedFilterField == nil) {
            [[self alloc] initWithNibName:@"FilterField" bundle:[NSBundle mainBundle]]; // assignment not done here
        }
    }
    return sharedFilterField;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedFilterField == nil) {
            sharedFilterField = [super allocWithZone:zone];
            return sharedFilterField;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release {
    //do nothing
}
- (id)autorelease{
    return self;
}

- (void)dealloc {
	
	[filteredTagsField release];
	[searchBarField release];
	[tagsToFilterBy release];
	[realTags release];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}



@end
