//
//  Model.m
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import "Model.h"

@implementation Model {
    
}

-(id) initWithName: (NSString*) name Description:(NSString*) description GestureArray: (NSMutableArray*) array {
    _nameOfModel = name;
    _modelDescription = description;
    _gestureArray = array;
    
    return self;
}

@end
