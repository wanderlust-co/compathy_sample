//
//  ContentViewController.m
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.view.superview) {
        self.view.frame = self.view.superview.bounds;
    }
}

@end
