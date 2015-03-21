//
//  Model.h
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject
@property (strong, nonatomic) NSString *nameOfModel;
@property (strong, nonatomic) NSMutableArray *gestureArray;
-(id) initWithName: (NSString*) name gestureArray: (NSMutableArray*) array;

@end
