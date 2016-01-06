//
//  TPGameScene.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/6/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPGameScene.h"

@implementation TPGameScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        NSLog(@"Size: %f %f", size.width, size.height);
    }
    
    return self;
    
}

@end
