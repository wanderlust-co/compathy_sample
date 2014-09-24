//
//  CYPageViewController.h
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CYPageViewControllerDelegate, CYPageViewControllerDataSource;

@interface CYPageViewController : UIViewController

- (instancetype)init;

@property (nonatomic, assign) id <CYPageViewControllerDelegate> delegate;
@property (nonatomic, assign) id <CYPageViewControllerDataSource> dataSource;
@property (nonatomic, readonly) NSArray *gestureRecognizers;
@property (nonatomic, copy, readonly) NSArray *viewControllers;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@protocol CYPageViewControllerDelegate <NSObject>

@optional

/*
- (void)pageViewController:(CYPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers NS_AVAILABLE_IOS(6_0);

- (void)pageViewController:(CYPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (NSUInteger)pageViewControllerSupportedInterfaceOrientations:(CYPageViewController *)pageViewController;
- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(CYPageViewController *)pageViewController;
 */

@end

@protocol CYPageViewControllerDataSource <NSObject>

@required

- (UIViewController *)pageViewController:(CYPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
- (UIViewController *)pageViewController:(CYPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

@end