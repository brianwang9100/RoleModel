//
//  CompareModelViewController.h
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyoKit/MyoKit.h>
#import "ModelGraphViewController.h"
#import "Model.h"

@class CompareModelViewController;

@protocol CompareModelViewControllerDelegate <NSObject>
-(void) compareModelViewControllerDidClose:(CompareModelViewController *) controller;
@end

@interface CompareModelViewController : UIViewController<ModelGraphViewControllerDelegate>


@property (weak, nonatomic) id <CompareModelViewControllerDelegate> delegate;
@property (strong, nonatomic) Model *student;
@property (strong, nonatomic) Model *teacher;

@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *compareButton;

@property (strong, nonatomic) IBOutlet UILabel *syncAndLockLabel;
@property (strong, nonatomic) IBOutlet UILabel *percentError;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIButton *graphButton;


@property (strong, nonatomic) NSMutableArray *rollEarray;
@property (strong, nonatomic) NSMutableArray *pitchEarray;
@property (strong, nonatomic) NSMutableArray *yawEarray;

@property (strong, nonatomic) NSMutableArray *aXEarray;
@property (strong, nonatomic) NSMutableArray *aYEarray;
@property (strong, nonatomic) NSMutableArray *aZEarray;

@property (strong, nonatomic) NSMutableArray *studentGesturesArray;
@property (strong, nonatomic) NSMutableArray *teacherGesturesArray;

-(IBAction) compare;
-(IBAction) close;
@end
