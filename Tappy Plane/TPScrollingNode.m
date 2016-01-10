//
//  TPScrollingNode.m
//  Tappy Plane
//
//  Created by Ramon Quiusky on 1/10/16.
//  Copyright © 2016 Chimi Coco. All rights reserved.
//

#import "TPScrollingNode.h"

@implementation TPScrollingNode

// method to update the position of a background sprite
-(void)updateWithTimeElapsed:(NSTimeInterval)timeElapsed {
    // only scroll the node if 'scrolling' is true
    if (self.scrolling) {
        self.position = CGPointMake(self.position.x + (self.horizontalScrollSpeed * timeElapsed), self.position.y);
    }
}

@end
