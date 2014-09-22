//
//  CYPageViewAnimator.m
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import "CYPageViewAnimator.h"

@interface CYPageViewAnimator ()

@end

@implementation CYPageViewAnimator

static const CGFloat kAnimationDuration = 1.0f;

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    if (self.reverse) {
        [[transitionContext containerView] addSubview:toViewController.view];
    } else {
        [[transitionContext containerView]insertSubview:toViewController.view belowSubview:fromViewController.view];
    }

    CGRect initialFrame = [transitionContext initialFrameForViewController:fromViewController];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / (4 * CGRectGetWidth(initialFrame));
    [transitionContext containerView].layer.sublayerTransform = transform;

    if (self.reverse) {
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, -1 * M_PI_2, 0, 1, 0);
        toViewController.view.layer.transform = transform;
        toViewController.view.layer.anchorPoint = CGPointMake(0, 0);
        toViewController.view.layer.position = CGPointMake(0, 0);
    } else {
        fromViewController.view.layer.anchorPoint = CGPointMake(0, 0);
        fromViewController.view.layer.position = CGPointMake(0, 0);
    }

    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                   delay:0.0
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:kAnimationDuration
                                                                animations:^{
                                                                    if (self.reverse) {
                                                                        toViewController.view.layer.transform = CATransform3DIdentity;
                                                                    } else {
                                                                        CATransform3D transform = CATransform3DIdentity;
                                                                        transform = CATransform3DRotate(transform, -1 * M_PI_2, 0, 1, 0);
                                                                        fromViewController.view.layer.transform = transform;
                                                                    }
                                                                }];
                              }
                              completion:^(BOOL finished) {
                                  toViewController.view.layer.transform = CATransform3DIdentity;
                                  [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                              }
     ];
}

@end
