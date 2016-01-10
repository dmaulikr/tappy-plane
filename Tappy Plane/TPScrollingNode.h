//
//  TPScrollingNode.h
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/10/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TPScrollingNode : SKNode

// distance to scroll per second
@property (nonatomic) CGFloat horizontalScrollSpeed;
@property (nonatomic) BOOL scrolling;

-(void)updateWithTimeElapsed:(NSTimeInterval)timeElapsed;

@end
