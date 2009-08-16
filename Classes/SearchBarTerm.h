//
//  SearchBarTerm.h
//  Finance
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchBarWord.h"

@interface SearchBarTerm : NSObject <SearchBarWordDelegate> {
	NSMutableArray * searchBarWords;
	UIFont * font;
}

@property (nonatomic, retain) UIFont * font;

-(void)setText:(NSString*)text;

-(void)printTheWords;
-(NSArray*)words;
-(void)notifyNewTag;
-(NSArray*)tags;

// Clears all the tags away
-(void)clear;

@end
