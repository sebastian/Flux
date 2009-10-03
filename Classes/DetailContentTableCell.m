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
#import "KleioCustomStyles.h"

@implementation DetailContentTableCell
@synthesize what, amount, time, tags;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (BOOL) existsWhatFor:(Transaction*)trs {
	return ([[[CacheMasterSingleton sharedCacheMaster] detailTableCellData] objectForKey:[trs description]] != nil);
}
- (TTStyledTextLabel*)whatForTransaction:(Transaction*)trs {
	return [[[CacheMasterSingleton sharedCacheMaster] detailTableCellData] objectForKey:[trs description]];
}

- (void) setupWhatWithWidth:(NSInteger)maxWidth forTransaction:(Transaction*)trs {
	
	if ([self existsWhatFor:trs]) {
		return; 
	}
	
	int width = 0;
	
	maxWidth -= [@"..." sizeWithFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]].width;
	
	TTLOG(@"Setuping up the setupWhatWithWidth:%i", maxWidth);
	
	NSMutableString * text = [[[NSMutableString alloc] init] autorelease];
	
	for (NSString * tag in self.tags) {

		width += [[tag stringByAppendingString:@"   "] sizeWithFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]].width + 6;
		if (width > maxWidth) {
			[text appendFormat:@"<span class=\"tagBox\">...</span>"];		
			break;
		}
		
		NSString * tagBoxStyle;
		if ([[CacheMasterSingleton sharedCacheMaster].tagWords containsObject:tag]) {
			tagBoxStyle = @"existingTagBox";
		} else {
			tagBoxStyle = @"tagBox";
		}
		
		[text appendFormat:@"<span class=\"%@\">%@</span>   ", tagBoxStyle, tag];	
	}
	what.text = [TTStyledText textFromXHTML:text lineBreaks:NO URLs:YES];
	[what sizeToFit];
	
	[[[CacheMasterSingleton sharedCacheMaster] detailTableCellData] setObject:what forKey:[trs description]];
}

- (void) calculatePositionsForTransaction:(Transaction*)trs {
		
	topCorner.x = 0;
	topCorner.y = 0;
	
	cellSepRect.origin.x = 0;
	cellSepRect.origin.y = 39;
	cellSepRect.size.width = 288;
	cellSepRect.size.height = 1;
	
	int originY = 14;
	int margin_right = 40;
	int margin = 8;
	
	timeStartPoint.x = 30;
	timeStartPoint.y = originY;
	
	CGSize timeSize = [time sizeWithFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]];
	
	CGSize amountSize = [amount sizeWithFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]];
	
	amountFrame.size.width = amountSize.width;
	amountFrame.origin.x = 320 - margin_right - amountFrame.size.width;	
	amountFrame.origin.y = originY;
	
	if ([self existsWhatFor:trs]) {
		return;
	} else {
		// Draw what
		CGPoint whatStartPoint;
		whatStartPoint.y = originY - 2;
		whatStartPoint.x = timeStartPoint.x + timeSize.width + margin;
		int whatWidth = amountFrame.origin.x - margin - timeStartPoint.x - timeSize.width - margin;
		
		[self setupWhatWithWidth:whatWidth forTransaction:trs];
		what.frame = CGRectMake(whatStartPoint.x, whatStartPoint.y, whatWidth, what.frame.size.height);		
	}
	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

+ (void)initialize
{
	if (self == [DetailContentTableCell class])
	{
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
	}
}

- (void)dealloc {
	
	TT_RELEASE_SAFELY(time);
	TT_RELEASE_SAFELY(what);
	TT_RELEASE_SAFELY(amount);
	TT_RELEASE_SAFELY(tags);
	
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UITableViewCell

- (void)drawContentView:(CGRect)r {
			
	if (self.highlighted) {
		[[[CacheMasterSingleton sharedCacheMaster] detailTableCellSelectedBackgroundImage] drawAtPoint:topCorner];
	} else {
		[[[CacheMasterSingleton sharedCacheMaster] detailTableCellBackgroundImage] drawAtPoint:topCorner];
	}
	
	[[[CacheMasterSingleton sharedCacheMaster] detailTableCellSeparator] drawInRect:cellSepRect];
	
	// Set gray color
	[[[CacheMasterSingleton sharedCacheMaster] detailTableCellGrayColor] set];
	
	[time drawAtPoint:timeStartPoint withFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]];
	
	// Draw amount
	[amount drawInRect:amountFrame withFont:[[CacheMasterSingleton sharedCacheMaster] detailTableCellFont]];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Public

-(void)configureCellForTransaction:(Transaction*)trs {
	
	[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		
	self.time = [trs timeToString];
	self.amount = [trs amountInLocalCurrency];
	self.tags = trs.tagsArray;
	
	if (what != nil) {
		[what removeFromSuperview];
		TT_RELEASE_SAFELY(what);
	}	
	
	if ([self existsWhatFor:trs]) {
		self.what = [self whatForTransaction:trs];
		
	} else {
		self.what = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
		what.backgroundColor = [UIColor clearColor];
		what.contentInset = UIEdgeInsetsMake(2, 5, 2, 5);
		
	}
	[self addSubview:what];
	
	[self calculatePositionsForTransaction:trs];
	
	[self setNeedsDisplay];
}


@end
