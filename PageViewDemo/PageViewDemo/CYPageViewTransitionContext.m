//
//  CYPageViewTransitionContext.m
//  PageViewDemo
//
//  Created by James Chen on 9/20/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import "CYPageViewTransitionContext.h"

@interface CYPageViewTransitionContext ()

@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@property (nonatomic, assign) BOOL transitionWasCancelled;

@end

@implementation CYPageViewTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController reverse:(BOOL)reverse {
    //NSAssert([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");

    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.privateViewControllers = @{
                                        UITransitionContextFromViewControllerKey:fromViewController,
                                        UITransitionContextToViewControllerKey:toViewController,
                                        };

        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset(self.containerView.bounds, reverse ? 0 : -self.containerView.bounds.size.width, 0);
        self.privateAppearingFromRect = CGRectOffset(self.containerView.bounds, 0, 0);
    }

    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingFromRect;
    } else {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingToRect;
    } else {
        return self.privateAppearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock(didComplete);
    }
}

- (BOOL)transitionWasCancelled {
    return _transitionWasCancelled;
}

- (UIView *)viewForKey:(NSString *)key {
    return nil;
}

- (CGAffineTransform)targetTransform {
    return CGAffineTransformMake(0, 0, 0, 0, 0, 0);
}

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}

- (void)finishInteractiveTransition {
    self.transitionWasCancelled = NO;
}

- (void)cancelInteractiveTransition {
    self.transitionWasCancelled = YES;
}

@end
