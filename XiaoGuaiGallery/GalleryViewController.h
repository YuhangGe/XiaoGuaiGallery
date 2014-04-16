//
//  GalleryViewController.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-12.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property(nonatomic) NSMutableArray* picArray;

@property(nonatomic) int curLayoutType;

@end
