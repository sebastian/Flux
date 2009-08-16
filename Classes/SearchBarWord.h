//
//  SearchBarWord.h
//  Finance
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchBarWordDelegate
-(void)notifyNewTag;
@end



@interface SearchBarWord : NSObject {
	NSString * word;
	BOOL validTag;
	float origin;
	float width;
	
	UIFont * font;
	
	id <SearchBarWordDelegate> delegate;
}

@property (nonatomic, assign) id <SearchBarWordDelegate> delegate;
@property (nonatomic, retain) UIFont * font; 
@property (nonatomic, readonly) NSString * word;
@property (nonatomic, readonly) BOOL validTag;
@property (nonatomic, readonly) float origin;
@property (nonatomic, readonly) float width;

-(void)setWord:(NSString*)aWord fromContext:(NSString*)context;

@end
