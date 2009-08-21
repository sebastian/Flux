//
//  CacheMasterSingleton.h
//  Finance
//
//  Created by Sebastian Probst Eide on 21.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CacheMasterSingleton : NSObject {

	// Detail table cell
	UIFont * detailTableCellFont;
	UIColor * detailTableCellGrayColor;
	UIColor * detailTableCellBlackColor;
	UIImage * detailTableCellBackgroundImage;
	UIImage * detailTableCellSelectedBackgroundImage;
	UIImage * detailTableCellSeparator;	
	
}

// The one public init method
+ (CacheMasterSingleton*)sharedCacheMaster;
- (void) clearCache;


#pragma mark Shared data for Detail Content Table cell
@property (nonatomic, retain) UIFont * detailTableCellFont;
@property (nonatomic, retain) UIColor * detailTableCellGrayColor;
@property (nonatomic, retain) UIColor * detailTableCellBlackColor;
@property (nonatomic, retain) UIImage * detailTableCellBackgroundImage;
@property (nonatomic, retain) UIImage * detailTableCellSelectedBackgroundImage;
@property (nonatomic, retain) UIImage * detailTableCellSeparator;

- (UIFont*)detailTableCellFont;
- (UIColor*)detailTableCellGrayColor;
- (UIColor*)detailTableCellBlackColor;
- (UIImage*)detailTableCellBackgroundImage;
- (UIImage*)detailTableCellSelectedBackgroundImage;
- (UIImage*)detailTableCellSeparator;


@end
