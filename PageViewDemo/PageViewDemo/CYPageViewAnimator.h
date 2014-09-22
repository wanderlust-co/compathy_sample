//
//  CYPageViewAnimator.h
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYPageViewAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign) BOOL reverse;

@end
