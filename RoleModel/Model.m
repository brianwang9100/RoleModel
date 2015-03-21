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

-(id) initWithName: (NSString*) name gestureArray: (NSMutableArray*) array {
    _nameOfModel = name;
    _gestureArray = array;
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:_gestureArray forKey:@"gestureArray"];
    [coder encodeObject: _nameOfModel forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [super init];
    if (self != nil)
    {
        _gestureArray = [coder decodeObjectForKey:@"gestureArray"];
        _nameOfModel = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
