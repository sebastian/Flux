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
		if (range.length == 0) {
			range = [[text lowercaseString] rangeOfString:word];
		}
		
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
			newWord.delegate = self;
			newWord.font = self.font;
			[newWord setWord:word fromContext:context];
			
			[searchBarWords addObject:newWord];
				
		}
	
	}
	
	// The user might delete stuff...
	if ([words count] < [searchBarWords count]) {
		if ([words count] == 0) {[searchBarWords removeAllObjects];[self notifyNewTag];return;}
		
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
-(NSArray*)tags {
	NSMutableArray * tags = [[NSMutableArray alloc] init];
	for (SearchBarWord * word in searchBarWords) {
		if (word.validTag) {
			[tags addObject:word];
		}
	}
	return [tags autorelease];
}
-(void)notifyNewTag {

	NSArray * tags = [self tags];
	
	NSPredicate * filteringPredicate;
	
	
	if ([tags count] == 0) {
		filteringPredicate = [NSPredicate predicateWithValue:YES];
	} else {

		NSMutableArray * tagPredicates = [[NSMutableArray alloc] init];
		
		for (SearchBarWord * tag in tags) {
			
			// Create a predicate
			NSPredicate * autotagPredicate = [NSPredicate predicateWithFormat:@"autotags contains[cd] %@", [NSString stringWithFormat:@" %@ ", tag.word]];
			NSPredicate * tagPredicate = [NSPredicate predicateWithFormat:@"tags contains[cd] %@", [NSString stringWithFormat:@" %@ ", tag.word]];
			NSPredicate * orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:tagPredicate,autotagPredicate,nil]];			

			// Add to predicate list
			[tagPredicates addObject:orPredicate];
			
		}
		
		filteringPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:tagPredicates];
		
	}
	
	NSDictionary * predicateDict = [NSDictionary dictionaryWithObject:filteringPredicate 
															   forKey:@"predicate"];
	
	NSLog(@"Sent out a filtering predicate that looks like this: %@", filteringPredicate);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KleioPredicateUpdated" 
														object:self 
													  userInfo:predicateDict];
}

-(void)clear {
	[searchBarWords removeAllObjects];
	[self notifyNewTag];
}

-(void)dealloc {
	[font release];
	[searchBarWords release];
	[super dealloc];
}

@end
