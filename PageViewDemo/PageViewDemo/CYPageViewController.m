//
//  CYPageViewController.m
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import "CYPageViewController.h"
#import "CYPageViewTransitionContext.h"
#import "CYPageViewPanGestureInteractiveTransition.h"
#import "CYPageViewAnimator.h"

@interface CYPageViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, copy, readwrite) NSArray *viewControllers;
@property (nonatomic, assign) UIViewController *currentViewController;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) NSArray *gestureRecognizers;
@property (nonatomic, assign) BOOL tapEnabled;
@property (nonatomic, assign) BOOL reverse;
@property (nonatomic, strong) CYPageViewPanGestureInteractiveTransition *interactiveTransition;

@end

@implementation CYPageViewController

- (instancetype)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
    }
    return self;
}

- (void)loadView {
    UIView *rootView = [[UIView alloc] init];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.opaque = YES;

    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.opaque = YES;
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [rootView addSubview:self.containerView];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];

    self.view = rootView;

    __weak typeof(self) wself = self;
    self.interactiveTransition = [[CYPageViewPanGestureInteractiveTransition alloc] initWithGestureRecognizerInView:self.containerView
                                                                                                    recognizedBlock:^(UIPanGestureRecognizer *recognizer) {
                                                                                                        wself.reverse = [recognizer velocityInView:recognizer.view].x > 0;
                                                                                                        [wself navigate];
                                                                                                    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addGestures];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.containerView.subviews.count == 0) {
        [self transitionToChildViewController:self.viewControllers.firstObject];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    self.viewControllers = [viewControllers copy];
}

# pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]]) {
		return NO;
    }

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ((self.tapEnabled && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) ||
        [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
    	CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
        return tapPoint.x <= kTapMargin || tapPoint.x >= self.view.bounds.size.width - kTapMargin;
    }

    return YES;
}

#pragma Private Methods

-(void)setCurrentViewController:(UIViewController *)currentViewController {
    NSParameterAssert(currentViewController);
    [self transitionToChildViewController:currentViewController];
}

- (void)addGestures {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    	UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNext:)];
    	left.direction = UISwipeGestureRecognizerDirectionLeft;
    	left.delegate = self;
        [left requireGestureRecognizerToFail:self.interactiveTransition.recognizer];
    	[self.containerView addGestureRecognizer:left];

    	UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePrevious:)];
    	right.direction = UISwipeGestureRecognizerDirectionRight;
    	right.delegate = self;
        [right requireGestureRecognizerToFail:self.interactiveTransition.recognizer];
    	[self.containerView addGestureRecognizer:right];

    	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    	tap.delegate = self;
    	[self.containerView addGestureRecognizer:tap];

        self.gestureRecognizers = @[left, right, tap, self.interactiveTransition.recognizer];
    });
}

- (void)navigate {
    if (self.reverse) {
        [self gotoPreviousPage];
    } else {
        [self gotoNextPage];
    }
}

- (void)swipeNext:(UIGestureRecognizer *)gestureRecognizer {
    [self gotoNextPage];
}

- (void)swipePrevious:(UIGestureRecognizer *)gestureRecognizer {
    [self gotoPreviousPage];
}

static const CGFloat kTapMargin = 60;

- (void)tap:(UIGestureRecognizer *)gestureRecognizer {
    // TODO: make tapEanbled as public option so tap to turn page could be disabled?
    if (!self.tapEnabled) {
        return;
    }

	CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
    if (tapPoint.x <= kTapMargin) {
		[self gotoPreviousPage];
    } else if (tapPoint.x >= self.view.bounds.size.width - kTapMargin) {
		[self gotoNextPage];
    }
}

- (void)gotoPreviousPage {
    self.reverse = YES;
    UIViewController *toViewController = [self.dataSource pageViewController:self viewControllerBeforeViewController:self.currentViewController];
    [self transitionToChildViewController:toViewController];
}

- (void)gotoNextPage {
    self.reverse = NO;
    UIViewController *toViewController = [self.dataSource pageViewController:self viewControllerAfterViewController:self.currentViewController];
    [self transitionToChildViewController:toViewController];
}

- (void)transitionToChildViewController:(UIViewController *)toViewController {
    if (!toViewController) {
        return;
    }

    UIViewController *fromViewController = self.currentViewController;
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }

    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];

    if (!fromViewController) {
        [self.containerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        [self finishTransitionToChildViewController:toViewController];
        return;
    }

    CYPageViewAnimator *animator = [[CYPageViewAnimator alloc] init];
    animator.reverse = self.reverse;

    CYPageViewTransitionContext *transitionContext = [[CYPageViewTransitionContext alloc] initWithFromViewController:fromViewController
                                                                                                    toViewController:toViewController
                                                                                                          reverse:self.reverse];
    transitionContext.animated = YES;

    id<UIViewControllerInteractiveTransitioning> interactionController = [self interactionControllerForAnimator:animator];
    transitionContext.interactive = (interactionController != nil);

    transitionContext.completionBlock = ^(BOOL didComplete) {
        if (didComplete) {
            //[fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            [toViewController didMoveToParentViewController:self];
            [self finishTransitionToChildViewController:toViewController];
        } else {
            //[toViewController.view removeFromSuperview];
        }

        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
    };

    if (transitionContext.interactive) {
        [interactionController startInteractiveTransition:transitionContext];
    } else {
        [animator animateTransition:transitionContext];
        [self finishTransitionToChildViewController:toViewController];
    }
}

- (void)finishTransitionToChildViewController:(UIViewController *)toViewController {
    _currentViewController = toViewController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForAnimator:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if (self.interactiveTransition.recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition.animator = animationController;
        return self.interactiveTransition;
    } else {
        return nil;
    }
}

@end
