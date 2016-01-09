//
//  TPPlane.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/6/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPPlane.h"

@interface TPPlane()

// hold animation actions
@property (nonatomic) NSMutableArray *planeAnimations;

@end


static NSString* const kKeyPlaneAnimation = @"PlaneAnimation";


@implementation TPPlane

-(instancetype)init {
    self = [super initWithImageNamed:@"planeBlue1"];
    
    if (self) {
        
        // init array to hold animations
        _planeAnimations = [[NSMutableArray alloc] init];
        
        // load animation plist file
        NSString *path = [[NSBundle mainBundle] pathForResource:@"PlaneAnimations" ofType:@"plist"];
        NSDictionary *animations = [NSDictionary dictionaryWithContentsOfFile:path];
        for (NSString *key in animations) {
            
            // get the animation from the array, passing it hte NSArray frames with a duration 0.4
            NSArray *textures = [animations objectForKey:key];
            SKAction *animation = [self animationFromArray:textures withDuration:0.4];
            // now add the animations to the main container
            [self.planeAnimations addObject:animation];
        
        }
        
        [self setRandomColor];
        
    }
    
    return self;
}


// SETTER METHODS


-(void)setEngineRunning:(BOOL)engineRunning {
    _engineRunning = engineRunning;
    
    if (engineRunning) {
        [self actionForKey:kKeyPlaneAnimation].speed = 1;
    } else {
        [self actionForKey:kKeyPlaneAnimation].speed = 0;
    }
}


-(SKAction*)animationFromArray:(NSArray*)textureNames withDuration:(CGFloat)duration {
    
    // create array to hold textures
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    
    // get planes atlas
    SKTextureAtlas *planesAtlas = [SKTextureAtlas atlasNamed:@"Planes"];
    
    // loop through textureNames array and load textures
    for (NSString *textureName in textureNames) {
        // get the specified texture
        SKTexture *texture = [planesAtlas textureNamed:textureName];
        // add texture in to the frames array
        [frames addObject:texture];
    }
    
    // calculate time per frame - so the entire duration divided by
    // the number of frames in the frames array so that each has equal time to run
    CGFloat frameTime = duration / (CGFloat)frames.count;
    
    // create and return animation action
    return [SKAction repeatActionForever:[SKAction animateWithTextures:frames
                                                          timePerFrame:frameTime
                                                                resize:NO
                                                               restore:NO]];
}

-(void)setRandomColor {
    
    // remove the action first
    [self removeActionForKey:kKeyPlaneAnimation];
    
    // random index from the coutn of the planeAnimations array
    int randomPlane = arc4random_uniform((int)self.planeAnimations.count);
    
    // instatiate an animation object
    SKAction *animation = [self.planeAnimations objectAtIndex:randomPlane];
    
    // run action to randomize the planes
    [self runAction:animation withKey:kKeyPlaneAnimation];
    
    // we want to stop the animation when the new random color plane is loaded
    if (!self.engineRunning) {
        self.engineRunning = NO;
        //[self actionForKey:kKeyPlaneAnimation].speed = 0;
    }
}

@end
