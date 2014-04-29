//
//  CameraPickerViewController.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-20.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraPickerViewController : UIViewController

@property CGSize size;

- (void) deletePickedImage:(UIImage*)image;

- (IBAction)pickImage:(id)sender;
- (IBAction)cancelPick:(id)sender;
- (IBAction)finishPick:(id)sender;

@end
