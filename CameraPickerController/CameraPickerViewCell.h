//
//  CameraPickerViewCell.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-27.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraPickerViewController.h"

@interface CameraPickerViewCell : UICollectionViewCell

@property(nonatomic) UIImage* image;
@property (nonatomic) CameraPickerViewController* delegate;

@end
