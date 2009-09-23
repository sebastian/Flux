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
		
		self.currentTransaction = trs;
		self.multipleTouchEnabled = NO;
		
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
		
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
		
		NSString * tagBoxStyle;
		if ([[CacheMasterSingleton sharedCacheMaster].tagWords containsObject:tag]) {
			tagBoxStyle = @"existingTagBox";
		} else {
			tagBoxStyle = @"tagList";
		}
		
		TTStyledTextLabel * label = [[[TTStyledTextLabel alloc] initWithFrame:self.bounds] autorelease];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:12.f];
		label.contentInset = UIEdgeInsetsMake(1, 1, 1, 1);
		label.text = [TTStyledText textFromXHTML:[NSString stringWithFormat:@"<span class=\"%@\">%@</span>", tagBoxStyle, tag] 
																	lineBreaks:NO 
																				URLs:NO];
		
		[label sizeToFit];
		label.width = [tag sizeWithFont:label.font].width + 17;
		label.height += 4;
		
		[self addSubview:label];
	}
	
	TTFlowLayout * layout = [[[TTFlowLayout alloc] init] autorelease];
	layout.padding = 20;
	layout.spacing = 3;
	CGSize size = [layout layoutSubviews:self.subviews forView:self];
	self.height = size.height;
	
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
  flowLayout.spacing = 5;
  CGSize size = [flowLayout layoutSubviews:self.view.subviews forView:self.view];
  
  UIScrollView* scrollView = (UIScrollView*)self.view;
  scrollView.contentSize = CGSizeMake(scrollView.width, size.height);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
	
	// Add the tags
	UILabel * keywordLabel = [[UILabel alloc] init];
	keywordLabel.text = NSLocalizedString(@"Keywords:", nil);
	[keywordLabel sizeToFit];
	[view addSubview:keywordLabel];
	[keywordLabel release];
	
	TTButton * editButton = [TTButton buttonWithStyle:@"embossedButton:" title:NSLocalizedString(@"Edit", nil)];
	[editButton sizeToFit];
	[editButton addTarget:self action:@selector(editTags) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:editButton];
	
	_tagCluster = [[KleioTagCluster alloc] initWithTransaction:self.currentTransaction andFrame:CGRectMake(0, 0, 320, 400)];
	[view addSubview:_tagCluster];	
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private (Description)

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
	
	_descriptionButton = [TTButton buttonWithStyle:@"descriptionField"];
	_descriptionButton.text = buttonTitle;
//  [_descriptionButton setTitle:buttonTitle forState:UIControlStateNormal];
  [_descriptionButton addTarget:@"tt://post" action:@selector(openURLFromButton:)
		forControlEvents:UIControlEventTouchUpInside];
  _descriptionButton.frame = CGRectMake(0, 0, 320, 50);
  [view addSubview:_descriptionButton];
	
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
	
	TT_RELEASE_SAFELY(_currentTransaction);
	TT_RELEASE_SAFELY(_tagCluster);
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
  scrollView.backgroundColor = RGBACOLOR(50,50,50,0.6);
  scrollView.canCancelContentTouches = NO;
  scrollView.delaysContentTouches = YES;
  self.view = scrollView;
		
	// Add the tags
	[self addTagsToView:scrollView];
	
	// Add description
	[self addDescriptionToView:scrollView];
	
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
	[_tagCluster setNeedsDisplay];
	[self layout];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	TTPostControllerDelegate
- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text {
	_currentTransaction.transactionDescription = text;

	_descriptionButton.text = text;
	[[Utilities toolbox] save:[self.currentTransaction managedObjectContext]];
	
	[self layout];
	
	return YES;
}

//- (CGRect)postController:(TTPostController*)postController willAnimateTowards:(CGRect)rect {
//	return _descriptionButton.frame;
//}

@end
