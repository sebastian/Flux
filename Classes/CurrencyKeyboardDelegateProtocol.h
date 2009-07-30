//
//  MenuProtocol.h
//  Pager
//
//  Created by Sebastian Probst Eide on 21.06.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

@protocol CurrencyKeyboardDelegate
- (void)numericButtonPressed:(NSInteger)key;
- (void)okButtonPressed;
- (void)doubleZeroButtonPressed;

- (UIView*)view;
@end