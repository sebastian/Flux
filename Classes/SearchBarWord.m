//
//  SearchBarWord.m
//  Finance
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "SearchBarWord.h"
#import "Utilities.h"

@implementation SearchBarWord

@synthesize word;
@synthesize validTag;
@synthesize font;
@synthesize origin;
@synthesize width;

	
-(void)setWord:(NSString*)aWord fromContext:(NSString*)context {
	[aWord retain];
	[word release];

	origin = [context sizeWithFont:self.font].width;
	width = [aWord sizeWithFont:self.font].width;
	
	NSLog(@"Setting word '%@' (%@)", aWord, context);
	
	word = aWord;
	validTag = [[Utilities toolbox] doesTagExist:aWord];
}

-(void)dealloc {
	[word release];
	[super dealloc];
}

@end
