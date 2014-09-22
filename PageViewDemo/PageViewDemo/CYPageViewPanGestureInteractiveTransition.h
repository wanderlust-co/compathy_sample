//
//  CYPageViewPanGestureInteractiveTransition.h
//  PageViewDemo
//
//  Created by James Chen on 9/21/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import "AWPercentDrivenInteractiveTransition.h"

@interface CYPageViewPanGestureInteractiveTransition : AWPercentDrivenInteractiveTransition

@property (nonatomic, readonly) UIPanGestureRecognizer *recognizer;
@property (nonatomic, copy) void (^gestureRecognizedBlock)(UIPanGestureRecognizer *recognizer);

- (id)initWithGestureRecognizerInView:(UIView *)view recognizedBlock:(void (^)(UIPanGestureRecognizer *recognizer))gestureRecognizedBlock;

@end
