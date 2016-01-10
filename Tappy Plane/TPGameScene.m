//
//  TPGameScene.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/6/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPGameScene.h"
#import "TPPlane.h"

@interface TPGameScene ()

@property (nonatomic) TPPlane *player;
@property (nonatomic) SKNode *world;

@end

@implementation TPGameScene


-(void)didMoveToView:(SKView *)view {
    // compatibility stuff with newer xcode crepas
    self.size = view.bounds.size;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // setup physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.5);
        
        // setup world
        _world = [SKNode node];
        [self addChild:_world];
        
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
        /*
        // alternate the engine on/off
        self.player.engineRunning = !self.player.engineRunning;
        // load new plane color
        [self.player setRandomColor];
         */
        
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
    [self.player update];
}

@end
