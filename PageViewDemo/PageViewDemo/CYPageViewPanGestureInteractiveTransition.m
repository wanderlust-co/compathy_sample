//
//  CYPageViewPanGestureInteractiveTransition.m
//  PageViewDemo
//
//  Created by James Chen on 9/21/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import "CYPageViewPanGestureInteractiveTransition.h"

@implementation CYPageViewPanGestureInteractiveTransition {
    BOOL _leftToRightTransition;
}

- (id)initWithGestureRecognizerInView:(UIView *)view recognizedBlock:(void (^)(UIPanGestureRecognizer *recognizer))gestureRecognizedBlock {
    self = [super init];
    if (self) {
        _gestureRecognizedBlock = [gestureRecognizedBlock copy];
        _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [view addGestureRecognizer:_recognizer];
    }
    return self;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];

    _leftToRightTransition = [_recognizer velocityInView:_recognizer.view].x > 0;
}

- (void)pan:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.gestureRecognizedBlock(recognizer);
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGFloat d = translation.x / CGRectGetWidth(recognizer.view.bounds);
        if (!_leftToRightTransition) {
            d *= -1;
        }
        [self updateInteractiveTransition:d * 1.0];
    } else if (recognizer.state >= UIGestureRecognizerStateEnded) {
        if (self.percentComplete > 0.4) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }
}

@end
