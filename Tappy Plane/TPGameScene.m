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


@implementation TPGameScene


-(void)didMoveToView:(SKView *)view {
    // compatibility stuff with newer xcode crepas
    self.size = view.bounds.size;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // get atlas file
        SKTextureAtlas *graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
        
        // setup physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.5);
        
        // setup world
        _world = [SKNode node];
        [self addChild:_world];
        
        
        // set up the background layer first, add it to the world because we
        // want all other layers to be on top of the background (addChild is a stack)
        NSMutableArray *backgroundTiles = [[NSMutableArray alloc] init];
        for (int i=0; i<3; i++) {
            SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"background"]];
            [backgroundTiles addObject:tile];
        }
        
        // set up the scrolling layer
        _background = [[TPScrollingLayer alloc] initWithTiles:backgroundTiles];
        _background.position = CGPointZero;
        _background.horizontalScrollSpeed = -60;
        _background.scrolling = YES;
        //_background.zPosition = 0.0;
        [_world addChild:_background];
        
        
        // setup player
        _player = [[TPPlane alloc] init];
        _player.position = CGPointMake(self.size.width/2, self.size.height/2);
        _player.physicsBody.affectedByGravity = NO;
        // setting engine running was here before:**
        //_player.engineRunning = YES;
        [_world addChild:_player];
        // ** but since now we are updating the emitter targetNode to be the parent
        // we need to make sure that the plane has a parent first before we do that
        // that is why now we are starting engine after the plane object is added
        // to its parent
        _player.engineRunning = YES;
        
    }
    
    return self;
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        self.player.accelerating = YES;
        self.player.physicsBody.affectedByGravity = YES;
    }
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        self.player.accelerating = NO;
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
    
    [self.player update];
    [self.background updateWithTimeElapsed:timeElapsed];
}

@end
