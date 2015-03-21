//
//  NewModelViewController.h
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewModelViewController;

@protocol NewModelViewControllerDelegate <NSObject>
-(void) newModelViewControllerDidClose:(NewModelViewController *) controller;
@end

@interface NewModelViewController : UIViewController
@property (weak, nonatomic) id <NewModelViewControllerDelegate> delegate;
-(IBAction) close;

@end
