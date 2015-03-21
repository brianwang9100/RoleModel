//
//  CompareModelViewController.h
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@class CompareModelViewController;

@protocol CompareModelViewControllerDelegate <NSObject>
-(void) compareModelViewControllerDidClose:(CompareModelViewController *) controller;
@end

@interface CompareModelViewController : UIViewController


@property (weak, nonatomic) id <CompareModelViewControllerDelegate> delegate;
@property (strong, nonatomic) Model *student;
@property (strong, nonatomic) Model *teacher;
-(IBAction) close;
@end
