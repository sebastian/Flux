//
//  CacheMasterSingleton.m
//  Finance
//
//  Created by Sebastian Probst Eide on 21.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "CacheMasterSingleton.h"


@implementation CacheMasterSingleton

static CacheMasterSingleton *sharedCacheMaster = nil;

- (void) clearCache {

	// Clear all the cached files
	self.detailTableCellFont = nil;
	self.detailTableCellGrayColor = nil;
	self.detailTableCellBlackColor = nil;
	self.detailTableCellBackgroundImage = nil;
	self.detailTableCellSelectedBackgroundImage = nil;
	self.detailTableCellSeparator = nil;
		
}

#pragma mark
#pragma mark -
#pragma mark Shared data for Detail Content Table cell
// Detail table view cell
@synthesize detailTableCellFont;
@synthesize detailTableCellGrayColor;
@synthesize detailTableCellBlackColor;
@synthesize detailTableCellBackgroundImage;
@synthesize detailTableCellSelectedBackgroundImage;
@synthesize detailTableCellSeparator;
// Getters
- (UIFont*)detailTableCellFont {
	if (detailTableCellFont == nil) {
		detailTableCellFont = [[UIFont systemFontOfSize:12] retain];
	}
	return detailTableCellFont;
}
- (UIColor*)detailTableCellGrayColor {
	if (detailTableCellGrayColor == nil) {
		detailTableCellGrayColor = [[UIColor grayColor] retain];
	}
	return detailTableCellGrayColor;
}
- (UIColor*)detailTableCellBlackColor {
	if (detailTableCellBlackColor == nil) {
		detailTableCellBlackColor = [[UIColor blackColor] retain];
	}
	return detailTableCellBlackColor;
}
- (UIImage*)detailTableCellBackgroundImage {
	if (detailTableCellBackgroundImage == nil) {
		detailTableCellBackgroundImage = [[UIImage imageNamed:@"CellDetail.png"] retain];
	}
	return detailTableCellBackgroundImage;
}
- (UIImage*)detailTableCellSelectedBackgroundImage {
	if (detailTableCellSelectedBackgroundImage == nil) {
		detailTableCellSelectedBackgroundImage = [[UIImage imageNamed:@"CellSelectedDetail.png"] retain];
	}
	return detailTableCellSelectedBackgroundImage;
}
- (UIImage*)detailTableCellSeparator {
	if (detailTableCellSeparator == nil) {
		detailTableCellSeparator = [[UIImage imageNamed:@"CellSeparator288.png"] retain];
	}
	return detailTableCellSeparator;
}

#pragma mark
#pragma mark -
#pragma mark Singleton methods
+ (CacheMasterSingleton*)sharedCacheMaster; {
    @synchronized(self) {
        if (sharedCacheMaster == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedCacheMaster;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedCacheMaster == nil) {
            sharedCacheMaster = [super allocWithZone:zone];
            return sharedCacheMaster;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release {
    //do nothing
}
- (id)autorelease{
    return self;
}

- (void)dealloc {	
	[super dealloc];
}


@end
