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
- (TTStyle*)grayToolbarButton:(UIControlState)state;
- (TTStyle*)blueToolbarButton:(UIControlState)state;

// Add amount controller
- (TTStyle*) expenseInputField;
- (TTStyle*) amountFieldStyle;

// Filter buttons
- (TTStyle*)filteringButtonActive:(UIControlState)state;
- (TTStyle*)filteringButtonPassive:(UIControlState)state;
	
@end

