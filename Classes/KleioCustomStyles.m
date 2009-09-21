//
//  CustomStyles.m
//  Finance
//
//  Created by Sebastian Probst Eide on 10.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "KleioCustomStyles.h"
#import "CacheMasterSingleton.h"

#define KLEIO_GRAY_COLOR RGBCOLOR(80, 80, 80)
#define KLEIO_GREEN_COLOR RGBCOLOR(0,153,0)
#define KLEIO_RED_COLOR RGBACOLOR(100, 0, 0, 1)
#define KLEIO_TRANSACTION_ADD_SCREEN_BACKGROUND RGBACOLOR(0, 0, 0, 1)

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
	return [TTSolidFillStyle styleWithColor:KLEIO_TRANSACTION_ADD_SCREEN_BACKGROUND next:
					[TTInsetStyle styleWithInset:UIEdgeInsetsMake(4, 4, 5, 4) next:
					 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:13] next:
						[TTSolidFillStyle styleWithColor:RGBACOLOR(63,63,63,5) next:nil]]]];
}

- (TTStyle*) amountFieldStyle {
	return [TTSolidFillStyle styleWithColor:KLEIO_TRANSACTION_ADD_SCREEN_BACKGROUND next:
					[TTFourBorderStyle styleWithTop:RGBACOLOR(255,255,255,0.2) width:1 next:
					 [TTReflectiveFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 1) next:nil]]];
}

// Filter buttons
- (TTStyle*)filteringButtonActive:(UIControlState)state {
  return [self toolbarButtonForState:state
															 shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
													 tintColor:KLEIO_GREEN_COLOR
																font:nil];
}
- (TTStyle*)filteringButtonPassive:(UIControlState)state {
  TTStyle * returnStyle = [self toolbarButtonForState:state
															 shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
													 tintColor:KLEIO_GRAY_COLOR
																font:nil];
	return returnStyle;
}

// Tags
- (TTStyle*)filterButtonTag {
	return 
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:-1 topRight:-1 bottomRight:-1 bottomLeft:-1] next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-2, -5, -4, -5) next:
		[TTSolidFillStyle styleWithColor:RGBACOLOR(255, 255, 255, 0.2) next:
		 [TTSolidBorderStyle styleWithColor:RGBACOLOR(255,255,255,0.3) width:1.f next:
			[TTTextStyle styleWithFont:[UIFont systemFontOfSize:12.f] color:[UIColor whiteColor] next:nil]]]]];
}

- (TTStyle*)tagBox {
	return [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-2, -4, -2, -4) next:
					[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:-1] next:
					 [TTSolidFillStyle styleWithColor: RGBACOLOR(255, 255, 255, 0.7) next:
						[TTSolidBorderStyle styleWithColor:RGBACOLOR(150, 150, 150, 0.5) width:1 next:
						 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-2, 15, -4, 15) next:
							[TTTextStyle styleWithFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont] color:[UIColor blackColor] next:nil]]]]]];
					
}
- (TTStyle*)existingTagBox {
	return [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-2, -4, -2, -4) next:
					[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:-1] next:
					 [TTSolidFillStyle styleWithColor: KLEIO_GREEN_COLOR next:
						[TTSolidBorderStyle styleWithColor:KLEIO_GREEN_COLOR width:1 next:
						 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-2, 15, -4, 15) next:
							[TTTextStyle styleWithFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont] color:[UIColor whiteColor] next:nil]]]]]];
	
}

@end