//
//  TPScrollingLayer.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/10/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPScrollingLayer.h"


@interface TPScrollingLayer()

@property (nonatomic) SKSpriteNode *rightmostTile;

@end


@implementation TPScrollingLayer

-(instancetype)initWithTiles:(NSArray*)tileSpriteNodes {
    
    if (self = [super init]) {
        
        for (SKSpriteNode *tile in tileSpriteNodes) {
            
            tile.anchorPoint = CGPointZero;
            tile.name = @"Tile";
            [self addChild:tile];
            
        }
        
        [self layoutTiles];
        
    }
    
    return self;
}

-(void)layoutTiles {
    self.rightmostTile = nil;
    [self enumerateChildNodesWithName:@"Tile" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
       node.position = CGPointMake(self.rightmostTile.position.x + self.rightmostTile.size.width,
                                    node.position.y);
        self.rightmostTile = (SKSpriteNode*)node;
    }];
    
}

-(void)updateWithTimeElapsed:(NSTimeInterval)timeElapsed {
    [super updateWithTimeElapsed:timeElapsed];
    
    if (self.scrolling && self.horizontalScrollSpeed < 0 && self.scene) {
        
        [self enumerateChildNodesWithName:@"Tile" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            
            // find out where node coordinates are - are they out of view on the left?
            // take position of node that is in the coordinate system of self and give back
            // as the thought that position were in the coordinate system of self.scene
            // OR what is node's position in the coordinate system of self.scene
            CGPoint nodePositionInScene = [self convertPoint:node.position toNode:self.scene];
            
            // find out if we are outside of scene
            // the conditional will give us the left hand edge of the scene.
            // OR is the righthand side of the node to the left of the scene point
            if (nodePositionInScene.x + node.frame.size.width <
                -self.scene.size.width * self.scene.anchorPoint.x) {
                
                // if the node is out of view on the left then it will now become the new
                // rightmostTile node
                node.position = CGPointMake(self.rightmostTile.position.x + self.rightmostTile.size.width,
                                            node.position.y);
                self.rightmostTile = (SKSpriteNode*)node;
                
            }
            
        }];
        
    }
}

@end
