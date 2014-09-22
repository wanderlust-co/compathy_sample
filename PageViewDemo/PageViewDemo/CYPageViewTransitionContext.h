//
//  CYPageViewTransitionContext.h
//  PageViewDemo
//
//  Created by James Chen on 9/20/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYPageViewTransitionContext : NSObject <UIViewControllerContextTransitioning>

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController reverse:(BOOL)reverse;
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

@end
