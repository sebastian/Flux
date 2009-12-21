//
//  TagDataSource.m
//  Finance
//
//  Created by Sebastian Probst Eide on 04.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TagDataSource.h"
#import "Utilities.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TagBook

@synthesize tags = _tags;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)performSearch:(NSString*)text {
  self.tags = [NSMutableArray array];
  
  if (text.length) {
    text = [text lowercaseString];
    for (NSString * tag in _allTags) {
      if ([[tag lowercaseString] rangeOfString:text].location == 0) {
        [_tags addObject:tag];
      }
    }    
  }
	
  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id) initWithAutotags:(BOOL)autotags {
  if (self = [super init]) {
    _delegates = nil;
		
		_isLoaded = NO;
		_loadingData = NO;
		_outdated = YES;
		
		if (autotags) {
			_allTags = [[[Utilities toolbox] allTagNamesIncludingAutotags:YES] retain];
		} else {
			_allTags = [[[Utilities toolbox] allTagNames] retain];	
		}
		
    _tags = nil;
  }
  return self;	
}

- (id)init {
	return [self initWithAutotags:NO];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_allTags);
  TT_RELEASE_SAFELY(_tags);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isOutdated {
  return _outdated;
}

- (BOOL)isLoaded {
  return _isLoaded;
}

- (BOOL)isLoading {
  return _loadingData;
}

- (BOOL)isEmpty {
  return !_tags.count;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	[self didFinishLoad];
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
  if (_loadingData) {
    _loadingData = NO;
		[self didCancelLoad];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)loadTagsFromStore {
	// TODO: Perform a load of tags...
  TT_RELEASE_SAFELY(_tags);
  _tags = [_allTags mutableCopy];
}

- (void)search:(NSString*)text {
  [self cancel];
  
  if (text.length) {
      [self performSearch:text];
      [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
  } else {
    TT_RELEASE_SAFELY(_tags);
    [_delegates perform:@selector(modelDidChange:) withObject:self];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TagDataSource

@synthesize tagBook = _tagBook;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id) initWithAutotags:(BOOL)autotags {
  if (self = [super init]) {
		if (autotags) {
			_tagBook = [[TagBook alloc] initWithAutotags:YES];
		}	else {
			_tagBook = [[TagBook alloc] init];
		}
		
    self.model = _tagBook;
  }
  return self;
	
}

- (id)init {
	return [self initWithAutotags:NO];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_tagBook);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];
	
  for (NSString * tag in _tagBook.tags) {
    TTTableItem* item = [TTTableTextItem itemWithText:tag];
    [_items addObject:item];
  }
}

- (void)search:(NSString*)text {
  [_tagBook search:text];
}

- (NSString*)titleForLoading:(BOOL)reloading {
  return NSLocalizedString(@"Searching...", nil);
}

- (NSString*)titleForNoData {
  return NSLocalizedString(@"No previous keywords found", nil);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

