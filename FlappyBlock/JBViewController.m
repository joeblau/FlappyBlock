//
//  JBViewController.m
//  FlappyBlock
//
//  Created by Joe Blau on 2/9/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

#import "JBViewController.h"

@interface JBViewController ()

@end

#define PIPE_SPACE 200
#define PIPE_WIDTH 75
#define DEFAULT_OFFSET 320.0
#define NEPHRITIS [UIColor colorWithRed:39.0/255 green:174.0/255.0 blue:96.0/255.0 alpha:1.0]

@implementation JBViewController {
  UIView *pipeBounds;
  UIDynamicAnimator *blockAnimator;
  
  UICollisionBehavior *blockCollision;
  UICollisionBehavior *groundCollision;
  UIDynamicItemBehavior *blockDynamicProperties;
  UIDynamicItemBehavior *pipesDynamicProperties;
  UIGravityBehavior *gravity;
  UIPushBehavior *flapUp;
  UIPushBehavior *movePipes;
  int points2x;
  int lastYOffset;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Create Block Animator
  blockAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
  
  blockDynamicProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ground]];
  blockDynamicProperties.allowsRotation = NO;
  blockDynamicProperties.density = 1000;
  
  // Block gravity
  gravity = [[UIGravityBehavior alloc] initWithItems:@[self.block]];
  gravity.magnitude = 1.1;
  
  // Block flap behavior
  flapUp = [[UIPushBehavior alloc] initWithItems:@[self.block] mode:UIPushBehaviorModeInstantaneous];
  flapUp.pushDirection = CGVectorMake(0, -1.1);
  flapUp.active = NO;
  
  // Block Pipe Collision
  blockCollision = [[UICollisionBehavior alloc] initWithItems:@[self.block]];
  [blockCollision addBoundaryWithIdentifier:@"LEFT_WALL" fromPoint:CGPointMake(-1*PIPE_WIDTH, 0) toPoint:CGPointMake(-1*PIPE_WIDTH, self.view.bounds.size.height)];
  blockCollision.collisionDelegate = self;
  
  // Block Ground Collision
  groundCollision = [[UICollisionBehavior alloc] initWithItems:@[self.block, self.ground]];
  groundCollision.collisionDelegate = self;
  
  [blockAnimator addBehavior:blockDynamicProperties];
  [blockAnimator addBehavior:gravity];
  [blockAnimator addBehavior:flapUp];
  [blockAnimator addBehavior:blockCollision];
  [blockAnimator addBehavior:groundCollision];
  
  // Create Pipes Animator
  points2x = 0;
  lastYOffset = -100;
  [self generatePipesAndMove:DEFAULT_OFFSET];
  
  UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
  [self.view addGestureRecognizer:singleTapGestureRecognizer];
  [singleTapGestureRecognizer setNumberOfTapsRequired:1];
}

- (void) handleSingleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
  [flapUp setActive:YES];
}

- (void)generatePipesAndMove:(float)xOffset {
  lastYOffset = lastYOffset +  (arc4random_uniform(3)*40) * myRandom();
  lastYOffset = (lastYOffset < -200)?-200:lastYOffset;
  lastYOffset = (lastYOffset > 0)?0:lastYOffset;
  
  UIView *topPipe = [[UIView alloc] initWithFrame:CGRectMake(xOffset, lastYOffset, PIPE_WIDTH, 300)];
  [topPipe setRestorationIdentifier:@"TOP"];
  [topPipe setBackgroundColor:NEPHRITIS];
  
  [self.view addSubview:topPipe];
  UIView *bottomPipe = [[UIView alloc] initWithFrame:CGRectMake(xOffset, lastYOffset+topPipe.bounds.size.height+PIPE_SPACE, PIPE_WIDTH, 300)];
  [bottomPipe setRestorationIdentifier:@"BOTTOM"];
  [bottomPipe setBackgroundColor:NEPHRITIS];
  [self.view addSubview:bottomPipe];

  pipesDynamicProperties= [[UIDynamicItemBehavior alloc] initWithItems:@[topPipe, bottomPipe]];
  pipesDynamicProperties.allowsRotation = NO;
  pipesDynamicProperties.density = 1000;
  
  [blockCollision addItem:topPipe];
  [blockCollision addItem:bottomPipe];

  // Push Pipes across the screen
  movePipes = [[UIPushBehavior alloc] initWithItems:@[topPipe, bottomPipe] mode:UIPushBehaviorModeInstantaneous];
  movePipes.pushDirection = CGVectorMake(-2800, 0);
  movePipes.active = YES;

  [blockAnimator addBehavior:pipesDynamicProperties];
  [blockAnimator addBehavior:movePipes];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
  if ([(NSString*)identifier isEqualToString:@"LEFT_WALL"]) {
    points2x++;
    [blockCollision removeItem:item];
    [blockAnimator removeBehavior:pipesDynamicProperties];
    [blockAnimator removeBehavior:movePipes];
    if (points2x%2 == 0) [self generatePipesAndMove:DEFAULT_OFFSET];
  }
}
int myRandom() {
  return (arc4random() % 2 ? 1 : -1);
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p {
  [blockAnimator removeAllBehaviors];
  UIAlertView *gameOver = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"You Lose" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
  [gameOver show];
}

- (BOOL)shouldAutorotate {
  return NO;
}
@end
