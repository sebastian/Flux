//
//  TagSelector.m
//  Finance
//
//  Created by Sebastian Probst Eide on 04.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TagSelector.h"
#import "TagDataSource.h"
#import "KleioPickerTextField.h"
#import "SuggestedTags.h"
#import <Three20/Three20.h>
#import "Utilities.h"
#import "KleioCustomStyles.h"
#import "CacheMasterSingleton.h"

#define LOGRECT(rect) \
TTLOG(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
rect.size.width, rect.size.height)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KleioViewHolder : TTView
@end

@implementation KleioViewHolder

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Keyboard actions
- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds {
	LOGRECT(bounds);
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
	LOGRECT(bounds);
}
@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation TagSelector

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize pickerTextField = _pickerTextField;
@synthesize mode = _mode;
@synthesize tags = _preexistingTags;
- (NSArray*) tags {return nil;} // Fix if needed...

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (NSArray*) chosenTags {
	NSMutableArray * returnTags = [[NSMutableArray alloc] init];
	for (id tag in _pickerTextField.cells) {
		
		if ([tag isKindOfClass:[NSString class]]) {
			[returnTags addObject:tag];
		}
		
		if ([tag isKindOfClass:[TTTableTextItem class]]) {
			TTTableTextItem * item = tag;
			[returnTags addObject:item.text];
		}
	}	
	
	return [returnTags autorelease];
}

- (void) makeCurrentTextIntoTag {
	if ([_pickerTextField.text isEqualToString:@""]) {
		return;
	}
	
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
	NSString * newTagText = [_pickerTextField.text stringByTrimmingCharactersInSet:whitespace];
	// Add if not empty
	if (![newTagText isEqualToString:@""]) {
		[_pickerTextField addCellWithObject:newTagText];
	}
	
	// Remove the old text
	[_pickerTextField setText:@""];
	
}

- (void) done {

	// Update the cache master
	[CacheMasterSingleton sharedCacheMaster].tagWords = [self chosenTags];
	
	// Remove window
	[self dismissModalViewControllerAnimated:YES];	
}

- (void) clearTagsAndExit {
	
	// Remove all tags
	[CacheMasterSingleton sharedCacheMaster].tagWords = nil;
	
	// Remove window
	[self dismissModalViewControllerAnimated:YES];	

}

- (void) cancel {
	
	[self.navigationController popViewControllerAnimated:YES];
	
}

/*
 "Save" and "Back" are both for the transaction mode,
 where we are NOT in modal view mode, but belong directly 
 to a controller
 */
- (void) sendTagsToDelegate {
	if ([_delegate respondsToSelector:@selector(tagSelectorFinishedWithTagWords:)]) {

		NSArray * returnTags = [self chosenTags];
		[_delegate tagSelectorFinishedWithTagWords:returnTags];

	}
}

- (void) doSave {
	
	[self makeCurrentTextIntoTag];
	
	/*
	 Notify the delegate to save with the new tags
	 Then do a fancy animation to show that it has been saved!
	 */
	[self sendTagsToDelegate];
	
	if ([_delegate respondsToSelector:@selector(save)]) {
		[_delegate save];
	}
	
}

- (void) editorSave {
	
	[self cancel];
	[self doSave];
	
}

- (void) save {
	
	[self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];
	[self doSave];
	
}

- (void) back {
	/*
	 Send the tags back to the delegate
	 and then go back
	 */
	[self makeCurrentTextIntoTag];
	[self sendTagsToDelegate];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)layout {
	
	CGRect workableSpace;
	
	if (keybordVisible) {
		workableSpace = TTKeyboardNavigationFrame();
		
	} else {
		if (_mode == TagSelectorModeFilter) {
			workableSpace = TTNavigationFrame();
		} else {
			workableSpace = TTToolbarNavigationFrame(); //TTNavigationFrame(); //TTToolbarNavigationFrame();
			workableSpace = CGRectMake(workableSpace.origin.x, workableSpace.origin.y, workableSpace.size.width, workableSpace.size.height - 5);
		}
		
	}
	
	// Set right location for picker frame;
	_pickerTextField.top = 0;
		
	separator.top = _pickerTextField.bottom;
	separator.width = 320;
	separator.height = 1;
	
	// Get the right height for the tableview
	suggestedTagsView.height = workableSpace.size.height - _pickerTextField.height - separator.height;
	suggestedTagsView.top = separator.bottom;
		
	TTFlowLayout * flow = [[TTFlowLayout alloc] init];
	flow.padding = 0;
	flow.spacing = 0;
	[flow layoutSubviews:self.view.subviews forView:self.view];
	[flow release];
	
}

- (KleioPickerTextField*)createPicker {
	
	if (_pickerTextField != nil) {
		return _pickerTextField;
	}
	
	_pickerTextField = [[[KleioPickerTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 45)] autorelease];
	_pickerTextField.dataSource = self.dataSource;
	_pickerTextField.delegate = self;
	_pickerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	_pickerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_pickerTextField.backgroundColor = [UIColor whiteColor];
	
	UILabel* label = [[[UILabel alloc] init] autorelease];
	// TODO: replace with "keyword"/"tag" icon
	label.text = NSLocalizedString(@"Keywords:",nil); 
	label.font = TTSTYLEVAR(messageFont);
	label.textColor = TTSTYLEVAR(messageFieldTextColor);
	[label sizeToFit];
	label.frame = CGRectInset(label.frame, -2, 0);
	_pickerTextField.leftView = label;
	_pickerTextField.leftViewMode = UITextFieldViewModeAlways;
	
  return _pickerTextField;
}

- (void) addCellWithObject {
	[self makeCurrentTextIntoTag];
	[_pickerTextField addCellWithObject:[[Utilities toolbox] tempVariable]];
}

- (void) addTagTableView {

	if (suggestedTagsView != nil) {TT_RELEASE_SAFELY(suggestedTagsView);}
	
	suggestedTagsView = [[TTView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
	suggestedTagsView.autoresizesSubviews = YES;
	
	otherTags = [[SuggestedTags alloc] init];
	UITableView * sugTags = otherTags.tableView;
	sugTags.height = suggestedTagsView.height;
	sugTags.top = 0;
	sugTags.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	sugTags.autoresizesSubviews = YES;
	sugTags.width = suggestedTagsView.width;
	
	[suggestedTagsView addSubview:sugTags];
	
	[self.view addSubview:suggestedTagsView];
	
}

- (void) setupNavigationButtons {
	/* 
	 Setup the right navigation bar buttons
	 */
	if (_mode == TagSelectorModeTransaction) {
		
		// Right button
		TTButton * saveButton = [TTButton buttonWithStyle:@"blueToolbarButton:" title:NSLocalizedString(@"Save",nil)];
		saveButton.font = [UIFont boldSystemFontOfSize:16.f];
		[saveButton sizeToFit];
		[saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:saveButton] autorelease];
		
		// Left button
		TTButton * backButton = [TTButton buttonWithStyle:@"blackBackwardButton:" title:NSLocalizedString(@"Back",nil)];
		backButton.font = [UIFont boldSystemFontOfSize:16.f];
		[backButton sizeToFit];
		[backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
		
	} 
	
	if (_mode == TagSelectorModeFilter) {
		
		// Right button
		TTButton * doneButton = [TTButton buttonWithStyle:@"blueToolbarButton:" title:NSLocalizedString(@"Done",nil)];
		doneButton.font = [UIFont boldSystemFontOfSize:12];
		[doneButton sizeToFit];
		[doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease];
		
		
		// Left button
		TTButton * clearButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:NSLocalizedString(@"Clear filter",nil)];
		clearButton.font = [UIFont boldSystemFontOfSize:12];
		[clearButton sizeToFit];
		[clearButton addTarget:self action:@selector(clearTagsAndExit) forControlEvents:UIControlEventTouchUpInside];
		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:clearButton] autorelease];
		
	}
	
	if (_mode == TagSelectorModeEditor) {
		
		// Right button
		TTButton * doneButton = [TTButton buttonWithStyle:@"blueToolbarButton:" title:NSLocalizedString(@"Save",nil)];
		doneButton.font = [UIFont boldSystemFontOfSize:12];
		[doneButton sizeToFit];
		[doneButton addTarget:self action:@selector(editorSave) forControlEvents:UIControlEventTouchUpInside];
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease];
		
		// Left button
		TTButton * clearButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:NSLocalizedString(@"Cancel",nil)];
		clearButton.font = [UIFont boldSystemFontOfSize:12];
		[clearButton sizeToFit];
		[clearButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:clearButton] autorelease];
		
	}
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithAutotags:(BOOL)autotags {
	if (self = [super init]) {
		self.title = NSLocalizedString(@"Select keywords", nil);
		self.navigationBarStyle = UIBarStyleBlackOpaque;
		
		self.autoresizesForKeyboard = YES;
		
		if (autotags) {
			self.dataSource = [[[TagDataSource alloc] initWithAutotags:YES] autorelease];
		} else {
			self.dataSource = [[[TagDataSource alloc] init] autorelease];
		}
		
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
		[[TTNavigator navigator].URLMap from:@"kleio://addTagToTagSugester" toObject:self selector:@selector(addCellWithObject)];
		
	}
	return self;
}
- (id) init {
	return [self initWithAutotags:YES];
}

- (void) loadView {
	[super loadView];
	
	KleioPickerTextField * picker = [self createPicker];
	[self.view addSubview:picker];
	
	separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
	separator.backgroundColor = TTSTYLEVAR(messageFieldSeparatorColor);
	separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:separator];
	
	[self addTagTableView];

	// Make the navigation bar and status bar black
	[[Utilities toolbox] setBarColours:self];
	
	[self setupNavigationButtons];

	// Layout the controls
	[self layout];

	/*
	 If we are in filter mode then there might just as well
	 be preexisting tags to filter by. 
	 They should be added to the list so that the filter can be adjusted!
	 */
	if (_mode == TagSelectorModeFilter) {self.tags = [CacheMasterSingleton sharedCacheMaster].tagWords;}

	// add all the current tags to the field so that they are visually selected
	for (NSString * tag in _preexistingTags) {
		if (![tag isEqualToString:@""]) {[_pickerTextField addCellWithObject:tag];}
	}
}

- (void) dealloc {
	[[TTNavigator navigator].URLMap removeURL:@"kleio://addTagToTagSugester"];
	TT_RELEASE_SAFELY(otherTags);
	TT_RELEASE_SAFELY(_dataSource);
	TT_RELEASE_SAFELY(separator);
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTPickerTextFieldDelegate
- (void)textField:(TTPickerTextField*)textField didAddCellAtIndex:(NSInteger)index {
	TTLOG(@"didAddCellAtIndex:");
}
- (void)textField:(TTPickerTextField*)textField didRemoveCellAtIndex:(NSInteger)index {
	TTLOG(@"didRemoveCellAtIndex:");
}
- (void)textFieldDidResize:(TTPickerTextField*)textField {
	TTLOG(@"didResize");
	[self layout];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTSearchTextFieldDelegate
- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
	TTLOG(@"Did selectObject:");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UITextFieldDelegate
- (BOOL)textField:(KleioPickerTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	if ([textField isEqual:_pickerTextField] && [string isEqualToString:@" "]) {
		
		[self makeCurrentTextIntoTag];
		
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	BOOL shouldReturn = YES;
  
	[self makeCurrentTextIntoTag];
	
  return shouldReturn;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Keyboard action...
- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds {
	TTLOG(@"Keyboard did appear");
	keybordVisible = YES;
	[self layout];
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
	TTLOG(@"Keyboard did dissapear");
	keybordVisible = NO;
	[self layout];
}

@end
