//
//  CameraPickerViewCell.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-27.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "CameraPickerViewCell.h"


@interface CameraPickerViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CameraPickerViewCell



//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (IBAction)deleteClick:(id)sender {
    [self.delegate deletePickedImage:self.image];
}

@end
