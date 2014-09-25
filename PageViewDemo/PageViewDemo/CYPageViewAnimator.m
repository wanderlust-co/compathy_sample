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

static const CGFloat kAnimationDuration  = 0.8f;
static const CGFloat kShadowViewMaxAlpha = 0.5f;

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromViewController];

    UIView *shadowView = [[UIView alloc] initWithFrame:initialFrame];
    shadowView.backgroundColor = [UIColor blackColor];
    //NSLog(@"Transition from %ld to %ld", fromViewController.view.tag, toViewController.view.tag);

    if (self.reverse) {
        [[transitionContext containerView] addSubview:shadowView];
        [[transitionContext containerView] addSubview:toViewController.view];
    } else {
        [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
        [[transitionContext containerView] insertSubview:shadowView belowSubview:fromViewController.view];
    }

    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / (6.8 * CGRectGetWidth(initialFrame));
    [transitionContext containerView].layer.sublayerTransform = transform;

    if (self.reverse) {
        shadowView.alpha = 0;
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, -1 * M_PI_2, 0, 1, 0);
        toViewController.view.layer.transform = transform;
        toViewController.view.layer.anchorPoint = CGPointMake(0, 0);
        toViewController.view.layer.position = CGPointMake(0, 0);
        toViewController.view.layer.allowsEdgeAntialiasing = YES;
    } else {
        shadowView.alpha = kShadowViewMaxAlpha;
        fromViewController.view.layer.anchorPoint = CGPointMake(0, 0);
        fromViewController.view.layer.position = CGPointMake(0, 0);
        fromViewController.view.layer.allowsEdgeAntialiasing = YES;
    }

    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                   delay:0.0
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:kAnimationDuration
                                                                animations:^{
                                                                    if (self.reverse) {
                                                                        shadowView.alpha = kShadowViewMaxAlpha;
                                                                        toViewController.view.layer.transform = CATransform3DIdentity;
                                                                    } else {
                                                                        shadowView.alpha = 0;
                                                                        CATransform3D transform = CATransform3DIdentity;
                                                                        transform = CATransform3DRotate(transform, -1 * M_PI_2, 0, 1, 0);
                                                                        fromViewController.view.layer.transform = transform;
                                                                    }
                                                                }];
                              }
                              completion:^(BOOL finished) {
                                  shadowView.alpha = 0;
                                  [shadowView removeFromSuperview];
                                  toViewController.view.layer.transform = CATransform3DIdentity;
                                  BOOL cancelled = [transitionContext transitionWasCancelled];
                                  if (cancelled) {
                                      fromViewController.view.layer.transform = CATransform3DIdentity;
                                      [toViewController.view removeFromSuperview];
                                  } else {
                                      [fromViewController.view removeFromSuperview];
                                  }
                                  [transitionContext completeTransition:!cancelled];
                              }
     ];
}

@end
