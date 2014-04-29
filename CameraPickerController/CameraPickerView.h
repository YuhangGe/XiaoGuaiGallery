//
//  CameraPickerView.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-28.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraPickerViewController.h"

@interface CameraPickerView : UIView
@property (weak, nonatomic) IBOutlet UIView *liveView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *ctrlView;

@property (nonatomic) CameraPickerViewController* delegate;

- (IBAction)takePicture:(id)sender;
- (IBAction)cancelClick:(id)sender;
- (IBAction)importClick:(id)sender;

@end
