//
//  ModelGraphViewController.h
//  RoleModel
//
//  Created by Brian Wang on 3/22/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
@class ModelGraphViewController;
@protocol ModelGraphViewControllerDelegate <NSObject>
-(void) modelGraphViewControllerDidClose:(ModelGraphViewController *) controller;
@end

@interface ModelGraphViewController : UIViewController<CPTPlotDataSource>
@property (weak, nonatomic) id <ModelGraphViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *rollE;
@property (strong, nonatomic) NSMutableArray *pitchE;
@property (strong, nonatomic) NSMutableArray *yawE;

@property (strong, nonatomic) NSMutableArray *aXE;
@property (strong, nonatomic) NSMutableArray *aYE;
@property (strong, nonatomic) NSMutableArray *aZE;

@property (strong, nonatomic) NSMutableArray *studentGestures;
@property (strong, nonatomic) NSMutableArray *teacherGestures;

@property (strong, nonatomic) IBOutlet UIView *subView;








-(IBAction) close;

@end
