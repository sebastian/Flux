#import <Three20/Three20.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TagBook : TTModel {

  NSMutableArray* _tags;
  NSArray* _allTags;

	BOOL _loadingData;
	BOOL _isLoaded;
	BOOL _outdated;
}

@property(nonatomic,retain) NSArray* tags;

- (id) initWithAutotags:(BOOL)autotags;

- (void)loadTagsFromStore;
- (void)search:(NSString*)text;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TagDataSource : TTSectionedDataSource {
  TagBook * _tagBook;
}

@property(nonatomic, readonly) TagBook * tagBook;

@end

