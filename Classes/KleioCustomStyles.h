//
//  CustomStyles.h
//  Finance
//
//  Created by Sebastian Probst Eide on 10.09.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Three20/Three20.h>


@interface KleioCustomStyles : TTDefaultStyleSheet

- (TTStyle*)blackBackwardButton:(UIControlState)state;
- (TTStyle*)blackForwardButton:(UIControlState)state;
- (TTStyle*)greenForwardButton:(UIControlState)state;
- (TTStyle*)greenForwardButtonHighlighted:(UIControlState)state;
- (TTStyle*)grayToolbarButton:(UIControlState)state;
- (TTStyle*)blueToolbarButton:(UIControlState)state;


// Add amount controller
- (TTStyle*) expenseInputField;
- (TTStyle*) amountFieldStyle;
- (TTStyle*) amountFieldStyleGreen;

// Filter buttons
- (TTStyle*)filteringButtonActive:(UIControlState)state;
- (TTStyle*)filteringButtonPassive:(UIControlState)state;
	
// Currency tag
- (TTStyle*)currencyTag;
- (TTStyle*)currencyText;

// TransactionViewer
- (TTStyle*)tagList;
- (TTStyle*)newTagList;
- (TTStyle*)filterButtonTag;
- (TTStyle*)tagBox;
- (TTStyle*)existingTagBox;
- (TTStyle*)embossedButton:(UIControlState)state;
- (TTStyle*)editTransactionDetailButton:(UIControlState)state;
- (TTStyle*)descriptionField;
- (TTStyle*)contentBox;

// Delete button
- (TTStyle*)deleteButton:(UIControlState)state;
@end

