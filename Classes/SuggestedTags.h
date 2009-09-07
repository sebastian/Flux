//
//  SuggestedTags.h
//  Finance
//
//  Created by Sebastian Probst Eide on 06.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SuggestedTags : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray * _items;
}
@property (nonatomic, retain) NSMutableArray * items;

@end
