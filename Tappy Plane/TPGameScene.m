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


@interface TPGameScene ()

@property (nonatomic) TPPlane *player;
@property (nonatomic) SKNode *world;
@property (nonatomic) TPScrollingLayer *background;

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
        // get atlas file
        SKTextureAtlas *graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
        
        
        // ######################
        // setup physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.5);
        
        
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
        _background.position = CGPointMake(0.0, 70.0);
        _background.horizontalScrollSpeed = -60;
        _background.scrolling = YES;
        [_world addChild:_background];
        
        
        // ######################
        // setup player
        _player = [[TPPlane alloc] init];
        _player.position = CGPointMake(self.size.width/2, self.size.height/2);
        _player.physicsBody.affectedByGravity = NO;
        [_world addChild:_player];
        
        // this setter uses settings that only exist AFTER the object
        // has been added to a parent
        _player.engineRunning = YES;
        
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        self.player.accelerating = YES;
        
        // store the touch
        _touchLocation = [touch locationInNode:self];
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
        [_player startFlyingAnimation];
        
        // reset the _touchLocation to keep track of new position
        _touchLocation = [touch locationInNode:self];
        
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
    [self.background updateWithTimeElapsed:timeElapsed];

}

@end
