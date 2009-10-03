#import <Three20/Three20.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TagBook : NSObject <TTModel> {
  NSMutableArray* _delegates;
  NSMutableArray* _tags;
  NSArray* _allTags;
	BOOL loadingData;
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

