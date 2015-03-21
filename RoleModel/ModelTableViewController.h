//
//  ModelTableViewController.h
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "NewModelViewController.h"
#import "CompareModelViewController.h"

@interface ModelTableViewController : UITableViewController <NewModelViewControllerDelegate>, <CompareModelViewController>
@end
