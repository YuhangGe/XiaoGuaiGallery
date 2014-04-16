//
//  GalleryPhoto.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-13.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GalleryPhoto : NSObject

@property(nonatomic,strong) UIImage* thumbnail;
@property(nonatomic,strong) UIImage* image;
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* imageFile;

-(void) deallocPhoto;

@end
