//
//  GalleryDetailControllerViewController.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-15.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryPhoto.h"

@interface GalleryDetailController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic) GalleryPhoto* photo;
@property (weak, nonatomic) IBOutlet UIImageView *imageCenterView;
@property (weak, nonatomic) IBOutlet UIImageView *imageLeftView;
@property (weak, nonatomic) IBOutlet UIImageView *imageRightView;
@property (nonatomic) NSArray* picArray;
@property (nonatomic) NSInteger curImageIndex;
@property (nonatomic) NSString* docRootPath;
@property (nonatomic) CGSize size;

@end
