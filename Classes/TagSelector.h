//
//  TagSelector.h
//  Finance
//
//  Created by Sebastian Probst Eide on 04.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>


@protocol TagSelectorDelegate;
@class KleioPickerTextField;
@class SuggestedTags;

@interface TagSelector : TTViewController <TTTextEditorDelegate, UITextFieldDelegate, TTPickerTextFieldDelegate> {

	id<TagSelectorDelegate> _delegate;
	id<TTTableViewDataSource> _dataSource;
	
	KleioPickerTextField * _pickerTextField;
	SuggestedTags * otherTags;
	UIView * separator;
	
	TTView * suggestedTagsView;
	CGRect _keyboardBounds;

	BOOL keybordVisible;
}

@property (nonatomic, retain) KleioPickerTextField * pickerTextField;
@property (nonatomic, assign) id<TagSelectorDelegate> delegate;
@property (nonatomic, retain) id<TTTableViewDataSource> dataSource;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Protocols
@protocol TagSelectorDelegate
- (void)tagSelectorFinishedWithTagWords:(NSArray*)tagsWords; // Returns the tagswords on complete
@end