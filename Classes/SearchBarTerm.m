//
//  SearchBarTerm.m
//  Finance
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "SearchBarTerm.h"
#import "Utilities.h"
#import "SearchBarWord.h"

@implementation SearchBarTerm

@synthesize font;

-(void)setText:(NSString*)text {
	
	if (searchBarWords == nil) {searchBarWords = [[NSMutableArray alloc] init];}
	
	// Split the search term into words
	NSArray * words = [[Utilities toolbox] tagStringToArray:text];
	
	// Check each existing word
	for (int n = 0; n < [words count]; n++) {

		NSString * word = [words objectAtIndex:n];
		
		NSRange range = [text rangeOfString:word];
		NSString * context = [text substringToIndex:range.location];
		
		// Are there enough words in the current search bar term array?
		if (n < [searchBarWords count]) {
			
			SearchBarWord * currentWord = [searchBarWords objectAtIndex:n];
			
			if ([word isEqualToString:currentWord.word]) {
				// The two words are equal, hence no change
			} else {
				/*
				 Two words that are not equal!
				 We should update our entry in the searchBarWords array
				 */
				[currentWord setWord:word fromContext:context];
				//[searchBarWords replaceObjectAtIndex:n withObject:sWord];
			}
			
		} else {
			
			// This word clearly does not exist
			SearchBarWord * newWord = [[SearchBarWord alloc] init];
			newWord.font = self.font;
			[newWord setWord:word fromContext:context];
			
			[searchBarWords addObject:newWord];
				
		}
	
	}
	
	// The user might delete stuff...
	if ([words count] < [searchBarWords count]) {
		if ([words count] == 0) {[searchBarWords removeAllObjects];return;}
		
		for (int n = [searchBarWords count] - 1; n >= [words count]; n--) {
			[searchBarWords removeObjectAtIndex:n];
		}
	}
}
-(void)printTheWords  {
	for (SearchBarWord * word in searchBarWords) {
		if (word.validTag) {
			NSLog(@"%@[T] ", word.word);
		} else {
			NSLog(@"%@ ", word.word);
		}
	}
}
-(NSArray*)words {
	return searchBarWords;
}

-(void)dealloc {
	[font release];
	[searchBarWords release];
	[super dealloc];
}

@end
