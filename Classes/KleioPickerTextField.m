//
//  KleioPickerTextField.m
//  Finance
//
//  Created by Sebastian Probst Eide on 05.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "KleioPickerTextField.h"
#import <Three20/TTPickerViewCell.h>
#import <Three20/TTPickerTextField.h>
#import <Three20/TTSearchTextField.h>
#import "Utilities.h"

@implementation KleioPickerTextField

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Override of methods from super...

/*
 * Method overriden to remove cells that are clicked on.
 * Removed cells will be put into the tableview below the suggester
 */
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[super touchesBegan:touches withEvent:event];

	// Get the selected cell
	TTPickerViewCell* cell = (TTPickerViewCell*)self.selectedCell;
	// Aquire title to send to delegate
	NSString * cellTitle = [cell.label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	// Remove the cell
	[self removeSelectedCell];
	
	if (![cellTitle isEqualToString:@""] && !(cellTitle == nil)) {
		[[@"kleio://addTagToTagTable/" stringByAppendingString:cellTitle] openURL];
	}
	
}

@end
