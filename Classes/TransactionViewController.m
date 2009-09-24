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

#define STANDARD_TEXT_FONT [UIFont systemFontOfSize:14.f]


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

// CONFIG
#define KleioTag_VerticalPadding 3
#define KleioTag_HorizontalPadding 5
#define KleioTag_MinWidth 25
#define KleioTag_fontSize 14.f

@interface KleioTag : TTView {
	NSString * _text;
	int verticalPadding;
	int horizontalPadding;
	CGFloat fontSize;
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
	return daSaiz;
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
	
	[_titleLabel sizeToFit];
	_titleLabel.frame = CGRectMake(10, 10, _titleLabel.width, _titleLabel.height);
	
	if (_editButton != nil) {
		_editButton.left = _titleLabel.right + 10;
		_editButton.top = _titleLabel.top;
	}
	
	[_contentView sizeToFit];
	_contentView.frame = CGRectMake(0, _titleLabel.bottom, _contentView.width, _contentView.height);
	
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
		_titleLabel.font = [UIFont systemFontOfSize:25.f];
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

- (void) enableEditForTarget:(id)target selector:(SEL)selector {
	_editDelegate = target;
	_delegateSelector = selector;

	// Add a button if there is a delegate
	if ((_editDelegate != nil) & [_editDelegate respondsToSelector:_delegateSelector]) {
		if (_editDelegate != nil) {
			TT_RELEASE_SAFELY(_editButton);
		}
		_editButton = [[TTButton buttonWithStyle:@"embossedButton:" title:NSLocalizedString(@"Edit", nil)] retain];
		[_editButton sizeToFit];
		[_editButton addTarget:_editDelegate action:_delegateSelector forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:_editButton];
		
	}
	
	[self performLayout];
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
	CGSize size = [layout layoutSubviews:self.subviews forView:self];
	self.height = size.height;
	[layout release];
	
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation TransactionViewController

@synthesize currentTransaction = _currentTransaction;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (void) layout {
	TTFlowLayout* flowLayout = [[[TTFlowLayout alloc] init] autorelease];
  flowLayout.padding = 0;
  flowLayout.spacing = 0;
  CGSize size = [flowLayout layoutSubviews:self.view.subviews forView:self.view];
  
  UIScrollView* scrollView = (UIScrollView*)self.view;
  scrollView.contentSize = CGSizeMake(scrollView.width, size.height);
}

//	Private (Tags)

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

- (UIViewController*)post:(NSDictionary*)query {
  TTPostController* controller = [[[TTPostController alloc] init] autorelease];
	controller.delegate = self;
	controller.textEditor.text = _currentTransaction.transactionDescription;
  controller.originView = [query objectForKey:@"__target__"];
  return controller;
}

//	Private (Amount)

- (void) editAmount {
	
}

- (void) addTheAmountToView:(UIView*)view {
	
	ItemView * amountItem = [[ItemView alloc] init];
	amountItem.title = NSLocalizedString(@"Amount", nil);
	amountItem.delegate = self;
	[amountItem enableEditForTarget:self selector:@selector(editAmount)];
	
	UIFont * font = [UIFont systemFontOfSize:16.f];
	
	UILabel * amount = [[[UILabel alloc] init] autorelease];
	amount.text = [_currentTransaction amountInLocalCurrency];
	amount.font = font;
	[amount sizeToFit];
	[amountItem.contentView addSubview:amount];
	
	if (![[_currentTransaction amountInLocalCurrency] isEqualToString:[_currentTransaction amountInBaseCurrency]]) {
		UILabel * amountBase = [[[UILabel alloc] init] autorelease];

		NSString * baseCurrency = [NSString stringWithFormat:@"(%@)", [_currentTransaction amountInBaseCurrency]];
		amountBase.text = baseCurrency;
		amountBase.font = font;
		[amountBase sizeToFit];
		[amountItem.contentView addSubview:amountBase];
	}
	
	[view addSubview:amountItem];
	[amountItem release];
	
}

//	Private (Date)

- (void) addDateToView:(UIView*)view {

	_dateItem = [[ItemView alloc] init];
	_dateItem.title = NSLocalizedString(@"When", nil);
	_dateItem.delegate = self;
	[view addSubview:_dateItem];
	
	// Create something about the date...
	UILabel * when = [[[UILabel alloc] init] autorelease];
	when.text = [_currentTransaction longFormattedDate];
	when.font = STANDARD_TEXT_FONT;
	[when sizeToFit];
	[_dateItem.contentView addSubview:when];
	
}

//	Private (Description)

- (void) addDescriptionToView:(UIView*)view {

	NSString * buttonTitle = [_currentTransaction.transactionDescription isEqualToString:@""]
		? NSLocalizedString(@"Click to add a description", nil)
		: _currentTransaction.transactionDescription;
	
	_descriptionItem = [[ItemView alloc] init];
	_descriptionItem.title = NSLocalizedString(@"Description", nil);
	_descriptionItem.delegate = self;
	
	[_descriptionItem enableEditForTarget:@"tt://post" selector:@selector(openURLFromButton:)];
	[view addSubview:_descriptionItem];
	
	TTLabel * descriptionLabel = [[TTLabel alloc] initWithText:buttonTitle];
	descriptionLabel.font = STANDARD_TEXT_FONT;
//	descriptionLabel.width = 200;
	[descriptionLabel sizeToFit];
	[_descriptionItem.contentView addSubview:descriptionLabel];
	[descriptionLabel release];
		
//	_descriptionButton = [TTButton buttonWithStyle:@"descriptionField"];
//	_descriptionButton.text = buttonTitle;
//  [_descriptionButton addTarget:@"tt://post" action:@selector(openURLFromButton:)
//		forControlEvents:UIControlEventTouchUpInside];
//  _descriptionButton.frame = CGRectMake(0, 0, 320, 50);
////  [view addSubview:_descriptionButton];
//	[_descriptionItem.contentView addSubview:_descriptionButton];
	
}

// Private (Location)

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
	location.numberOfLines = numberOfLines;
	location.font = STANDARD_TEXT_FONT;
	[location sizeToFit];
	
	[_locationItem.contentView removeAllSubviews];
	[_locationItem.contentView addSubview:location];
	
	TTButton * showMapButton = [TTButton buttonWithStyle:@"embossedButton:"];
	[showMapButton setText:NSLocalizedString(@"Show on map", nil)];
	[showMapButton addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
	[showMapButton sizeToFit];
	[_locationItem.contentView addSubview:showMapButton];

	[_locationItem setNeedsDisplay];

	[location release];

}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	
	NSString * errorText = NSLocalizedString(@"Location not found",nil);
	
	// Setup location label
	UILabel * location = [[UILabel alloc] init];
	location.text = errorText;
	location.font = STANDARD_TEXT_FONT;
	[location sizeToFit];
	
	[_locationItem.contentView removeAllSubviews];
	[_locationItem.contentView addSubview:location];
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
	
	[[Utilities toolbox] setBarColours:self];
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

	UILabel * descriptionLabel = [[UILabel alloc] init];
	descriptionLabel.font = STANDARD_TEXT_FONT;
	descriptionLabel.text = text;
	descriptionLabel.width = 200;
	descriptionLabel.numberOfLines = INT_MAX;
	[descriptionLabel sizeToFit];
	[_descriptionItem.contentView removeAllSubviews];
	[_descriptionItem.contentView addSubview:descriptionLabel];
	[descriptionLabel release];
	
//	_descriptionButton.text = text;
	[[Utilities toolbox] save:[self.currentTransaction managedObjectContext]];
	
//	[self layout];
	
	return YES;
}

@end
