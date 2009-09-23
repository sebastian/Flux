//
//  TagSelector.h
//  Finance
//
//  Created by Sebastian Probst Eide on 04.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>


typedef enum {
  TagSelectorModeFilter = 0,
  TagSelectorModeTransaction = 1,
	TagSelectorModeEditor = 2
} TagSelectorMode;


@protocol TagSelectorDelegate;
@class KleioPickerTextField;
@class SuggestedTags;

@interface TagSelector : TTViewController <TTTextEditorDelegate, UITextFieldDelegate, TTPickerTextFieldDelegate> {

	TagSelectorMode _mode;
	
	id<TagSelectorDelegate> _delegate;
	id<TTTableViewDataSource> _dataSource;
	
	KleioPickerTextField * _pickerTextField;
	SuggestedTags * otherTags;
	UIView * separator;
	
	TTView * suggestedTagsView;
	CGRect _keyboardBounds;

	NSArray * _preexistingTags;
	
	BOOL keybordVisible;
}

@property (nonatomic, retain) KleioPickerTextField * pickerTextField;
@property (nonatomic, assign) id<TagSelectorDelegate> delegate;
@property (nonatomic, retain) id<TTTableViewDataSource> dataSource;
@property (nonatomic, assign) TagSelectorMode mode;
@property (nonatomic, retain) NSArray * tags;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Protocols
@protocol TagSelectorDelegate <NSObject>
- (void) tagSelectorFinishedWithTagWords:(NSArray*)tagsWords; // Returns the tagswords on complete
- (void) save;
@end