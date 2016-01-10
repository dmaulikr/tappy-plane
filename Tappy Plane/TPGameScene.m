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

@implementation TPGameScene {
    CGPoint _touchLocation;
}


-(void)didMoveToView:(SKView *)view {
    // compatibility stuff with newer xcode crepas
    self.size = view.bounds.size;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // setup world
        _world = [SKNode node];
        [self addChild:_world];
        
        // setup player
        _player = [[TPPlane alloc] init];
        _player.position = CGPointMake(self.size.width/2, self.size.height/2);
        _player.physicsBody.affectedByGravity = NO;
        _player.engineRunning = YES;
        [_world addChild:_player];
        
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
        
        // calculate how far touch has moved on x axis
        CGFloat xMovement = [touch locationInNode:self].x - _touchLocation.x;
        CGFloat yMovement = [touch locationInNode:self].y - _touchLocation.y;
        // move plane distance of touch
        _player.position = CGPointMake(_player.position.x + xMovement, _player.position.y + yMovement);
        
        
        // reset the _touchLocation to keep track of new position
        _touchLocation = [touch locationInNode:self];
        
    }
    
}

// method to apply the force to the plane every frame
-(void)update:(NSTimeInterval)currentTime {
    //[self.player update];
}

@end
