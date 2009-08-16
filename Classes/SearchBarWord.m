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
@synthesize delegate;

	
-(void)setWord:(NSString*)aWord fromContext:(NSString*)context {
	[aWord retain];
	[word release];

	BOOL wasValid = validTag;
	
	origin = [context sizeWithFont:self.font].width;
	width = [aWord sizeWithFont:self.font].width;
	
	word = aWord;
	validTag = [[Utilities toolbox] doesTagExist:aWord];
	
	/*
	 If the current word is valid then we should notify 
	 the delegate. Likewise if it previously was a valid tag
	 and now it isn't anymore then we should also notify the delegate
	 */
	if (validTag || wasValid) { [delegate notifyNewTag]; }
}

-(void)dealloc {
	[word release];
	[super dealloc];
}

@end
