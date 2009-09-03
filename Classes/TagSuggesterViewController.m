//
//  TagSuggesterViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 16.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TagSuggesterViewController.h"
#import <CoreData/CoreData.h>
#import "Utilities.h"
#import "Tag.h"
#import "FinanceAppDelegate.h"


@interface TagSuggesterViewController (PrivateMethods)
-(void)setLocation:(CGPoint)point;	
@end



@implementation TagSuggesterViewController

@synthesize delegate;
@synthesize matchingTags;
@synthesize localTableView;
@synthesize currentWord;


- (id) init {
	self = [super initWithNibName:@"TagSuggesterViewController" bundle:[NSBundle mainBundle]];
	if (self != nil) {
		FinanceAppDelegate * app = (FinanceAppDelegate*)[[UIApplication sharedApplication] delegate];
		[app.window addSubview:self.view];
		self.view.hidden = YES;
	}
	return self;
}
- (void) dealloc {
	self.delegate = nil;
	self.view.hidden = YES;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)remove {
	[self.view removeFromSuperview];
	self.view.hidden = YES;
}

-(void)setTagText:(NSString*)text {
	NSArray * words = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString * word = [words lastObject];
	
	self.currentWord = word;
		
	self.matchingTags = [[Utilities toolbox] twoTagsStartingWith:word];
		
	[self.localTableView reloadData];
	
	if ((![word isEqualToString:@""]) && ([self.matchingTags count] > 0)){
		self.view.hidden = NO;
	} else {
		self.view.hidden = YES;
	}
	
}


-(void)isForAddExpenseView {
	[self setLocation:CGPointMake(115.f, 84.f)];
}
-(void)isForSearchBar {
	[self setLocation:CGPointMake(30.f, 53.f)];
	[self.view.superview bringSubviewToFront:self.view];
}
-(void)isForEditView:(UIView*)theView {
	[self.view removeFromSuperview];
	[theView addSubview:self.view];
	[theView bringSubviewToFront:self.view];
	[self setLocation:CGPointMake(125.f, 355.f)];
}
-(void)setLocation:(CGPoint)point {
	CGRect frame = self.view.frame;
	frame.origin = point;
	self.view.frame = frame;
}


#pragma mark
#pragma mark -
#pragma mark UITableView datasource and delegate	
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.localTableView == nil) {
		self.localTableView = tableView;
		CGRect frame = tableView.frame;
		frame.origin.x = 5;
		frame.origin.y = 2;
		tableView.frame = frame;
		[self.localTableView setBackgroundColor:[UIColor clearColor]];
	}
	
	if (self.matchingTags == nil) {
		return 0;
	} else {
		return [self.matchingTags count];
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell * cell;
	
	switch (indexPath.row) {
		case 0:
			cell = cell1;
			break;
		case 1:
			cell = cell2;
			break;
	}
	
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textLabel.text = ((Tag*)[self.matchingTags objectAtIndex:indexPath.row]).name;	
    return cell;
}	
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString * tag = ((Tag*)[self.matchingTags objectAtIndex:indexPath.row]).name;
	
	/*
	 Why this range biz?
	 Consider the suggested word: popcorn. 
	 Type in p and get suggested popcorn. When selecting popcorn from the dropdown menu opcorn should be added.
	 If I just to a search and replace for p in the whole tag name then ocorn is added instead!
	 */
	NSRange replacementRange;
	replacementRange.length = [self.currentWord length];
	replacementRange.location = 0;
	
	tag = [tag stringByReplacingOccurrencesOfString:self.currentWord withString:@"" options:NSCaseInsensitiveSearch range:replacementRange];
	tag = [tag stringByAppendingFormat:@" "];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.delegate addTagWord:tag];
	self.matchingTags = nil;
	[tableView reloadData];
	self.view.hidden = YES;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 25.f;
}

@end
