//
//  SuggestedTags.h
//  Finance
//
//  Created by Sebastian Probst Eide on 06.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>

@interface SuggestedTags : TTTableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray * _items;
	
	bool loading;
}
@property (nonatomic, retain) NSMutableArray * items;
@end
