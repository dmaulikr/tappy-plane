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

// particle effects
@property (nonatomic) SKEmitterNode *puffTrailEmitter;
@property (nonatomic) CGFloat puffTrailBirthEmitter;

@end


static NSString* const kKeyPlaneAnimation = @"PlaneAnimation";


@implementation TPPlane

-(instancetype)init {
    self = [super initWithImageNamed:@"planeBlue1"];
    
    if (self) {
        
        // set up a physics body
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        self.physicsBody.mass = 0.07;
        
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
        
        // set up puff trail particle effect
        NSString *particleFile = [[NSBundle mainBundle] pathForResource:@"PlanePuffTrail" ofType:@"sks"];
        _puffTrailEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:particleFile];
        _puffTrailEmitter.position = CGPointMake(-self.size.width+20.0, 0.0);
        [self addChild:self.puffTrailEmitter];
        // store the particle birth rate because we will use it later
        self.puffTrailBirthEmitter = self.puffTrailEmitter.particleBirthRate;
        // now set the particle birth rate of the emitter to 0
        // because the plane will not be in movement in the beginning
        self.puffTrailEmitter.particleBirthRate = 0;
        
        
        [self setRandomColor];
        
    }
    
    return self;
}


// SETTER METHODS


-(void)setEngineRunning:(BOOL)engineRunning {
    _engineRunning = engineRunning;
    
    if (engineRunning) {
        [self actionForKey:kKeyPlaneAnimation].speed = 1;
        self.puffTrailEmitter.particleBirthRate = self.puffTrailBirthEmitter;
    } else {
        [self actionForKey:kKeyPlaneAnimation].speed = 0;
        // turn off the smoke
        self.puffTrailEmitter.particleBirthRate = 0;
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

-(void)update {
    
    // are we accelerating? if so apply force to the physics body
    if (self.accelerating) {
        
        [self.physicsBody applyForce:CGVectorMake(0.0, 100.0)];
        
    }
    
}

@end
