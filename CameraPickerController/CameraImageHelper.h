//
//  CameraImageHelper.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol AVHelperDelegate;

@interface CameraImageHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	AVCaptureSession *session;
	UIImage *image;
    AVCaptureStillImageOutput *captureOutput;
    UIImageOrientation g_orientation;
}

@property (nonatomic) id<AVHelperDelegate>delegate;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer* preview;


- (void) startRunning;
- (void) stopRunning;

- (void) takePicture;
//- (void) embedPreviewInView: (UIView *) aView;
- (void) changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@protocol AVHelperDelegate <NSObject>

-(void) didFinishedTakePicture:(UIImage*)image attachments:(CFDictionaryRef) attachments;

@optional
-(void) foucusStatus:(BOOL)isadjusting;

@end
