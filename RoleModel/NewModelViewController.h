//
//  NewModelViewController.h
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyoKit/MyoKit.h>
#import "Model.h"

@class NewModelViewController;

@protocol NewModelViewControllerDelegate <NSObject>
-(void) newModelViewControllerDidClose:(NewModelViewController *) controller;
-(void) addModel: (Model *) model;
@end

@interface NewModelViewController : UIViewController
@property (weak, nonatomic) id <NewModelViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;

@property (strong, nonatomic) TLMPose *currentPose;

-(IBAction) close;

@end
