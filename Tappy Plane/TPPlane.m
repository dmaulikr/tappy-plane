//
//  TPPlane.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/6/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPPlane.h"
#import "TPConstants.h"

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
        
        // set up a physics body with path instead of circle of radius
        //self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        
        
        CGFloat offsetX = self.frame.size.width * self.anchorPoint.x;
        CGFloat offsetY = self.frame.size.height * self.anchorPoint.y;
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, 43 - offsetX, 15 - offsetY);
        CGPathAddLineToPoint(path, NULL, 35 - offsetX, 35 - offsetY);
        CGPathAddLineToPoint(path, NULL, 11 - offsetX, 35 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, NULL, 10 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, NULL, 30 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 40 - offsetX, 5 - offsetY);
        
        CGPathCloseSubpath(path);
        
        self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
        self.physicsBody.mass = 0.08;
        self.physicsBody.categoryBitMask = kTPCategoryPlane;
        self.physicsBody.contactTestBitMask = kTPCategoryGround;
        // the following makes the plane only collide with the ground
        // commented out, not needed at the moment
        //self.physicsBody.collisionBitMask = kTPCategoryGround;
        
        // init array to hold animations
        _planeAnimations = [[NSMutableArray alloc] init];
        
        // load animation plist file
        NSString *animationPlistPath = [[NSBundle mainBundle] pathForResource:@"PlaneAnimations" ofType:@"plist"];
        NSDictionary *animations = [NSDictionary dictionaryWithContentsOfFile:animationPlistPath];
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


// set the engine running parameters
-(void)setEngineRunning:(BOOL)engineRunning {
    
    // if we have crashed engineRunning needs to be false
    _engineRunning = engineRunning && !self.crashed;
    
    if (engineRunning) {
        [self actionForKey:kKeyPlaneAnimation].speed = 1;
        self.puffTrailEmitter.particleBirthRate = self.puffTrailBirthEmitter;
        self.puffTrailEmitter.targetNode = self.parent;
        // need to set this because it will get drawn behind the background instead
        self.puffTrailEmitter.particleZPosition = 2.0;
    } else {
        [self actionForKey:kKeyPlaneAnimation].speed = 0;
        // turn off the smoke
        self.puffTrailEmitter.particleBirthRate = 0;
    }
}

-(void)setAccelerating:(BOOL)accelerating {
    _accelerating = accelerating && !self.crashed;
}

-(void)setCrashed:(BOOL)crashed {
    _crashed = crashed;
    
    if (crashed) {
        self.accelerating = NO;
        self.engineRunning = NO;
    }
}


// FUNCTIONAL METHODS


-(SKAction*)animationFromArray:(NSArray*)textureNames withDuration:(CGFloat)duration {
    
    // create array to hold textures
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    
    // get planes atlas
    SKTextureAtlas *planesAtlas = [SKTextureAtlas atlasNamed:@"Graphics"];
    
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
    
    // rotate the plane
    if (!self.crashed) {
        self.zRotation = fmaxf(fminf(self.physicsBody.velocity.dy, 400), -400) / 400;
    }
}

-(void)collide:(SKPhysicsBody *)body {
    
    // ignore collisions if already crashed
    if (!self.crashed) {
        // hit the ground
        if (body.categoryBitMask == kTPCategoryGround) {
            self.crashed = YES;
        }
    }
    
}

// reset the plane
-(void)reset {
    // reset plane
    self.crashed = NO;
    self.engineRunning = YES;
    
    // reset the plane rotation/velocity/etc
    self.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    self.zRotation = 0.0;
    self.physicsBody.angularVelocity = 0.0;
    
    // randomize the plane color
    [self setRandomColor];
}

@end
