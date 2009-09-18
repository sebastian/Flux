//
//  CustomStyles.m
//  Finance
//
//  Created by Sebastian Probst Eide on 10.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "KleioCustomStyles.h"

#define KLEIO_GRAY_COLOR [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1]
#define KLEIO_GREEN_COLOR RGBCOLOR(0,153,0)

@implementation KleioCustomStyles

- (TTStyle*)blackBackwardButton:(UIControlState)state {
  TTShape* shape = [TTRoundedLeftArrowShape shapeWithRadius:4.5];
  UIColor* tintColor = KLEIO_GRAY_COLOR;
  return [TTSTYLESHEET toolbarButtonForState:state shape:shape tintColor:tintColor font:nil];
}

- (TTStyle*)blackForwardButton:(UIControlState)state {
  TTShape* shape = [TTRoundedRightArrowShape shapeWithRadius:4.5];
	UIColor* tintColor = KLEIO_GRAY_COLOR;
  return [TTSTYLESHEET toolbarButtonForState:state shape:shape tintColor:tintColor font:nil];
}
- (TTStyle*)greenForwardButton:(UIControlState)state {
  TTShape* shape = [TTRoundedRightArrowShape shapeWithRadius:4.5];
	UIColor* tintColor = KLEIO_GREEN_COLOR;
  return [TTSTYLESHEET toolbarButtonForState:state shape:shape tintColor:tintColor font:nil];
}


- (TTStyle*)grayToolbarButton:(UIControlState)state {
  return [self toolbarButtonForState:state
															 shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
													 tintColor:KLEIO_GRAY_COLOR
																font:nil];
}

- (TTStyle*)blueToolbarButton:(UIControlState)state {
  return [self toolbarButtonForState:state
															 shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
													 tintColor:KLEIO_GREEN_COLOR
																font:nil];
}

- (TTStyle*) expenseInputField {
	return [TTSolidFillStyle styleWithColor:[UIColor blackColor] next:
					[TTInsetStyle styleWithInset:UIEdgeInsetsMake(4, 4, 5, 4) next:
					 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:13] next:
						[TTSolidFillStyle styleWithColor:RGBACOLOR(63,63,63,5) next:nil]]]];
}

- (TTStyle*) amountFieldStyle {
	return [TTSolidFillStyle styleWithColor:[UIColor blackColor] next:nil];
}


@end