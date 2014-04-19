//
//  AnimatedDismissTransitioning.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-19.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "AnimatedDismissTransitioning.h"
#import "GalleryViewController.h"
#import "SearchViewController.h"

@implementation AnimatedDismissTransitioning

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
//    UIView *inView = [transitionContext containerView];
//    SearchViewController *toVC = (SearchViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    GalleryViewController *fromVC = (GalleryViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //[inView addSubview:toVC.view];
    
    //    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
//    [toVC.view setAlpha:0.0];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         //
                         //                         [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                         [fromVC.view setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                         [fromVC removeFromParentViewController];
                     }];
}


@end
