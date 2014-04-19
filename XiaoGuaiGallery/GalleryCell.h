//
//  GalleryCell.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-12.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryPhoto.h"

@interface GalleryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) int curLayoutType;
@property (nonatomic) GalleryPhoto* photo;
@property (weak, nonatomic) IBOutlet UIImageView *checkIcon;

@end
