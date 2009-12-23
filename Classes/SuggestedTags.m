//
//  SuggestedTags.m
//  Finance
//
//  Created by Sebastian Probst Eide on 06.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "SuggestedTags.h"
#import "Utilities.h"

@implementation SuggestedTags

@synthesize items = _items;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (void) addTag:(NSString*)tagName {

	// Insert it into the items array
	if (![_items containsObject:tagName]) {
		[_items insertObject:tagName atIndex:0];
		
		NSIndexPath * ipath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ipath] withRowAnimation:UITableViewRowAnimationTop];		
	}
}

- (void) addSuggestedTags {
	NSArray * suggestedTags = [[Utilities toolbox] suggestedTagsForCurrentLocation];

	for (NSString * tag in suggestedTags) {
		[self.items addObject:tag];
	}
	
}

- (void) addTopTags {
	NSArray * topTags = [[Utilities toolbox] topTagsIncludingAutotags:NO];
	
	for (NSString *tagName in [topTags reverseObjectEnumerator]) {
		if (![self.items containsObject:tagName]) {
			[self.items addObject:tagName];
		}		
	}
	
}

- (void) loadData {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Load in the suggested tags
	[self addSuggestedTags];
	
	// Add top tags
	[self addTopTags];
	
	loading = NO;
	
	[self.tableView reloadData];
	
	[pool release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
	
			loading = YES;
			
			[self.tableView setDelegate:self];
			[self.tableView setDataSource:self];
					
			[[TTNavigator navigator].URLMap from:@"kleio://addTagToTagTable/(addTag:)" toObject:self];
			
			_items = [[NSMutableArray alloc] init];
			
			[self performSelectorInBackground:@selector(loadData) withObject:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
	NSLog(@"Received memory warning in %@", self);
}

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:@"kleio://addTagToTagTable/(addTag:)"];
	
	TT_RELEASE_SAFELY(_items);
	[super dealloc];
}

#pragma mark Table view methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (loading) {
		return 1;
	} else {
		return [_items count];
	}	
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"SuggestTagCell";
	
	if (loading) {
		
		TTTableActivityItem * loadingItem = [TTTableActivityItem itemWithText:TTLocalizedString(@"Loading...", @"")];
		TTTableActivityItemCell * cell = [[TTTableActivityItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		cell.object = loadingItem;
		return cell;
		
	} else {
		
		NSString * title = [_items objectAtIndex:indexPath.row];
		
		TTTableStyledTextItem * item = [TTTableStyledTextItem itemWithText:title 
																																	 URL:[@"kleio://addTagToTagTable/" stringByAppendingString:title]];
														
		TTTableTextItemCell *cell = (TTTableTextItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TTTableTextItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		cell.object = item;
		return cell;
		
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString * tagName = [_items objectAtIndex:indexPath.row];
	[[Utilities toolbox] setTempVariable:tagName];
	
	[_items removeObjectAtIndex:indexPath.row];
	
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[[@"kleio://addTagToTagSugester/" stringByAppendingString:tagName] openURL];
	
}

@end

