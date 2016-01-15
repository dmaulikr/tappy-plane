//
//  TPScrollingLayer.h
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/10/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPScrollingNode.h"

@interface TPScrollingLayer : TPScrollingNode

-(instancetype)initWithTiles:(NSArray*)tileSpriteNodes;
-(void)layoutTiles;

@end
