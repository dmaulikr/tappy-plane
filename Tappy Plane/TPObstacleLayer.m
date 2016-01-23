//
//  TPObstacleLayer.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/23/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPObstacleLayer.h"
#import "TPConstants.h"

@interface TPObstacleLayer()

@property (nonatomic) CGFloat marker;

@end


static const CGFloat kTPMarkerBuffer = 200.0;
static const CGFloat kTPVerticalGap = 90.0;
static const CGFloat kTPSpaceBetweenObstacleSets = 180.0;

static NSString *const kTPKeyMountainUp = @"MountainUp";
static NSString *const kTPKeyMountainDown = @"MountainDown";


@implementation TPObstacleLayer

-(void)reset {
    // loop through child nodes and reposition for reuse
    for (SKNode *node in self.children) {
        node.position = CGPointMake(-1000.0, 0.0);
    }
    
    // reposition marker
    if (self.scene) {
        self.marker = self.scene.size.width + kTPMarkerBuffer;
    }
}

-(void)updateWithTimeElapsed:(NSTimeInterval)timeElapsed {
    [super updateWithTimeElapsed:timeElapsed];
    
    // find the marker's location in the scene's coordinate
    if (self.scrolling && self.scene) {
        
        // find out where marker is in scene coordinates
        CGPoint markerLocationInScene = [self convertPoint:CGPointMake(self.marker, 0.0) toNode:self.scene];
        // when marker comes on screen, add new obstacles
        if (markerLocationInScene.x - (self.scene.size.width * self.scene.anchorPoint.x)
            < self.scene.size.width + kTPMarkerBuffer) {
            
            [self addObstacleSet];
            
        }
    }
    
}

-(void)addObstacleSet {
    
    // get mountain nodes
    SKSpriteNode *mountainUp = [self getUnusedObjectForKey:kTPKeyMountainUp];
    SKSpriteNode *mountainDown = [self getUnusedObjectForKey:kTPKeyMountainDown];
    
    // calculate maximum variation
    CGFloat maxVariation = (mountainUp.size.height + mountainDown.size.height + kTPVerticalGap) - (self.ceiling - self.floor);
    CGFloat yAdjustment = (CGFloat)arc4random_uniform(maxVariation);
    
    // position the mountain nodes
    mountainUp.position = CGPointMake(self.marker, (self.floor + mountainUp.size.height/2) - yAdjustment);
    mountainDown.position = CGPointMake(self.marker, mountainUp.position.y + mountainDown.size.height + kTPVerticalGap);
    
    // reposition marker
    self.marker += kTPSpaceBetweenObstacleSets;
    
}

-(SKSpriteNode*)getUnusedObjectForKey:(NSString*)key {
    if (self.scene) {
        // get left edge of screen in local coordinates
        CGFloat leftEdgeInLocalCoords = [self.scene convertPoint:CGPointMake(-self.scene.size.width*self.scene.anchorPoint.x, 0.0) toNode:self].x;
        
        // try to find object key to the left of the screen
        for (SKSpriteNode* node in self.children) {
            if (node.name == key && node.frame.origin.x + node.frame.size.width < leftEdgeInLocalCoords) {
                // return the node
                return node;
            }
        }
    }
    
    // couldnt find an unused node with the given key
    return [self createObjectForKey:key];
}

-(SKSpriteNode*)createObjectForKey:(NSString*)key {
    
    SKSpriteNode *object = nil;
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Graphics"];
    
    if (key == kTPKeyMountainUp) {
        
        object = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"MountainGrass"]];
        
        CGFloat offsetX = object.frame.size.width * object.anchorPoint.x;
        CGFloat offsetY = object.frame.size.height * object.anchorPoint.y;
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, 55 - offsetX, 199 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 90 - offsetX, 1 - offsetY);
        
        CGPathCloseSubpath(path);
        
        //object.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
        object.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:path];
        object.physicsBody.categoryBitMask = kTPCategoryGround;
        
        [self addChild:object];
        
    } else if (key == kTPKeyMountainDown) {
        
        object = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"MountainGrassDown"]];
        
        CGFloat offsetX = object.frame.size.width * object.anchorPoint.x;
        CGFloat offsetY = object.frame.size.height * object.anchorPoint.y;
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, 0 - offsetX, 198 - offsetY);
        CGPathAddLineToPoint(path, NULL, 55 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 90 - offsetX, 198 - offsetY);
        
        CGPathCloseSubpath(path);
        
        object.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:path];
        [self addChild:object];
        
    }
    
    if (object) {
        object.name = key;
    }
    
    return object;
}

@end
