//
//  CameraPickerView.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-28.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "CameraPickerView.h"

@implementation CameraPickerView


- (IBAction)takePicture:(id)sender {
    [self.delegate pickImage:sender];
}

- (IBAction)cancelClick:(id)sender {
    [self.delegate cancelPick:sender];
}

- (IBAction)importClick:(id)sender {
    [self.delegate finishPick:sender];
}

@end
