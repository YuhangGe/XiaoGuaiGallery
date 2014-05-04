//
//  CameraPickerViewController.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-20.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraPickerViewDelegate;

@interface CameraPickerViewController : UIViewController

@property CGSize size;
@property(nonatomic) id<CameraPickerViewDelegate> delegate;

- (void) deletePickedImage:(UIImage*)image;

- (IBAction)pickImage:(id)sender;
- (IBAction)cancelPick:(id)sender;
- (IBAction)finishPick:(id)sender;

@end

@protocol CameraPickerViewDelegate <NSObject>

- (void) cameraPickerViewController:(CameraPickerViewController*) picker didFinishPickImages:(NSArray*) pickedImages;

@end