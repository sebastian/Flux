//
//  SuggestedTags.m
//  Finance
//
//  Created by Sebastian Probst Eide on 06.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "SuggestedTags.h"
#import <Three20/Three20.h>
#import "Utilities.h"

@implementation SuggestedTags

@synthesize items = _items;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (void) addTag {

	NSString * tagName = [[Utilities toolbox] tempVariable];
	// Insert it into the items array
	[_items insertObject:tagName atIndex:0];
	
	NSIndexPath * ipath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ipath] withRowAnimation:UITableViewRowAnimationTop];
}

- (void) addSuggestedTags {
	NSArray * suggestedTags = [[Utilities toolbox] suggestedTagsForCurrentLocation];

	for (NSString * tag in suggestedTags) {
		[self.items addObject:tag];
	}
}

- (void) addTopTags {
	NSArray * topTags = [[Utilities toolbox] topTagsIncludingAutotags:NO];

	// Make sure we don't get duplicate tag entries
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.items];
	for (NSString * tag in topTags) {
		if (![predicate evaluateWithObject:tag]) {
			// We only want max 15 items in total
			if ([self.items count] == 15) {break;}
	
			// We don't have 15 tags yet, add to the list!
			[self.items addObject:tag];
		}
	}

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
	
			[self.tableView setDelegate:self];
			[self.tableView setDataSource:self];
					
			[[TTNavigator navigator].URLMap from:@"kleio://addTagToTagTable" toObject:self selector:@selector(addTag)];
			
			self.items = [[NSMutableArray alloc] init];
			
			// Load in the suggested tags
			[self addSuggestedTags];
			
			// Add top tags
			[self addTopTags];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
	TTLOG(@"Received memory warning in %@", self);
}

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:@"kleio://addTagToTagTable"];
	
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
	return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SuggestTagCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
		cell.textLabel.text = [_items objectAtIndex:indexPath.row];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString * tagName = [_items objectAtIndex:indexPath.row];
	[[Utilities toolbox] setTempVariable:tagName];
	
	[_items removeObjectAtIndex:indexPath.row];
	
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	// Add the name to the tag field
	NSString * urlString = @"kleio://addTagToTagSugester";
	[[TTNavigator navigator] openURL:urlString animated:NO];
	
}

@end

