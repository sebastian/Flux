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


@implementation TagSelector

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize pickerTextField = _pickerTextField;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private
- (void) done {
	// TODO: tell the delegate about the tags
	/*
	NSArray * tagWords = [[NSMutableArray alloc] init];
	[_delegate tagSelectorFinishedWithTagWords:tagWords];
	TT_RELEASE_SAFELY(tagWords);
	 */
	TTLOG(@"Called 'done'");
	[self dismissModalViewControllerAnimated:YES];
}

#define LOGRECT(rect) \
NSLog(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
rect.size.width, rect.size.height)

- (void)layout {
	
	CGRect workableSpace;
	
	if (keybordVisible) {
		workableSpace = TTKeyboardNavigationFrame();
	} else {
		workableSpace = TTNavigationFrame();
	}
	
	// Set right location for picker frame;
	_pickerTextField.top = 0;
		
	separator.top = _pickerTextField.bottom;
	separator.width = 320;
	separator.height = 1;
	
	// Get the right height for the tableview
	suggestedTagsView.height = workableSpace.size.height - separator.bottom;
	suggestedTagsView.top = separator.bottom;
	

	
	TTFlowLayout * flow = [[TTFlowLayout alloc] init];
	flow.padding = 0;
	flow.spacing = 0;
	[flow layoutSubviews:self.view.subviews forView:self.view];

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

- (void) makeCurrentTextIntoTag {
	
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
	NSString * newTagText = [_pickerTextField.text stringByTrimmingCharactersInSet:whitespace];
	// Add if not empty
	if (![newTagText isEqualToString:@""]) {
		[_pickerTextField addCellWithObject:newTagText];
	}
	
	// Remove the old text
	[_pickerTextField setText:@""];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		self.title = NSLocalizedString(@"Select keywords", nil);
		self.navigationBarStyle = UIBarStyleBlackOpaque;
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																																														target:self action:@selector(done)] autorelease];

		self.autoresizesForKeyboard = YES;
		self.dataSource = [[[TagDataSource alloc] init] autorelease];
		self.navigationBarStyle = UIBarStyleBlackOpaque;
	}
	return self;
}

- (void) loadView {
	[super loadView];
	
	KleioPickerTextField * picker = [self createPicker];
	[self.view addSubview:picker];
	
	separator = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)] autorelease];
	separator.backgroundColor = TTSTYLEVAR(messageFieldSeparatorColor);
	separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:separator];
	
	[self addTagTableView];

	[self layout];
	
	[[TTNavigator navigator].URLMap from:@"kleio://addTagToTagSugester" toObject:self selector:@selector(addCellWithObject)];

}

- (void) dealloc {
	TT_RELEASE_SAFELY(_dataSource);
	TT_RELEASE_SAFELY(_pickerTextField);
	TT_RELEASE_SAFELY(otherTags);
	[super dealloc];
}

- (void) viewDidUnload {
	[[TTNavigator navigator].URLMap removeURL:@"kleio://addTagToTagSugester"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTPickerTextFieldDelegate
- (void)textField:(TTPickerTextField*)textField didAddCellAtIndex:(NSInteger)index {
	NSLog(@"didAddCellAtIndex:");
}
- (void)textField:(TTPickerTextField*)textField didRemoveCellAtIndex:(NSInteger)index {
	NSLog(@"didRemoveCellAtIndex:");
}
- (void)textFieldDidResize:(TTPickerTextField*)textField {
	NSLog(@"didResize");
	[self layout];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTSearchTextFieldDelegate
- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
	NSLog(@"Did selectObject:");
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
	_keyboardBounds = bounds;
	[self layout];
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
	_keyboardBounds = bounds;
	[self layout];
}

@end
