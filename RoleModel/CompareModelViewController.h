//
//  CompareModelViewController.h
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyoKit/MyoKit.h>
#import "Model.h"

@class CompareModelViewController;

@protocol CompareModelViewControllerDelegate <NSObject>
-(void) compareModelViewControllerDidClose:(CompareModelViewController *) controller;
@end

@interface CompareModelViewController : UIViewController


@property (weak, nonatomic) id <CompareModelViewControllerDelegate> delegate;
@property (strong, nonatomic) Model *student;
@property (strong, nonatomic) Model *teacher;

@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *compareButton;

@property (strong, nonatomic) IBOutlet UILabel *syncAndLockLabel;
@property (strong, nonatomic) IBOutlet UILabel *percentError;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;


-(IBAction) compare;
-(IBAction) close;
@end
