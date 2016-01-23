//
//  TPObstacleLayer.h
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/23/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPScrollingNode.h"

@interface TPObstacleLayer : TPScrollingNode

@property (nonatomic) CGFloat floor;
@property (nonatomic) CGFloat ceiling;

-(void)reset;

@end
