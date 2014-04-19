//
//  GalleryCell.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-12.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "GalleryCell.h"
#import "GalleryPhoto.h"
#import "Layout.h"

@interface GalleryCell()

@end

@implementation GalleryCell

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

-(void) setPhoto:(GalleryPhoto *)photo {
    
    if(_photo != photo) {
        _photo = photo;
    }
    self.imageView.image = _photo.thumbnail;
    self.titleLabel.text = _photo.title;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect nf = self.titleLabel.frame;
    nf.size.height = LAYOUT_TITLE_HEIGHT[self.curLayoutType];
    self.titleLabel.frame = nf;
    [self.titleLabel setFont:[UIFont systemFontOfSize:LAYOUT_TITLE_FONTSIZE[self.curLayoutType]]];
    self.checkIcon.hidden = self.isSelected ? NO : YES;
}

- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.checkIcon.hidden = selected ? NO : YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    NSLog(@"c draw");
//}


@end
