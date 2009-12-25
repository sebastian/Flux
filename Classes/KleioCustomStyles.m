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
#define FONT_SIZE 12.f
#define CLEAR_COLOR [UIColor clearColor]
#define BLACK_COLOR [UIColor blackColor]

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
- (TTStyle*)greenForwardButtonHighlighted:(UIControlState)state {
  TTShape* shape = [TTRoundedRightArrowShape shapeWithRadius:4.5];
	UIColor* tintColor = RGBCOLOR(153,255,153);
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

- (TTStyle*) amountFieldStyleGreen {
	return [TTSolidFillStyle styleWithColor:RGBACOLOR(53,153,53,0.4) next:
					[TTFourBorderStyle styleWithTop:RGBACOLOR(255,255,255,0.2) width:1 next:
					 [TTReflectiveFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 1) next:
						[TTLinearGradientFillStyle styleWithColor1:RGBACOLOR(53,153,53,0.7) color2:[UIColor blackColor] next:nil]]]];

					 
}


- (TTStyle*) headerView {
	UIColor* whiteishColour = RGBACOLOR(255,255,255, 0.1);
	UIColor* whiteBackground = RGBACOLOR(255,255,255, 0.05);
	return [TTFourBorderStyle styleWithTop:whiteishColour right:whiteBackground bottom:whiteishColour
																		left:whiteBackground width:1 next:
					[TTSolidFillStyle styleWithColor:whiteBackground next:
					 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(5, 5, 5, 5) next:
						[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
						 [TTSolidFillStyle styleWithColor:RGBACOLOR(255,255,255,0.1) next:nil]]]]];
}
- (UIFont*) overviewTotalFont {
	return [UIFont systemFontOfSize:14.f];
}
- (TTStyle*) overviewTotal {
	return [TTTextStyle styleWithFont:[self overviewTotalFont] 
															color:RGBACOLOR(255,255,255,0.4) 
															next:nil];
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


- (TTStyle*)tagList {
	return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 0, 0, 5) padding:UIEdgeInsetsMake(1, 5, 1, 5) next:
					 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:-1] next:
						[TTSolidFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 1) next:
						 [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12.f] color:[UIColor whiteColor] next:nil]]]];
}
- (TTStyle*)newTagList {
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:-1] next:
					[TTSolidFillStyle styleWithColor:[UIColor blackColor] next:nil]];				
}

- (TTStyle*)embossedButton:(UIControlState)state {
  if (state == UIControlStateNormal) {
		return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
			[TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
			 [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
																					 color2:RGBCOLOR(216, 221, 231) next:
				[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
				 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
					[TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
												 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
												shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else if (state == UIControlStateHighlighted) {
    return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
      [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
			 [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
																					 color2:RGBCOLOR(196, 201, 221) next:
				[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
				 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
					[TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
												 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
												shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else {
    return nil;
  }
}
- (TTStyle*)editTransactionDetailButton:(UIControlState)state {
	UIColor * borderColor = [UIColor whiteColor];
  if (state == UIControlStateNormal) {
		return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:8 topRight:8 bottomRight:0 bottomLeft:0] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
			[TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
			 [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:200 alpha:0.1] next:
				[TTFourBorderStyle styleWithTop:borderColor right:borderColor bottom:[UIColor clearColor] left:borderColor width:1 next:
				 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(6, 8, 6, 9) next:
					[TTTextStyle styleWithFont:[UIFont systemFontOfSize:15.f] color:[UIColor whiteColor]
												 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
												shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else if (state == UIControlStateHighlighted) {
    return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:8 topRight:8 bottomRight:0 bottomLeft:0] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
			[TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
			 [TTLinearGradientFillStyle styleWithColor1:[UIColor whiteColor] color2:[UIColor colorWithWhite:10 alpha:1] next:
				[TTFourBorderStyle styleWithTop:borderColor right:borderColor bottom:[UIColor clearColor] left:borderColor width:1 next:
				 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(6, 8, 6, 9) next:
					[TTTextStyle styleWithFont:[UIFont systemFontOfSize:15.f] color:[UIColor blackColor]
												 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
												shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];  } else {
    return nil;
  }
}

- (TTStyle*)descriptionField {
	return 
	
					[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 0, 0, 0) padding:UIEdgeInsetsMake(1, 1, 1, 1) next:
					[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
						 [TTTextStyle styleWithFont:[UIFont systemFontOfSize:14.f] 
																	color:[UIColor blackColor] 
												minimumFontSize:14.f 
														shadowColor:[UIColor clearColor] 
													 shadowOffset:CGSizeMake(0,0) 
													textAlignment:UITextAlignmentLeft 
											verticalAlignment:UIControlContentVerticalAlignmentTop 
													lineBreakMode:UILineBreakModeTailTruncation 
													numberOfLines:100 next:nil]]];
}
- (TTStyle*)contentBox {
	return [TTInsetStyle styleWithInset:UIEdgeInsetsMake(5, 5, 0, 5) next: 
					[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 0, 0, 0) padding:UIEdgeInsetsMake(10, 15, 0, 15) next:
					 [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:0 pointLocation:55 pointAngle:90 pointSize:CGSizeMake(12, 6)] next:
						[TTReflectiveFillStyle styleWithColor:RGBACOLOR(240, 233, 219, 1) next:
						//[TTSolidFillStyle styleWithColor:RGBACOLOR(255, 255, 255, 1) next:
						 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(5, 10, 5, 10) next:nil]]]]];
}

// Currency tag
- (TTStyle*)currencyTag {
	return 
	[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(10, 10, 5, 20) next:
	 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:-1 topRight:-1 bottomRight:-1 bottomLeft:-1] next:
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(-4, -6, -4, -6) next:
		 [TTSolidFillStyle styleWithColor:RGBACOLOR(20,20,20,0.05) next:
			[TTSolidBorderStyle styleWithColor:RGBACOLOR(0,0,0,0.1) width:1.f next:
			 [TTTextStyle styleWithFont:[UIFont systemFontOfSize:16.f] color:[UIColor blackColor] next:nil]]]]]];
}
- (TTStyle*)currencyText {
	return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(10, 10, 10, 10) next:
					[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(20, 10, 10, 10) next:
					 [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:18.f] next:nil]]];
}

// Delete button
- (TTStyle*)deleteButton:(UIControlState)state {
	return [self toolbarButtonForState:state
															 shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
													 tintColor:[UIColor redColor]
																font:nil];	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// DetailTableCell
- (CGFloat) dcFontSize {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"TextSize"] isEqualToString:@"Large"]) {
		return 16.f;
	} else {
		return 14.f;
	}
}
- (CGFloat) dcSmallFontSize {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"TextSize"] isEqualToString:@"Large"]) {
		return 14.f;
	} else {
		return 12.f;
	}
}
- (UIColor*)dcTextColour {
	return RGBCOLOR(20,20,20);
}
- (UIColor*)dcLightTextColour {
	return RGBCOLOR(100,100,100);
}
- (UIColor*)dcBackgroundColour {
	return [UIColor whiteColor];
}
- (TTStyle*)dcAreaDivider {
	return [TTSolidFillStyle styleWithColor:RGBACOLOR(200,200,200,0.2) next:
					[TTLinearGradientFillStyle styleWithColor1:RGBACOLOR(153,153,114,0.1) color2:[UIColor clearColor] next:nil]];
	 
	
}
- (TTStyle*)dcCellBackground {
	return 
	[TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
	 [TTImageStyle styleWithImage:[[CacheMasterSingleton sharedCacheMaster] detailTableCellBackgroundImage] 
									 defaultImage:[[CacheMasterSingleton sharedCacheMaster] detailTableCellBackgroundImage] 
										contentMode:UIViewContentModeScaleToFill 
													 size:CGSizeMake(320, 80) 
													 next:
		[TTSolidFillStyle styleWithColor:RGBACOLOR(255,255,255,0.3) next:
		[TTLinearGradientFillStyle styleWithColor1:[UIColor clearColor] color2:RGBACOLOR(153,153,114,0.1) next:nil]]]];
}
- (UIFont*)dcFont {
	return [UIFont systemFontOfSize:[self dcFontSize]];
}
- (UIFont*)dcSmallFont {
	return [UIFont systemFontOfSize:[self dcSmallFontSize]];
}

- (TTStyle*)dcText {
	return [TTTextStyle styleWithFont:[self dcFont] color:[UIColor blackColor] next:nil];
}
- (TTStyle*)dcTextWhite {
	return [TTTextStyle styleWithFont:[self dcFont] color:[UIColor whiteColor] next:nil];
}
- (TTStyle*)dcDetailElement {
	return	 [TTTextStyle styleWithFont:[self dcFont] 
																color:[self dcTextColour]
											minimumFontSize:[self dcFontSize]
													shadowColor:[self dcBackgroundColour]
												 shadowOffset:CGSizeMake(1, 1) 
												textAlignment:UITextAlignmentRight 
										verticalAlignment:UIControlContentVerticalAlignmentFill
												lineBreakMode:UILineBreakModeMiddleTruncation
												numberOfLines:0
																 next:nil];
}
- (TTStyle*)dcDescription {
	return [TTTextStyle styleWithFont:[self dcSmallFont] color:[self dcTextColour] next:nil];
}
- (TTStyle*)dcNoDescriptionOrTags {
	return [TTTextStyle styleWithFont:[self dcSmallFont] color:[self dcLightTextColour] next:nil];
}

// Tags
- (TTStyle*)dcTag {
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:-1] next:
					[TTSolidFillStyle styleWithColor: RGBACOLOR(255, 255, 255, 0.7) next:
					 [TTSolidBorderStyle styleWithColor:RGBACOLOR(150, 150, 150, 0.5) width:1 next:nil]]];
	
}
- (TTStyle*)dcFilteredTag {
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:-1] next:
					[TTSolidFillStyle styleWithColor: KLEIO_GREEN_COLOR next:
					 [TTSolidBorderStyle styleWithColor:KLEIO_GREEN_COLOR width:1 next:nil]]];	
}
- (TTStyle*)dcTagProcessingChange {
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:-1] next:
					[TTSolidFillStyle styleWithColor: RGBACOLOR(0,153,0, 0.3) next:
					 [TTSolidBorderStyle styleWithColor:KLEIO_GREEN_COLOR width:1 next:nil]]];
	
}
- (TTStyle*)dcTags {
	return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(10, 10, 10, 10) padding:UIEdgeInsetsMake(10, 10, 10, 10) next:nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Keyboard buttons
- (TTStyle*)numericKeyboardButton:(UIControlState)state {
  if (state == UIControlStateNormal) {
		return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
			[TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
			 [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
																					 color2:RGBCOLOR(216, 221, 231) next:
				[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
				 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
					[TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
												 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
												shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else if (state == UIControlStateHighlighted) {
    return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
      [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
			 [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
																					 color2:RGBCOLOR(196, 201, 221) next:
				[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
				 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
					[TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
												 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
												shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else {
    return nil;
  }
}

@end