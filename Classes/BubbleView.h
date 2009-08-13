//
//  BubbleView.h
//  TokenField
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBarTerm.h"

@interface BubbleView : UIView {
	SearchBarTerm * term;
	UIFont * font;
}
@property (nonatomic, retain) UIFont * font;
@property (nonatomic, retain) SearchBarTerm * term;

-(void)drawBubbleFrom:(NSInteger)x withWidth:(NSInteger)width;

@end
