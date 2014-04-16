//
//  GalleryDetailControllerViewController.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-15.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "GalleryDetailController.h"

//保存三个图片当前的位置
CGPoint curPosArray[] = {{0, 0}, {0, 0}, {0, 0}};
//保存三个图片移动之前的位置
CGPoint prePosArray[] = {{0, 0},{0, 0},{0,0}};
//保存三个图片当前大小。
CGSize curSizeArray[] = {{0, 0}, {0, 0}, {0,0}};
//保存当前缩放大小。
float curScale = 1.0;

const float IMAGE_SPACE = 20.0;

@interface GalleryDetailController ()
@end

@implementation GalleryDetailController


- (void)savePosArray {
    for(int i=0;i<3;i++) {
        prePosArray[i].x = curPosArray[i].x;
        prePosArray[i].y = curPosArray[i].y;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSLog(@"did load");
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageCenterView = imageView;
    
    UIImageView *imageLeftView = [[UIImageView alloc] init];
    imageLeftView.contentMode = UIViewContentModeScaleToFill;
    self.imageLeftView = imageLeftView;
    
    UIImageView *imageRightView = [[UIImageView alloc] init];
    imageRightView.contentMode = UIViewContentModeScaleToFill;
    self.imageRightView = imageRightView;
    
    
    [self showImages];
    
    [self layoutImages];
    
    /*
     * 一定要通过addSubview的方式，才能在一开始设置好imageView的位置和大小。
     */
    [self.view addSubview:imageView];
    [self.view addSubview:imageLeftView];
    [self.view addSubview:imageRightView];
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    /*
     * 旋转设备后，重新布局。
     */
    self.size = self.view.bounds.size;
    [self layoutImages];
}

-(void) animateLayoutImages:(NSTimeInterval) duration {
    [UIView animateWithDuration:duration animations:^{
        [self layoutImages];
    }];
}
/*
 * 计算图片在第idx个屏幕上的位置。如果idx==-1则是计算左边图片，0是计算当前图片，1是计算右边图片
 */
-(CGRect) calcImageOutline:(UIImage*)img index:(int)idx {
    float nw = img.size.width;
    float nh = img.size.height;
    float pw = self.size.width;
    float ph = self.size.height;
    float _w = nw, _h = nh;
    float _bx = nw / pw, _by = nh / ph;
    if(_bx>1 || _by >1) {
        if(_bx>_by) {
            _w = pw;
            _h = nh / _bx;
        } else {
            _h = ph;
            _w = nw / _by;
        }
    }
    
    float left_offset = 0;
    if(idx==-1) {
        left_offset = -(pw + IMAGE_SPACE);
    } else if(idx==1) {
        left_offset = pw + IMAGE_SPACE;
    }
    
    
    return CGRectMake( (pw-_w)/2.0+left_offset, (ph - _h) / 2.0, _w, _h);
}
 

- (void) showImages {
    NSInteger idx = self.curImageIndex;
    NSInteger total = [self.picArray count];
    if(total == 0 || idx < 0 || idx>=total) {
        return;
    }
    
    self.imageCenterView.image = [self getImageByIndex:idx];
    GalleryPhoto* p = [self.picArray objectAtIndex:idx];
    self.navigationItem.title = p.title;
    
    if(idx>0) {
        self.imageLeftView.hidden = NO;
        self.imageLeftView.image = [self getImageByIndex:idx-1];
    } else {
        self.imageLeftView.hidden = YES;
    }
    
    if(idx<total-1) {
        self.imageRightView.hidden = NO;
        self.imageRightView.image = [self getImageByIndex:idx+1];
    } else {
        self.imageRightView.hidden = YES;
    }
    
}
-(UIImage*) getImageByIndex:(NSInteger) idx {
    GalleryPhoto* p = [self.picArray objectAtIndex:idx];
    if(!p.image) {
        [self loadImage:p];
    }
    return p.image;
}

-(void) layoutImages {
    NSInteger idx = self.curImageIndex;
    NSInteger total = [self.picArray count];

    if(total == 0 || idx < 0 || idx>=total) {
        return;
    }
    
    CGRect frame = [self calcImageOutline:self.imageCenterView.image index:0];
    [self.imageCenterView setFrame:frame];
    curPosArray[1].x = frame.origin.x;
    curPosArray[1].y = frame.origin.y;
    curSizeArray[1].width = frame.size.width;
    curSizeArray[1].height = frame.size.height;
    
    if(idx>0) {
        CGRect frame = [self calcImageOutline:self.imageLeftView.image index:-1];
        [self.imageLeftView setFrame:frame];
        curPosArray[0].x = frame.origin.x;
        curPosArray[0].y = frame.origin.y;
        curSizeArray[0].width = frame.size.width;
        curSizeArray[0].height = frame.size.height;

    }
    
    if(idx<total-1) {
        CGRect frame = [self calcImageOutline:self.imageRightView.image index:1];
        [self.imageRightView setFrame:frame];
        curPosArray[2].x = frame.origin.x;
        curPosArray[2].y = frame.origin.y;
        curSizeArray[2].width = frame.size.width;
        curSizeArray[2].height = frame.size.height;

    }
    
    curScale = 1.0;
    
}

- (void) loadImage:(GalleryPhoto*) photo {
    NSString* imgPath = [self.docRootPath stringByAppendingString: photo.imageFile];
    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
    photo.image = [UIImage imageWithData:imgData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self deallocImage];
}

-(void) deallocImage {
    NSInteger idx = self.curImageIndex;
    for(int i=0;i<[self.picArray count];i++) {
        if(i==idx|| i==idx-1 ||i==idx+1) {
            continue;
        }
        [[self.picArray objectAtIndex:i] deallocPhoto];
    }
}

-(void) switchRightImage {
    [self switchRightImage:0.5];
    
}
-(void) switchRightImage:(NSTimeInterval)duration{
    if(self.curImageIndex>=[self.picArray count]-1) {
        return;
    }
    self.curImageIndex++;
    
    [UIView animateWithDuration:duration animations:^{
        [self setImagePosition:self.imageRightView position:[self calcDestPosition:self.imageRightView dest:0]];
        [self setImagePosition:self.imageCenterView position:[self calcDestPosition:self.imageCenterView dest:-1]];
    } completion:^(BOOL finished) {
        [self showImages];
        [self layoutImages];
    }];
}
/**
 *
 */
-(CGPoint) calcDestPosition:(UIImageView*) imgView dest:(int)dest {
    CGRect frame = imgView.frame;
    float w = frame.size.width, y = frame.origin.y;
    float PW = self.size.width;
    float dst_x = 0;
    if(dest==-1) {
        dst_x = -IMAGE_SPACE-w;
    } else if(dest == 0) {
        dst_x = (PW - w) / 2;
    } else if(dest == 1) {
        dst_x = PW + IMAGE_SPACE;
    }
    return CGPointMake(dst_x, y);
}

-(void) switchLeftImage {
    [self switchLeftImage:0.5];
}

-(void) switchLeftImage:(NSTimeInterval)duration {
    if(self.curImageIndex<=0) {
        return;
    }
    
    self.curImageIndex--;
    
    [UIView animateWithDuration:duration animations:^{
        [self setImagePosition:self.imageLeftView position:[self calcDestPosition:self.imageLeftView dest:0]];
        [self setImagePosition:self.imageCenterView position:[self calcDestPosition:self.imageCenterView dest:1]];
    } completion:^(BOOL finished) {
        [self showImages];
        [self layoutImages];
    }];

}

-(void) setImagePosition:(UIImageView*) imgView left:(float) left top:(float)top{
    CGRect frame = imgView.frame;
    frame.origin.x = left;
    frame.origin.y = top;
    [imgView setFrame:frame];
}

-(void) setImagePosition:(UIImageView*) imgView position:(CGPoint) position {
    [self setImagePosition:imgView left:position.x top:position.y];
}

-(void) scaleImage:(CGPoint) center prevScale:(float) prevScale{
    CGPoint pp = prePosArray[1];
    
    float _ox = (- pp.x + center.x) / prevScale;
    float _oy = (- pp.y + center.y) / prevScale;
    float _nox = _ox * curScale;
    float _noy = _oy * prevScale;
    curPosArray[1].x = center.x - _nox;
    curPosArray[1].y = center.y - _noy;
    
    CGRect frame = self.imageCenterView.frame;
    frame.origin.x = curPosArray[1].x;
    frame.origin.y = curPosArray[1].y;
    frame.size.width = curSizeArray[1].width * curScale;
    frame.size.height = curSizeArray[1].height * curScale;
    
    [self.imageCenterView setFrame:frame];
 
}

-(void) adjustPosition:(NSTimeInterval) duration {
    float PW = self.size.width;
    float PH = self.size.height;
    CGSize cs = curSizeArray[1];
    CGPoint cp = curPosArray[1];
    
    float w = cs.width * curScale;
    float h = cs.height * curScale;
    float m_x = 0;
    float m_y = 0;
    if(w<PW) {
        m_x = floor((PW-w)/2);
    }
    if(h<PH) {
        m_y = floor((PH-h)/2);
    }
    float left = cp.x, top = cp.y;
    float right = PW - (left + w), bottom = PH - (top+h);
    
    if(left>m_x || right>m_x) {
        if(left>m_x) {
            curPosArray[1].x = m_x;
        } else {
            curPosArray[1].x = PW - m_x - w;
        }
    }
    if(top>m_y || bottom>m_y) {
        if(top>m_y) {
            curPosArray[1].y = m_y;
        } else {
            curPosArray[1].y = PH - m_y - h;
        }
    }
    
    NSInteger curIdx = self.curImageIndex;
    if(curIdx>0) {
        //如果当前不是第一张图片，检测左边的图片
        cs = curSizeArray[0];
        cp = curPosArray[0];
        if(cp.x + cs.width / 2 > 0) {
            //如果左边的图上已经拖动来一半到了当前屏幕，则认为要切换左边图片
            [self switchLeftImage];
            return;
        }
        curPosArray[0].x =  ((PW - cs.width) / 2 - (PW + 20 - fmin(0, curPosArray[1].x)));
    }
    
    if(curIdx<[self.picArray count]-1) {
        //如果当前不是最后一张
        cs = curSizeArray[2];
        cp = curPosArray[2];
        if(cp.x + cs.width / 2 < PW) {
            //如果右边的图片已经拖到了一半
            [self switchRightImage];
            return;
        }
        curPosArray[2].x = (PW-cs.width)/2 + (PW + 20 + fmax(0, curPosArray[1].x+w-PW));
    }
    [UIView animateWithDuration:duration animations:^{
        [self setImagePosition:self.imageCenterView position:curPosArray[1]];
        [self setImagePosition:self.imageLeftView position:curPosArray[0] ];
        [self setImagePosition:self.imageRightView position:curPosArray[2]];
    } completion:nil];
    

}

//#pragma mark - Navigation
//
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
////    self.imageLeftView.hidden = YES;
////    self.imageRightView.hidden = YES;
//}


#pragma mark - Gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		[gestureRecognizer addTarget:self action:@selector(pinchGestureAction:)];
	} else if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        [gestureRecognizer addTarget:self action:@selector(tappedGestureAction:)];
    } else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        [gestureRecognizer addTarget:self action:@selector(panGestureAction:)];
    }
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

//- (void)rotateGestureAction:(UIRotationGestureRecognizer *)rotate {
//    if (rotate.state == UIGestureRecognizerStateBegan) {
//        prevRotation = 0.0;
//    }
//    
//    float thisRotate = rotate.rotation - prevRotation;
//    prevRotation = rotate.rotation;
//    self.view.transform = CGAffineTransformRotate(self.view.transform, thisRotate);
//}

- (void)pinchGestureAction:(UIPinchGestureRecognizer *)pinch {
    static float prevScale;
    static CGPoint pinchCenter;
	if (pinch.state == UIGestureRecognizerStateBegan) {
        prevScale = curScale;
        pinchCenter = [pinch locationInView:self.view.superview];
        NSLog(@"%@", NSStringFromCGPoint(pinchCenter));
    }

    NSLog(@"scale");
    float scale = pinch.scale * prevScale;
    if (scale>0.2 && scale<= 5.0) {
        curScale = scale;
        [self scaleImage:pinchCenter prevScale:prevScale];
    }
    
    if(pinch.state == UIGestureRecognizerStateEnded) {
        if(curSizeArray[1].width * curScale<350 && curSizeArray[1].height*curScale<350) {
            //如果图片被缩小到一定程度（宽高都小于350），那么认为用户想要退回到主页面
            
        } else {
            [self adjustPosition:0.4];
        }
    }
    
}

-(void)panGestureAction:(UIPanGestureRecognizer *)pan {
    static CGPoint prevPanPoint;
    if (pan.state == UIGestureRecognizerStateBegan){
        prevPanPoint = [pan locationInView:self.view.superview];
        [self savePosArray];
    }
//
    CGPoint curr = [pan locationInView:self.view.superview];
//    
	float diffx = curr.x - prevPanPoint.x;
    float diffy = curr.y - prevPanPoint.y;
    
    /*
     * 中间的图片需要把x,y 都移动，而左右的图片只需要移动x让用户可以看到
     */
    for(int i=0;i<3;i++) {
        curPosArray[i].x = prePosArray[i].x + diffx;
    }
    curPosArray[1].y = prePosArray[1].y + diffy;
    
    [self setImagePosition:self.imageCenterView left:curPosArray[1].x top:curPosArray[1].y];
    [self setImagePosition:self.imageLeftView left:curPosArray[0].x top:curPosArray[0].y];
    [self setImagePosition:self.imageRightView left:curPosArray[2].x top:curPosArray[2].y];

//    NSLog(@"pan: %f, %f", diffx, diffy);

    if(pan.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"pan: %f, %f", diffx, [pan velocityInView:self.view.superview].x);
        if(fabs(diffx)<20) {
            //认为是tag，不响应. 恢复到初始位置。
            [self animateLayoutImages:0.2];
            return;
        }
        if(fabs([pan velocityInView:self.view.superview].x) > 300) {
            //认为是swipe.
            if(diffx>0 && self.curImageIndex>0) {
                [self switchLeftImage: 0.3];
            } else if(diffx<0 && self.curImageIndex<[self.picArray count]-1) {
                [self switchRightImage: 0.3];
            } else {
                [self animateLayoutImages:0.2];
            }
            return;
        }
        
        NSTimeInterval duration = diffx / 800;
        
        [self adjustPosition:duration];
    }
    

}

-(void)tappedGestureAction:(UITapGestureRecognizer *)tap{
    NSLog(@"tap");
    /*
     * 想要把status bar和navigation bar同步淡入淡出，似乎没有靠谱的方法。网上能找到的各种方法，
     * 经过试验，如下的代码是表现最接近预期的。
     * 真正完全的同步淡入淡出是ios上面原生photo app在全屏查看图片时的表现，可惜似乎没有开放API可以做到这一点。
     */
    if(self.navigationController.isNavigationBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

        [UIView animateWithDuration:0.5 animations:^ {
            self.navigationController.navigationBar.alpha = 1.0;
        } completion:^(BOOL finished){
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }];
    } else {
        [UIView transitionWithView: self.navigationController.view
                          duration: 0.3
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^{
                            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                            [self.navigationController setNavigationBarHidden: YES animated: NO];
                        }
                        completion: nil ];
    }
    
}

-(void)swipeGestureAction:(UISwipeGestureRecognizer*)swipe {
    NSLog(@"swipe");
    if(swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self switchRightImage];
    } else if(swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [self switchLeftImage];
    }
}

@end
