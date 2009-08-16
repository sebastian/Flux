//
//  TagSuggesterViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 16.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagSuggesterDelegate
-(void)addTagWord:(NSString*)tag;
@end


@interface TagSuggesterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	id <TagSuggesterDelegate> delegate;
	
	NSArray * matchingTags;
	UITableView * localTableView;

	NSString * currentWord;
	
	IBOutlet UITableViewCell * cell1;
	IBOutlet UITableViewCell * cell2;
}

@property (nonatomic, retain) NSString * currentWord;
@property (nonatomic, retain) UITableView * localTableView;
@property (nonatomic, retain) NSArray * matchingTags;
@property (nonatomic, assign) id <TagSuggesterDelegate> delegate;

-(void)setTagText:(NSString*)text;
-(void)isForAddExpenseView;
-(void)isForSearchBar;
-(void)remove;

@end
