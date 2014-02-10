//
//  JBViewController.h
//  FlappyBlock
//
//  Created by Joe Blau on 2/9/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBViewController : UIViewController <UICollisionBehaviorDelegate>
@property (strong, nonatomic) IBOutlet UIView *block;
@property (strong, nonatomic) IBOutlet UIView *ground;
@property (strong, nonatomic) IBOutlet UIView *sky;

@end
