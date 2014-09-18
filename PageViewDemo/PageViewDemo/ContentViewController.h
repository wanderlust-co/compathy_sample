//
//  ContentViewController.h
//  PageViewDemo
//
//  Created by James Chen on 9/18/14.
//  Copyright (c) 2014 jp.co.wanderlust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *imageFile;
@property (nonatomic, assign) NSUInteger pageIndex;

@end
