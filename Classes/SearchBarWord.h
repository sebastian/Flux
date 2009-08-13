//
//  SearchBarWord.h
//  Finance
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SearchBarWord : NSObject {
	NSString * word;
	BOOL validTag;
	float origin;
	float width;
	
	UIFont * font;
}

@property (nonatomic, retain) UIFont * font; 
@property (nonatomic, readonly) NSString * word;
@property (nonatomic, readonly) BOOL validTag;
@property (nonatomic, readonly) float origin;
@property (nonatomic, readonly) float width;

-(void)setWord:(NSString*)aWord fromContext:(NSString*)context;

@end
