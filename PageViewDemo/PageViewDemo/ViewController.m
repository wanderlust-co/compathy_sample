//
//  ViewController.m
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

// See:
// http://www.appcoda.com/uipageviewcontroller-storyboard-tutorial/
// https://github.com/mpospese/MPFlipViewController
// http://www.scottlogic.com/blog/2013/09/20/creating-a-custom-flip-view-controller-transition.html
// https://markpospesel.wordpress.com/2012/05/23/anatomy-of-a-page-flip-animation/

#import "ViewController.h"
#import "CYPageViewController.h"
#import "ContentViewController.h"

@interface ViewController () <CYPageViewControllerDelegate, CYPageViewControllerDataSource>

@property (nonatomic) CYPageViewController *pageViewController;

@end

@implementation ViewController {
}

static const NSUInteger kPageCount = 5;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pageViewController = [[CYPageViewController alloc] init];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    [self.pageViewController setViewControllers:@[[self contentViewControlerAtIndex:0]] animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 80);

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (ContentViewController *)contentViewControlerAtIndex:(NSUInteger)index {
    if (index >= kPageCount) {
        return nil;
    }

    ContentViewController *contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentViewController"];
    contentViewController.imageFile = [NSString stringWithFormat:@"image%lu.jpg", index + 1];
    contentViewController.titleText = [NSString stringWithFormat:@"Page Title %lu", index + 1];
    contentViewController.pageIndex = index;
    contentViewController.view.tag = index + 1;
    return contentViewController;
}

#pragma mark - CYPageViewControllerDelegate

// TODO

#pragma mark - CYPageViewControllerDataSource

- (UIViewController *)pageViewController:(CYPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((ContentViewController *)viewController).pageIndex;
    if (index == 0) {
        return nil;
    }

    return [self contentViewControlerAtIndex:--index];
}

- (UIViewController *)pageViewController:(CYPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((ContentViewController *)viewController).pageIndex;
    if (index >= kPageCount - 1) {
        return nil;
    }

    return [self contentViewControlerAtIndex:++index];
}

@end
