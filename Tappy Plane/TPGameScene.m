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
        
        // setup world
        _world = [SKNode node];
        [self addChild:_world];
        
        // setup player
        _player = [[TPPlane alloc] init];
        _player.position = CGPointMake(self.size.width/2, self.size.height/2);
        [_world addChild:_player];
        
    }
    
    return self;
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    //for (UITouch *touch in touches) {
        // alternate the engine on/off
        self.player.engineRunning = !self.player.engineRunning;
        // load new plane color
        [self.player setRandomColor];
    //} 
    
}

@end
