//
//  TransactionViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TransactionViewController.h"
#import "KleioCustomStyles.h"
#import "Transaction.h"
#import "CacheMasterSingleton.h"
#import "Utilities.h"
#import "MapFullScreen.h"
#import "EditAmountController.h"
#import "EditDateController.h"

#define STANDARD_TEXT_FONT [UIFont systemFontOfSize:16.f]

@interface TTButton (KleioAddition)
@property (nonatomic, retain) NSString * text;
@end

@implementation TTButton (KleioAddition)

- (void) setText:(NSString*)text {
	
	[self setTitle:text forState:UIControlStateNormal];
	CGSize size = [text drawInRect:CGRectMake(0, 0, 300, 800) withFont:[UIFont systemFontOfSize:14.f]];
	self.height = size.height + 40;
	[self setNeedsLayout];
	
}
- (NSString*) text {
	return [self titleForState:UIControlStateNormal];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KleioMultilineLabel : TTView
{
	NSString * _text;
	NSArray * _textArray;
	UIFont * _font;
	UIColor * _textColor;
}
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) UIFont * font;
@property (nonatomic, retain) UIColor * textColor;
@end

@implementation KleioMultilineLabel

@synthesize font = _font, textColor = _textColor;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Accessor and getter for text
- (void) setText:(NSString*)text {
	[text retain];
	[_text release];
	_text = text;
	
	if (_textArray != nil) {TT_RELEASE_SAFELY(_textArray);}
	_textArray = [[_text componentsSeparatedByString:@" "] retain];
	
	[self setNeedsLayout];
	
}
- (NSString*) text {
	return _text;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.textColor = [UIColor blackColor];
	}
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_text);
	TT_RELEASE_SAFELY(_textArray);
	TT_RELEASE_SAFELY(_font);
	TT_RELEASE_SAFELY(_textColor);
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTView

- (void)drawContent:(CGRect)rect {
	int x = 0, y = 0;
	CGSize spaceSize = [@" " sizeWithFont:_font];
	
	for (NSString * word in _textArray) {
		CGSize sizeOfWord = [word sizeWithFont:_font];
		if ((x + sizeOfWord.width) > rect.size.width) {
			x = 0, y += spaceSize.height*1.4;
			
			if (y > rect.size.height) {
				break;
			}
		}
		
		[word drawAtPoint:CGPointMake(x, y) withFont:_font];
		x += sizeOfWord.width + spaceSize.width;
		
	}	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIView

- (CGSize)sizeThatFits:(CGSize)size {

	CGFloat lineHeightMultiplier = 1.4;
	
	int x = 0, y = 0;
	CGSize spaceSize = [@" " sizeWithFont:_font];
	
	for (NSString * word in _textArray) {
		CGSize sizeOfWord = [word sizeWithFont:_font];
		if ((x + sizeOfWord.width) > size.width) {
			x = 0, y += spaceSize.height*lineHeightMultiplier;
		}
		
		x += sizeOfWord.width + spaceSize.width;
		
	}
	return CGSizeMake(size.width, y + spaceSize.height*lineHeightMultiplier);
	
}


@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CONFIG
#define KleioTag_VerticalPadding 3
#define KleioTag_HorizontalPadding 5
#define KleioTag_MinWidth 25
#define KleioTag_fontSize 14.f

@interface KleioTag : TTView {
	NSString * _text;
}
- (id) initWithText:(NSString*)tag;
@end

@implementation KleioTag

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject
- (id) initWithText:(NSString*)tag {
	if (self = [super initWithFrame:CGRectMake(0, 0, 100, 40)]) {
		
		self.style = TTSTYLEVAR(newTagList);
		self.backgroundColor = [UIColor clearColor];
	
		_text = [tag retain];
		
		CGSize size = [_text drawAtPoint:CGPointMake(0, 0) withFont:[UIFont systemFontOfSize:KleioTag_fontSize]];
		
		// Resize self to new size
		self.width = size.width + 2*KleioTag_HorizontalPadding;
		self.height = size.height + 2*KleioTag_VerticalPadding;

		if (self.width < KleioTag_MinWidth) {
			self.width = KleioTag_MinWidth;
		}
	}
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_text);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTView

- (void)drawContent:(CGRect)rect {
	[[UIColor whiteColor] set];
	[_text drawAtPoint:CGPointMake(KleioTag_HorizontalPadding, KleioTag_VerticalPadding) withFont:[UIFont systemFontOfSize:KleioTag_fontSize]];	
}


@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol EncapsulatingViewDelegate
@required
- (void) performLayout;
- (void) invokeEdit;
@end

@interface EncapsulatingView : TTView {
	id <EncapsulatingViewDelegate> _delegate;
}
@property (nonatomic, assign) id <EncapsulatingViewDelegate> delegate;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation EncapsulatingView

@synthesize delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.width = 320;
		
		self.style = TTSTYLEVAR(contentBox);
		
		TTFlowLayout * layout = [[TTFlowLayout alloc] init];
		layout.padding = 20;
		layout.spacing = 5;
		self.layout = layout;
		[layout release];
		
	}
	return self;
}

- (void) dealloc {
	_delegate = nil;
	
	NSLog(@"Fresh subviews:");
	for (UIView* subview in self.subviews) {
		NSLog(@"Subview: %@", subview);
	}
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIView
- (void) addSubview:(UIView*)view {
	[super addSubview:view];
	[_delegate performLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize daSaiz = [self.layout layoutSubviews:self.subviews forView:self];
	daSaiz.width = 320;
	return daSaiz;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (event.type == UIEventTypeTouches) {
		[_delegate invokeEdit];
	}
	
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ItemView : TTView <EncapsulatingViewDelegate>
{
	UILabel * _titleLabel;
	EncapsulatingView * _contentView;

	// Edit button
	id _delegate;
	id _editDelegate;
	SEL _delegateSelector;
	TTButton * _editButton;
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, readonly) UIView * contentView;
@property (nonatomic, assign) id delegate;

- (void) performLayout;
- (void) enableEditForTarget:(id)target selector:(SEL)selector;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ItemView
@synthesize delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	EncapsulatingViewDelegate method

- (void) performLayout {
	
	int padding = 10;
	
	[_titleLabel sizeToFit];
	_titleLabel.frame = CGRectMake(padding, padding, _titleLabel.width, _titleLabel.height);

	_contentView.top = _titleLabel.bottom;
	[_contentView sizeToFit];

	if (_editButton != nil) {
		_editButton.right = self.width - 10;
		_editButton.bottom = _contentView.top + 16;
	}
	
	[self sizeToFit];
	
	SEL layoutSel = @selector(layout);
	if ([_delegate respondsToSelector:layoutSel]) {
		[_delegate performSelector:layoutSel];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Setters
- (void) setTitle:(NSString *)newTitle {
	_titleLabel.text = newTitle;

	[self performLayout];
	
	[self setNeedsLayout];
}

- (NSString*) title {
	return _titleLabel.text;
}

- (UIView*) contentView {
	return _contentView;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super initWithFrame:CGRectMake(0, 0, 320, 200)]) {		
		_delegate = nil;
		_editDelegate = nil;
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
		_titleLabel.font = [UIFont systemFontOfSize:23.f];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		[self addSubview:_titleLabel];
		
		_contentView = [[EncapsulatingView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		_contentView.delegate = self;
		[self addSubview:_contentView];
		
	}
	return self;
}

- (void) dealloc {
	_delegate = nil;
	_delegateSelector = nil;
	_editDelegate = nil;
	
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_contentView);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIView

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize selfSize = CGSizeMake(320, _contentView.bottom + 10);
	
	if (_editButton != nil) {
		selfSize.width = _editButton.right;
	} else {
		selfSize.width = _titleLabel.right;
	}

	[_contentView sizeToFit];
	
	if (_contentView.right > selfSize.width) {
		selfSize.width = _contentView.right;
	}

	selfSize.height = _contentView.bottom;

	return selfSize;
}

- (void) setNeedsDisplay {
	[super setNeedsDisplay];
	for (UIView * subview in _contentView.subviews) {
		[subview setNeedsDisplay];
	}
	[self performLayout];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Public

- (void) enableButtonWithTitle:(NSString*)title target:(id)target selector:(SEL)selector {

	_editDelegate = target;
	_delegateSelector = selector;
	
	// Add a button if there is a delegate
	if ((_editDelegate != nil) & [_editDelegate respondsToSelector:_delegateSelector]) {
		if (_editDelegate != nil) {
			TT_RELEASE_SAFELY(_editButton);
		}
		_editButton = [[TTButton buttonWithStyle:@"editTransactionDetailButton:" title:title] retain];
		[_editButton sizeToFit];
		[_editButton addTarget:_editDelegate action:_delegateSelector forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:_editButton];
		
		_contentView.multipleTouchEnabled = YES;
		
	}
	
	[self performLayout];
	
	
}

- (void) enableEditForTarget:(id)target selector:(SEL)selector {
	[self enableButtonWithTitle:NSLocalizedString(@"Edit", nil) target:target selector:selector];
}

- (void) invokeEdit {
	
	if ((_editDelegate != nil) & [_editDelegate respondsToSelector:_delegateSelector]) {
		if ([_editDelegate isKindOfClass:[NSString class]]) {
			[_editDelegate openURLFromButton:self];
		} else {
			[_editDelegate performSelector:_delegateSelector];	
		}
	}
	
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface KleioTagCluster : TTView {
	Transaction * _currentTransaction;
}
@property (nonatomic, retain) Transaction * currentTransaction;
@end

@implementation KleioTagCluster
@synthesize currentTransaction = _currentTransaction;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithTransaction:(Transaction*)trs andFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		self.backgroundColor = [UIColor clearColor];
		
		self.currentTransaction = trs;
		self.multipleTouchEnabled = NO;
		
		[self setNeedsDisplay];
	}
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_currentTransaction);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIView

- (void) setNeedsDisplay {
	[super setNeedsDisplay];
	
	[self removeAllSubviews];
	
	for (NSString * tag in _currentTransaction.tagsArray) {
		KleioTag * tagView = [[KleioTag alloc] initWithText:tag];
		[self addSubview:tagView];
		[tagView release];
	}
	
	TTFlowLayout * layout = [[TTFlowLayout alloc] init];
	layout.padding = 0;
	layout.spacing = 3;
	self.width = 270;
	CGSize size = [layout layoutSubviews:self.subviews forView:self];
	self.height = size.height;
	self.width = size.width;
	[layout release];
	
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation TransactionViewController

@synthesize currentTransaction = _currentTransaction;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (void) layout {
	for (UIView* subview in self.view.subviews) {
		[subview sizeToFit];
	}
	
	TTFlowLayout* flowLayout = [[[TTFlowLayout alloc] init] autorelease];
  flowLayout.padding = 0;
  flowLayout.spacing = 10;
  CGSize size = [flowLayout layoutSubviews:self.view.subviews forView:self.view];
  
  UIScrollView* scrollView = (UIScrollView*)self.view;
  scrollView.contentSize = CGSizeMake(scrollView.width, size.height);
}

//	Tags

- (void) editTags {
	
	TagSelector * tagsSelector = [[TagSelector alloc] init];
	tagsSelector.delegate = self;
	tagsSelector.tags = self.currentTransaction.tagsArray;
	tagsSelector.mode = TagSelectorModeEditor;
	
	[self.navigationController pushViewController:tagsSelector animated:YES];
	[tagsSelector release];
	
}

- (void) addTagsToView:(UIView*)view {
	
	_tags = [[ItemView alloc] init];
	_tags.delegate = self;
	_tags.title = NSLocalizedString(@"Keywords", nil);	

	KleioTagCluster * _tagCluster = [[KleioTagCluster alloc] initWithTransaction:self.currentTransaction andFrame:CGRectMake(0, 0, 260, 400)];
	[_tags.contentView addSubview:_tagCluster];
	[_tagCluster release];
	
	[_tags enableEditForTarget:self selector:@selector(editTags)];
	[view addSubview:_tags];
	
}

//	Amount

- (void) editAmount {
	
	EditAmountController * editAmount = [[EditAmountController alloc] initWithTransaction:self.currentTransaction];
	editAmount.delegate = self;
	[self.navigationController pushViewController:editAmount animated:YES];
	[editAmount release];
	
}

- (void) setupAmountLabels {
	
	[_amountItem.contentView removeAllSubviews];
	
	UILabel * amount = [[UILabel alloc] init];
	amount.text = [_currentTransaction amountInLocalCurrency];
	amount.font = STANDARD_TEXT_FONT;
	[amount sizeToFit];
	amount.backgroundColor = [UIColor clearColor];
	[_amountItem.contentView addSubview:amount];
	[amount release];
	
	if (![[_currentTransaction amountInLocalCurrency] isEqualToString:[_currentTransaction amountInBaseCurrency]]) {
		UILabel * amountBase = [[UILabel alloc] init];
		
		NSString * baseCurrency = [NSString stringWithFormat:@"(%@)", [_currentTransaction amountInBaseCurrency]];
		amountBase.text = baseCurrency;
		amountBase.font = STANDARD_TEXT_FONT;
		[amountBase sizeToFit];
		amountBase.backgroundColor = [UIColor clearColor];
		[_amountItem.contentView addSubview:amountBase];
		[amountBase release];
	}
		
}

- (void) addTheAmountToView:(UIView*)view {
	
	_amountItem = [[ItemView alloc] init];
	_amountItem.title = NSLocalizedString(@"Amount", nil);
	_amountItem.delegate = self;
	[_amountItem enableEditForTarget:self selector:@selector(editAmount)];
	
	[self setupAmountLabels];
	
	[view addSubview:_amountItem];
	
}

//	Date

- (void) editDate {

	EditDateController * editDate = [[EditDateController alloc] initWithTransaction:self.currentTransaction];
	editDate.delegate = self;
	[self.navigationController pushViewController:editDate animated:YES];
	[editDate release];
	
}

- (void) setupDateLabel {

	[_dateItem.contentView removeAllSubviews];
	
	// Create something about the date...
	UILabel * when = [[UILabel alloc] init];
	when.backgroundColor = [UIColor clearColor];
	when.text = [_currentTransaction longFormattedDate];
	when.font = STANDARD_TEXT_FONT;
	[when sizeToFit];
	[_dateItem.contentView addSubview:when];
	[when release];
	
}

- (void) addDateToView:(UIView*)view {

	_dateItem = [[ItemView alloc] init];
	_dateItem.title = NSLocalizedString(@"When", nil);
	[_dateItem enableEditForTarget:self selector:@selector(editDate)];
	_dateItem.delegate = self;
	[view addSubview:_dateItem];
	
	[self setupDateLabel];
	
}

//	Description

- (UIViewController*)post:(NSDictionary*)query {
  TTPostController* controller = [[[TTPostController alloc] init] autorelease];
	controller.delegate = self;
	controller.textEditor.text = _currentTransaction.transactionDescription;
  controller.originView = [query objectForKey:@"__target__"];
  return controller;
}

- (void) addDescriptionToView:(UIView*)view {

	NSString * buttonTitle = [_currentTransaction.transactionDescription isEqualToString:@""]
		? NSLocalizedString(@"Click to add a description", nil)
		: _currentTransaction.transactionDescription;
	
	_descriptionItem = [[ItemView alloc] init];
	_descriptionItem.title = NSLocalizedString(@"Description", nil);
	_descriptionItem.delegate = self;
	
	[_descriptionItem enableEditForTarget:@"tt://post" selector:@selector(openURLFromButton:)];
	[view addSubview:_descriptionItem];
	
	KleioMultilineLabel * myDescriptionLabel = [[KleioMultilineLabel alloc] initWithFrame:CGRectMake(0, 0, 250, 100)];
	myDescriptionLabel.font = STANDARD_TEXT_FONT;
	myDescriptionLabel.text = buttonTitle;
	[myDescriptionLabel sizeToFit];
	[_descriptionItem.contentView addSubview:myDescriptionLabel];
	[myDescriptionLabel release];
	
//	TTLabel * descriptionLabel = [[TTLabel alloc] initWithText:buttonTitle];
//	descriptionLabel.font = STANDARD_TEXT_FONT;
////	descriptionLabel.width = 200;
//	[descriptionLabel sizeToFit];
//	[_descriptionItem.contentView addSubview:descriptionLabel];
//	[descriptionLabel release];
		
//	_descriptionButton = [TTButton buttonWithStyle:@"descriptionField"];
//	_descriptionButton.text = buttonTitle;
//  [_descriptionButton addTarget:@"tt://post" action:@selector(openURLFromButton:)
//		forControlEvents:UIControlEventTouchUpInside];
//  _descriptionButton.frame = CGRectMake(0, 0, 320, 50);
////  [view addSubview:_descriptionButton];
//	[_descriptionItem.contentView addSubview:_descriptionButton];
	
}

//	Location

- (void) addLocationToView:(UIView *)view {
	
	// Geo code location
	if (_currentTransaction.location != nil) {
		[[Utilities toolbox] reverseGeoCode:_currentTransaction.location.coordinate forDelegate:self];

		_locationItem = [[ItemView alloc] init];
		_locationItem.title = NSLocalizedString(@"Where", nil);
		_locationItem.delegate = self;
		
		UIActivityIndicatorView * act = [[UIActivityIndicatorView alloc] init];
		[act startAnimating];
		[act sizeToFit];
		[_locationItem.contentView addSubview:act];
		[act release];
		
		UILabel * locationTempLabel = [[UILabel alloc] init];
		locationTempLabel.backgroundColor = [UIColor clearColor];
		locationTempLabel.font = STANDARD_TEXT_FONT;		
		locationTempLabel.text = NSLocalizedString(@"Looking up address", nil);
		[locationTempLabel sizeToFit];
		[_locationItem.contentView addSubview:locationTempLabel];
		[locationTempLabel release];

		[view addSubview:_locationItem];
		
	} 
}
#pragma mark CoreLocation - MKReverseGeocoder
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	
	NSInteger numberOfLines = 0;
	
	NSString * locationText = @"";
	if (placemark.thoroughfare != nil) {
		locationText = [locationText stringByAppendingFormat:@"%@", placemark.thoroughfare];
		numberOfLines++;
	}
	if (placemark.postalCode != nil) {
		locationText = [locationText stringByAppendingFormat:@"\n%@", placemark.postalCode];
		numberOfLines++;
	}
	if (placemark.locality != nil) {
		locationText = [locationText stringByAppendingFormat:@" %@", placemark.locality];
	}
	if (placemark.country != nil) {
		locationText = [locationText stringByAppendingFormat:@"\n%@", placemark.country];
		numberOfLines++;
	}
	if (placemark.subLocality != nil) {
		locationText = [[NSString stringWithFormat:@"%@", placemark.subLocality] stringByAppendingString:locationText];
		numberOfLines++;
	}
	
	// Setup location label
	UILabel * location = [[UILabel alloc] init];
	location.text = locationText;
	location.backgroundColor = [UIColor clearColor];
	location.numberOfLines = numberOfLines;
	location.font = STANDARD_TEXT_FONT;
	[location sizeToFit];
	
	[_locationItem.contentView removeAllSubviews];
	[_locationItem.contentView addSubview:location];

	[_locationItem enableButtonWithTitle:NSLocalizedString(@"Show on map", nil) target:self selector:@selector(showMap)];
	
	[_locationItem sizeToFit];
	[_locationItem setNeedsDisplay];

	[location release];

}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	
	NSString * errorText = NSLocalizedString(@"Location not found",nil);
	
	// Setup location label
	UILabel * location = [[UILabel alloc] init];
	location.text = errorText;
	location.backgroundColor = [UIColor clearColor];
	location.font = STANDARD_TEXT_FONT;
	[location sizeToFit];
	
	[_locationItem.contentView removeAllSubviews];
	[_locationItem.contentView addSubview:location];
	[_locationItem sizeToFit];
	[_locationItem setNeedsDisplay];
	
	[location release];
	
}
- (void) showMap {
	
	MapFullScreen * bigMap = [[MapFullScreen alloc] initWithTransaction:_currentTransaction];
	[self.navigationController pushViewController:bigMap animated:YES];
	[bigMap release];
	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		
		[[TTNavigator navigator].URLMap from:@"tt://post"
												toViewController:self selector:@selector(post:)];

		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
	}
	return self;
}

- (void)dealloc {
	
	[[TTNavigator navigator].URLMap removeURL:@"tt://post"];
	
	TT_RELEASE_SAFELY(_amountItem);
	TT_RELEASE_SAFELY(_tags);
	TT_RELEASE_SAFELY(_dateItem);
	TT_RELEASE_SAFELY(_descriptionItem);
	TT_RELEASE_SAFELY(_locationItem);
	
	TT_RELEASE_SAFELY(_currentTransaction);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UITableViewController

- (void) loadView {
	[super loadView];
	
	self.currentTransaction = [[Utilities toolbox] tempTransaction];
	[[Utilities toolbox] setTempTransaction:nil];
	
	[[Utilities toolbox] setBarColours:self colour:RGBCOLOR(50,50,50)];
	//[[Utilities toolbox] setBarColours:self];
	//TTToolbarNavigationFrame()
	UIScrollView* scrollView = [[[UIScrollView alloc] initWithFrame:TTToolbarNavigationFrame()] autorelease];
	scrollView.autoresizesSubviews = YES;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.canCancelContentTouches = NO;
  scrollView.delaysContentTouches = YES;
  self.view = scrollView;
	
	// Add the amount
	[self addTheAmountToView:scrollView];
		
	// Add the tags
	[self addTagsToView:scrollView];
	
	// Add description
	[self addDescriptionToView:scrollView];
	
	// Add date
	[self addDateToView:scrollView];

	// Add location
	[self addLocationToView:scrollView];
	
	// Lay out the elements
	[self layout];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
	NSLog(@"Did receive memory warning in @%", self);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TagSelectorDelegate

- (void) tagSelectorFinishedWithTagWords:(NSArray*)tagsWords {
	self.currentTransaction.tagsArray = tagsWords;
}

- (void) save {
	[[Utilities toolbox] save:[self.currentTransaction managedObjectContext]];
	[_tags setNeedsDisplay];
	[self layout];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTPostControllerDelegate
- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text {
	_currentTransaction.transactionDescription = text;

	KleioMultilineLabel * label = (KleioMultilineLabel*)[_descriptionItem.contentView.subviews objectAtIndex:0];
	label.text = text;
	[label sizeToFit];
	[_descriptionItem setNeedsDisplay];
	
	[[Utilities toolbox] save:[self.currentTransaction managedObjectContext]];
	
	return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	EditAmountControllerDelegate methods
- (void) updateAmount {
	[self setupAmountLabels];
	[_amountItem setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	EditDateControllerDelegate methods
- (void) updateDate {
	[self setupDateLabel];
	[_dateItem setNeedsDisplay];
}

@end
