//
//  DetailContentTableCell.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "DetailContentTableCell.h"
#import "Transaction.h"
#import "CacheMasterSingleton.h"

@implementation DetailContentTableCell
@synthesize what, amount, time;


+ (void)initialize
{
	if(self == [DetailContentTableCell class])
	{
		// No init to do... using cache master singleton
	}
}
- (void)dealloc {
	
	[time release];
	[what release];
	[amount release];
	
    [super dealloc];
}

-(void)configureCellForTransaction:(Transaction*)trs {
	self.time = [trs timeToString];
	self.what = [trs descriptionAndTags]; 
	self.amount = [trs amountInLocalCurrency];

	NSLog(@"Calling self needs display in table cell");
	[self setNeedsDisplay];
	
}

- (void)drawContentView:(CGRect)r
{
	//CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSLog(@"Drawing table cell");
	
	CGPoint topCorner;
	topCorner.x = 0;
	topCorner.y = 0;
	
	if (self.highlighted) {
		NSLog(@"\tCell is selected");
		[[[CacheMasterSingleton sharedCacheMaster] detailTableCellSelectedBackgroundImage] drawAtPoint:topCorner];
	} else {
		NSLog(@"\tCell is not selected");
		[[[CacheMasterSingleton sharedCacheMaster] detailTableCellBackgroundImage] drawAtPoint:topCorner];
	}
	
	CGRect cellSepRect;
	cellSepRect.origin.x = 0;
	cellSepRect.origin.y = 39;
	cellSepRect.size.width = 288;
	cellSepRect.size.height = 1;
	[[[CacheMasterSingleton sharedCacheMaster] detailTableCellSeparator] drawInRect:cellSepRect];
	
	int originY = 14;
	int margin_right = 40;
	int margin = 8;
	
	CGPoint timeStartPoint;
	timeStartPoint.x = 30;
	timeStartPoint.y = originY;

	// Set gray color
	[[[CacheMasterSingleton sharedCacheMaster] detailTableCellGrayColor] set];

	// Draw time
	CGSize timeSize = [time drawAtPoint:timeStartPoint withFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]];

	// Draw amount
	CGSize amountSize = [amount sizeWithFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]];
	CGRect amountFrame;

	amountFrame.size.width = amountSize.width;
	amountFrame.origin.x = 320 - margin_right - amountFrame.size.width;	
	amountFrame.origin.y = originY;
	[amount drawInRect:amountFrame withFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]];
	
	// Set black color
	[[[CacheMasterSingleton sharedCacheMaster] detailTableCellBlackColor] set];

	// Draw what
	CGPoint whatStartPoint;
	whatStartPoint.y = originY;
	whatStartPoint.x = timeStartPoint.x + timeSize.width + margin;
	int whatWidth = amountFrame.origin.x - margin - timeStartPoint.x - timeSize.width - margin;
	
	[what drawAtPoint:whatStartPoint forWidth:whatWidth withFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont] lineBreakMode:UILineBreakModeTailTruncation];
	
}


@end
