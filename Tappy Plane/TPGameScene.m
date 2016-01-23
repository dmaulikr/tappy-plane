//
//  TPGameScene.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/6/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPGameScene.h"
#import "TPPlane.h"
#import "TPScrollingLayer.h"
#import "TPConstants.h"


@interface TPGameScene ()

@property (nonatomic) TPPlane *player;
@property (nonatomic) SKNode *world;
@property (nonatomic) TPScrollingLayer *background;
@property (nonatomic) TPScrollingLayer *foreground;

@end


// dont drop below 10 frames per second when scrolling
static const CGFloat kMinFPS = 10.0/60.0;


@implementation TPGameScene{
    CGPoint _touchLocation;
}


-(void)didMoveToView:(SKView *)view {
    // compatibility stuff with newer xcode crepas
    self.size = view.bounds.size;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // ######################
        // set the background color
        self.backgroundColor = [SKColor colorWithRed:213.0/255.0 green:237.0/255.0 blue:247.0/255.0 alpha:1.0];
        self.view.multipleTouchEnabled = NO;
        
        // get atlas file
        SKTextureAtlas *graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
        
        
        // ######################
        // setup physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.5);
        self.physicsWorld.contactDelegate = self;
        
        
        // ######################
        // setup world
        _world = [SKNode node];
        [self addChild:_world];
        
        
        // ######################
        // set up the background layer first, add it to the world because we
        // want all other layers to be on top of the background (addChild is a stack)
        NSMutableArray *backgroundTiles = [[NSMutableArray alloc] init];
        for (int i=0; i<3; i++) {
            SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"background"]];
            [backgroundTiles addObject:tile];
        }
        
        // set up the scrolling layer
        _background = [[TPScrollingLayer alloc] initWithTiles:backgroundTiles];
        _background.horizontalScrollSpeed = -60;
        _background.scrolling = YES;
        [_world addChild:_background];
        
        
        // ######################
        // set up forground
        NSArray *foregroundTiles = @[[self generateGroundtile],
                                     [self generateGroundtile],
                                     [self generateGroundtile]];
        _foreground = [[TPScrollingLayer alloc] initWithTiles:foregroundTiles];
        _foreground.horizontalScrollSpeed = -80;
        _foreground.scrolling = YES;
        [_world addChild:_foreground];
        
        
        // ######################
        // setup player
        _player = [[TPPlane alloc] init];
        _player.position = CGPointMake(self.size.width/2, self.size.height/2);
        _player.physicsBody.categoryBitMask = kTPCategoryPlane;
        [_world addChild:_player];
        
        // new game/reset
        [self newGame];
        
        // get the screensize
        CGSize scr = self.scene.frame.size;
        
        // setup a position constraint for the plane
        SKConstraint *planeBoundries = [SKConstraint
                           positionX:[SKRange rangeWithLowerLimit:30.0 upperLimit:scr.width-30.0]
                           Y:[SKRange rangeWithLowerLimit:25.0 upperLimit:scr.height-25.0]];
        // ad the constraint to the plane
        _player.constraints = @[planeBoundries];
        
        // start the flying animation
        [_player startFlyingAnimation];
        
    }
    
    return self;
    
}

-(void)newGame {
    
    // reset the layers
    self.foreground.position = CGPointZero;
    [self.foreground layoutTiles];
    self.background.position = CGPointMake(0.0, 30.0);
    [self.background layoutTiles];
    
    // reset the plane
    [self.player reset];
    self.player.position = CGPointMake(self.size.width/2, self.size.height/2);
    self.player.physicsBody.affectedByGravity = NO;
    self.player.engineRunning = YES;
    [self.player startFlyingAnimation];
}

-(SKSpriteNode*)generateGroundtile {
    
    SKTextureAtlas *graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"groundGrass"]];
    
    // use http://insyncapp.net/SKPhysicsBodyPathGenerator.html
    //SKPhysicsBody Path Generator
    
    // set the anchor point
    sprite.anchorPoint = CGPointZero;
    
    CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
    CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 403 - offsetX, 17 - offsetY);
    CGPathAddLineToPoint(path, NULL, 369 - offsetX, 35 - offsetY);
    CGPathAddLineToPoint(path, NULL, 329 - offsetX, 33 - offsetY);
    CGPathAddLineToPoint(path, NULL, 286 - offsetX, 8 - offsetY);
    CGPathAddLineToPoint(path, NULL, 235 - offsetX, 13 - offsetY);
    CGPathAddLineToPoint(path, NULL, 203 - offsetX, 29 - offsetY);
    CGPathAddLineToPoint(path, NULL, 166 - offsetX, 20 - offsetY);
    CGPathAddLineToPoint(path, NULL, 124 - offsetX, 32 - offsetY);
    CGPathAddLineToPoint(path, NULL, 79 - offsetX, 30 - offsetY);
    CGPathAddLineToPoint(path, NULL, 44 - offsetX, 12 - offsetY);
    CGPathAddLineToPoint(path, NULL, 1 - offsetX, 16 - offsetY);
    
    // not needed:
    //CGPathCloseSubpath(path);
    
    // use bodyWithEdge instead:
    //sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    sprite.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
    sprite.physicsBody.categoryBitMask = kTPCategoryGround;
    
    // do this for debugging the path only
    //[sprite addChild:[self showDebugEdgeWithPath:path]];
    
    return sprite;
    
}

// method for testing out/debugging an edge's path
-(SKShapeNode*)showDebugEdgeWithPath:(CGMutablePathRef)path {
    // this code is VERY useful to view the path you have drawn
    SKShapeNode *bodyShape = [SKShapeNode node];
    bodyShape.path = path;
    bodyShape.strokeColor = [SKColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    bodyShape.lineWidth = 3.0;
    bodyShape.zPosition = 2.0;
    return  bodyShape;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        
        self.player.accelerating = YES;
        
        // store the touch
        _touchLocation = [touch locationInNode:self];
        
        // if plane has hit the ground or object, reset the game
        if (self.player.crashed) {
            
            [self newGame];
            
        } else {
            //self.player.accelerating = YES;
            //self.player.physicsBody.affectedByGravity = YES;
        }
        
    }
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        self.player.accelerating = NO;
    }
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        // stop the flying animation because we will need a new y point from
        // the finger movement
        [_player stopFlyingAnimation];
        
        // calculate how far touch has moved on x axis
        CGFloat xMovement = [touch locationInNode:self].x - _touchLocation.x;
        CGFloat yMovement = [touch locationInNode:self].y - _touchLocation.y;
        // move plane distance of touch
        _player.position = CGPointMake(_player.position.x + xMovement, _player.position.y + yMovement);
        
        // restart the flying animation
        if (!_player.crashed) {
            [_player startFlyingAnimation];
        }
        
        // reset the _touchLocation to keep track of new position
        _touchLocation = [touch locationInNode:self];
        
    }
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    
    if (contact.bodyA.categoryBitMask == kTPCategoryPlane) {
        [self.player collide:contact.bodyB];
    } else if (contact.bodyB.categoryBitMask == kTPCategoryPlane) {
        [self.player collide:contact.bodyA];
    }
    
}

// method to apply the force to the plane every frame
-(void)update:(NSTimeInterval)currentTime {
    
    static NSTimeInterval lastCallTime;
    NSTimeInterval timeElapsed = currentTime - lastCallTime;
    
    if (timeElapsed > kMinFPS) {
        timeElapsed = kMinFPS;
    }
    
    lastCallTime = currentTime;
    
    //[self.player update];
    
    if (!self.player.crashed) {
        [self.background updateWithTimeElapsed:timeElapsed];
        [self.foreground updateWithTimeElapsed:timeElapsed];
    }
}

@end
