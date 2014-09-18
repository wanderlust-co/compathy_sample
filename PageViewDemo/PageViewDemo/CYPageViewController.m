//
//  CYPageViewController.m
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import "CYPageViewController.h"

@interface CYPageViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, assign) NSArray *gestureRecognizers;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL tapEnabled;

@end

@implementation CYPageViewController

- (instancetype)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
        // TODO
        self.view.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addGestures];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    self.currentViewController = viewControllers.firstObject;
    // TODO
}

# pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]]) {
		return NO;
    }

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.animating) {
        return NO;
    }

	if ((self.tapEnabled && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) ||
        [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
    	CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
        return tapPoint.x <= kTapMargin || tapPoint.x >= self.view.bounds.size.width - kTapMargin;
    }

    return YES;
}

#pragma Private Methods

- (void)setCurrentViewController:(UIViewController *)currentViewController {
    [self.currentViewController.view removeFromSuperview];
    _currentViewController = currentViewController;
    [self.view addSubview:self.currentViewController.view];
}

- (void)addGestures {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    	UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNext:)];
    	left.direction = UISwipeGestureRecognizerDirectionLeft;
    	left.delegate = self;
    	[self.view addGestureRecognizer:left];

    	UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePrevious:)];
    	right.direction = UISwipeGestureRecognizerDirectionRight;
    	right.delegate = self;
    	[self.view addGestureRecognizer:right];

    	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    	tap.delegate = self;
    	[self.view addGestureRecognizer:tap];

    	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    	pan.delegate = self;
    	[self.view addGestureRecognizer:pan];

        self.gestureRecognizers = @[left, right, tap, pan];
    });
}

- (void)swipeNext:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.animating) {
        [self gotoNextPage];
    }
}

- (void)swipePrevious:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.animating) {
        [self gotoPreviousPage];
    }
}

static const CGFloat kTapMargin = 60;

- (void)tap:(UIGestureRecognizer *)gestureRecognizer {
    // TODO: make tapEanbled as public option so tap to turn page could be disabled?
    if (!self.tapEnabled) {
        return;
    }

    if (self.animating) {
        return;
    }

	CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
    if (tapPoint.x <= kTapMargin) {
		[self gotoPreviousPage];
    } else if (tapPoint.x >= self.view.bounds.size.width - kTapMargin) {
		[self gotoNextPage];
    }
}

- (void)pan:(UIGestureRecognizer *)gestureRecognizer {
    // TODO
}

- (void)gotoPreviousPage {
    UIViewController *viewController = [self.dataSource pageViewController:self viewControllerBeforeViewController:self.currentViewController];
    if (viewController) {
        self.currentViewController = viewController;
    }
    // TODO
}

- (void)gotoNextPage {
    UIViewController *viewController = [self.dataSource pageViewController:self viewControllerAfterViewController:self.currentViewController];
    if (viewController) {
        self.currentViewController = viewController;
    }
    // TODO
}

@end
