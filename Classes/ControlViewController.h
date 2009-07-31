//
//  ControlViewController.h
//  Finance
//
//  Created by Sebastian Probst Eide on 31.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControlViewDelegate
@required
-(UIView*)view;
-(void)addButtonPushed;
-(void)whatButtonPushed;
@end

@interface ControlViewController : UIViewController {
	id <ControlViewDelegate> delegate;
	
	IBOutlet UIImageView * whatActive;
	IBOutlet UIImageView * addActive;
	IBOutlet UIImageView * addPulse;
	
	IBOutlet UIButton * addButton;
	IBOutlet UIButton * whatButton;
	
	BOOL animateOKButton;
}

@property (nonatomic, assign) id <ControlViewDelegate> delegate;

-(void)addControlBar;

// Normal methods
-(void)enableAddButton;
-(void)disableAddButton;


// Actions
-(IBAction)addAction;
-(IBAction)whatAction;

@end
