//
//  ControlViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 31.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrencyKeyboard.h"

@protocol ControlViewDelegate
@required
-(UIView*)view;
-(void)addButtonPushed;
-(void)whatButtonPushed;
-(void)expenseIncomeSetToExpense:(BOOL)expense;
-(CurrencyKeyboard*)currencyKeyboard;

-(CGFloat)viewHeight;
@end

@interface ControlViewController : UIViewController {
	id <ControlViewDelegate> delegate;
	
	IBOutlet UIImageView * whatActive;
	IBOutlet UIImageView * addActive;
	IBOutlet UIImageView * addPulse;
	
	IBOutlet UIButton * addButton;
	IBOutlet UIButton * whatButton;
	
	IBOutlet UISegmentedControl * expenseIncomeControl;
	
	BOOL animateOKButton;
}

@property (nonatomic, assign) id <ControlViewDelegate> delegate;

-(void)addControlBar;

// Normal methods
-(void)enableAddButton;
-(void)disableAddButton;
-(void)setSelectExpenseIncomeSegment:(NSInteger)segment;
-(void)setEditMode:(BOOL)edit;

// Actions
-(IBAction)addAction;
-(IBAction)whatAction;
-(IBAction)expenseIncomeAction;

@end
