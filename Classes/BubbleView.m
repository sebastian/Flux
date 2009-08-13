//
//  BubbleView.m
//  TokenField
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "BubbleView.h"
//#import "ConfirmationView." // For the NewPathWithRoundRect


@implementation BubbleView

@synthesize term;
@synthesize font;

- (void)drawRect:(CGRect)rect {
	NSLog(@"Bubble view was asked to draw.");
	if (term != nil) {
		for (SearchBarWord * word in [term words]) {
			if (word.validTag) {
				[self drawBubbleFrom:word.origin withWidth:word.width];
			}
		}
	}
}
-(void)drawBubbleFrom:(NSInteger)x withWidth:(NSInteger)width {

	const CGFloat cornerRadius = 5;
	const NSInteger BUBBLE_HEIGHT = 15;
	const NSInteger BUBBLE_Y_POSITION = 9;
	
	CGRect rect;
	rect.size.width = width;
	rect.size.height = BUBBLE_HEIGHT;
	
	rect.origin.y = BUBBLE_Y_POSITION;
	rect.origin.x = x;
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
					  rect.origin.x,
					  rect.origin.y + rect.size.height - cornerRadius);
	
	// Top left corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x,
						rect.origin.y,
						rect.origin.x + rect.size.width,
						rect.origin.y,
						cornerRadius);
	
	// Top right corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x + rect.size.width,
						rect.origin.y,
						rect.origin.x + rect.size.width,
						rect.origin.y + rect.size.height,
						cornerRadius);
	
	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x + rect.size.width,
						rect.origin.y + rect.size.height,
						rect.origin.x,
						rect.origin.y + rect.size.height,
						cornerRadius);
	
	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x,
						rect.origin.y + rect.size.height,
						rect.origin.x,
						rect.origin.y,
						cornerRadius);
	
	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
		
	CGPathRef roundRectPath = path; //NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	const CGFloat BACKGROUND_OPACITY = 0.5;
	CGContextSetRGBFillColor(context, 0/256.f, 255/256.f, 0/256.f, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
	
	const CGFloat STROKE_OPACITY = 0.5;
	CGContextSetRGBStrokeColor(context, 0/256.f, 100/256.f, 0/256.f, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
	
}


- (void)dealloc {
    [super dealloc];
}


@end
