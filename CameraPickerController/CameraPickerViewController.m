//
//  CameraPickerViewController.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-20.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "CameraPickerViewController.h"
#import "CameraImageHelper.h"
#import "CameraPickerViewCell.h"
#import "CameraLayout.h"
#import "CameraPickerView.h"

NSString* const CameraPickerCellIdentifier_iPhone_portrait = @"CameraPickerCell_iPhone_portrait";
NSString* const CameraPickerCellIdentifier_iPad_portrait = @"CameraPickerCell_iPad_portrait";
NSString* const CameraPickerCellIdentifier_iPhone_landscape = @"CameraPickerCell_iPhone_landscape";
NSString* const CameraPickerCellIdentifier_iPad_landscape = @"CameraPickerCell_iPad_landscape";


@interface CameraPickerViewController ()
<AVHelperDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(retain,nonatomic) CameraImageHelper *CameraHelper;
//@property (weak, nonatomic) IBOutlet UIView *liveView;
//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (weak, nonatomic) IBOutlet UIView *ctrlView;

@property(nonatomic) NSMutableArray* pickedImageArray;

@property(nonatomic) NSInteger curLayoutType;


@property(nonatomic) CameraPickerView* portraitView;
@property(nonatomic) CameraPickerView* landscapeView;
@property(nonatomic) UICollectionView* collectionView;

@property(nonatomic) NSString* CameraViewCellIdentifier;

@end

@implementation CameraPickerViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.pickedImageArray) {
        self.pickedImageArray = [[NSMutableArray alloc] init];
    }
    
    [self setupLayout:[[UIApplication sharedApplication] statusBarOrientation]];
    
   
    
    if(!self.portraitView || !self.landscapeView) {
        NSArray *pnib;
        NSArray *lnib;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            pnib = [[NSBundle mainBundle]loadNibNamed:@"CameraPickerView_iPhone_portrait" owner:self options:nil];
            lnib = [[NSBundle mainBundle]loadNibNamed:@"CameraPickerView_iPhone_landscape" owner:self options:nil];
            self.portraitView = [pnib objectAtIndex:0];
            self.landscapeView = [lnib objectAtIndex:0];
            
            [self.portraitView.collectionView registerNib:[UINib nibWithNibName:CameraPickerCellIdentifier_iPhone_portrait bundle:nil] forCellWithReuseIdentifier:CameraPickerCellIdentifier_iPhone_portrait];
            [self.landscapeView.collectionView registerNib:[UINib nibWithNibName:CameraPickerCellIdentifier_iPhone_landscape bundle:nil] forCellWithReuseIdentifier:CameraPickerCellIdentifier_iPhone_landscape];
        } else {
            pnib = [[NSBundle mainBundle]loadNibNamed:@"CameraPickerView_iPad_portrait" owner:self options:nil];
            lnib = [[NSBundle mainBundle]loadNibNamed:@"CameraPickerView_iPad_landscape" owner:self options:nil];
            self.portraitView = [pnib objectAtIndex:0];
            self.landscapeView = [lnib objectAtIndex:0];
            
            [self.portraitView.collectionView registerNib:[UINib nibWithNibName:CameraPickerCellIdentifier_iPad_portrait bundle:nil] forCellWithReuseIdentifier:CameraPickerCellIdentifier_iPad_portrait];
            [self.landscapeView.collectionView registerNib:[UINib nibWithNibName:CameraPickerCellIdentifier_iPad_landscape bundle:nil] forCellWithReuseIdentifier:CameraPickerCellIdentifier_iPad_landscape];
        }
        
        
    }
    
   
    
    CGRect frame = self.portraitView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.portraitView.frame = frame;
    frame = self.landscapeView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.landscapeView.frame = frame;
    
    [self.portraitView setHidden:YES];
    [self.landscapeView setHidden:YES];
    self.portraitView.delegate = self;
    self.landscapeView.delegate = self;
    
    [self.view addSubview:self.portraitView];
    [self.view addSubview:self.landscapeView];
    
    
//    NSLog(@"did load");
    
   
    
    // Do any additional setup after loading the view.
    _CameraHelper = [[CameraImageHelper alloc]init];
    _CameraHelper.delegate = self;
    
    // 开始实时取景
    [_CameraHelper startRunning];
    
    [_CameraHelper changePreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    [self resetLayout:self.curLayoutType];
    
}

- (void) setupLayout:(UIInterfaceOrientation) orientation {
    BOOL is_iphone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    BOOL is_portrait = UIDeviceOrientationIsPortrait(orientation);
    if(is_iphone && is_portrait) {
        //iphone portrait
        self.curLayoutType = IPHONE_PORTRAIT;
        self.CameraViewCellIdentifier = CameraPickerCellIdentifier_iPhone_portrait;
    } else if(is_iphone && !is_portrait) {
        //iphone landscape
        self.curLayoutType = IPHONE_LANDSCAPE;
        self.CameraViewCellIdentifier = CameraPickerCellIdentifier_iPhone_landscape;

    } else if(!is_iphone && is_portrait) {
        //ipad portrait
        self.curLayoutType = IPAD_PORTRAIT;
        self.CameraViewCellIdentifier = CameraPickerCellIdentifier_iPad_portrait;

    } else {
        //ipad landscape
        self.curLayoutType = IPAD_LANDSCAPE;
        self.CameraViewCellIdentifier = CameraPickerCellIdentifier_iPad_landscape;

    }
}
- (void) resetLayout:(NSInteger) curLayoutType {
    [self.portraitView setHidden:YES];
    [self.landscapeView setHidden:YES];
    
    BOOL is_portrait = curLayoutType == IPAD_PORTRAIT || curLayoutType==IPHONE_PORTRAIT;
    
    CameraPickerView* curView = is_portrait ? self.portraitView : self.landscapeView;

    self.collectionView = curView.collectionView;
    
    NSInteger pn = [self.pickedImageArray count];
    CGRect liveFrame;
    CGRect ctrlFrame = curView.ctrlView.frame;
    CGRect collFrame = curView.collectionView.frame;
    
    float tmp;
    float thumbSpace = THUBM_VIEW_HEIGHT[self.curLayoutType]; // is_portrait ? collFrame.size.height : collFrame.size.width;
    float ctrlSpace =  is_portrait ? ctrlFrame.size.height : ctrlFrame.size.width;
    
 
    if(is_portrait) {
        tmp = pn > 0 ? self.size.height - thumbSpace : self.size.height;
        liveFrame = CGRectMake(0, 0, self.size.width, tmp);
        ctrlFrame = CGRectMake(0, tmp - ctrlSpace, self.size.width, ctrlSpace);
        collFrame = CGRectMake(0, pn > 0 ? self.size.height - thumbSpace : self.size.height + 100, self.size.width, thumbSpace);
 
    } else {
        tmp = pn > 0 ? self.size.width - thumbSpace : self.size.width;
        liveFrame = CGRectMake(pn>0 ? thumbSpace : 0, 0, tmp, self.size.height);
        ctrlFrame = CGRectMake(self.size.width - ctrlSpace, 0, ctrlSpace, self.size.height);
        collFrame = CGRectMake(pn > 0 ? 0 : self.size.width + 100, 0, THUBM_VIEW_HEIGHT[self.curLayoutType], self.size.height);
    }
    
    curView.collectionView.frame = collFrame;
//    NSLog(@"%@", NSStringFromCGRect(curView.collectionView.frame));

    curView.liveView.frame = liveFrame;
    curView.ctrlView.frame = ctrlFrame;
    
    [self.CameraHelper.preview removeFromSuperlayer];
    self.CameraHelper.preview.frame = curView.liveView.bounds;
    
    [curView.liveView.layer addSublayer:self.CameraHelper.preview];
    
    [curView setHidden:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    NSLog(@"will r");
    /*
     * 旋转设备后，重新布局。
     */
    self.size = self.view.bounds.size;
    
    [self setupLayout:toInterfaceOrientation];
    [self resetLayout:self.curLayoutType];

    [self.CameraHelper changePreviewOrientation:(UIInterfaceOrientation)toInterfaceOrientation];

}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    NSLog(@"did r");
    [self reloadPickedImages];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

    [super viewWillDisappear:animated];
    [self.CameraHelper stopRunning];
}

//-(void) dealloc {
//    NSLog(@"dlloc");
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pickImage:(id)sender {
    [self.CameraHelper takePicture];
}

- (IBAction)cancelPick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)finishPick:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) deletePickedImage:(UIImage*)image {
    NSInteger pre = [self.pickedImageArray count];
    [self.pickedImageArray removeObject:image];
    [self reloadPickedImages];

    if(pre==1) {
        [self resetLayout:self.curLayoutType];
        [self.view layoutIfNeeded];
////        [UIView animateWithDuration:0.4 animations:^{
//            [self reloadPickedImages];
////        }];
//    } else {
//        [self reloadPickedImages];
    }
}

- (void) didFinishedTakePicture:(UIImage *)image attachments:(CFDictionaryRef)attachments {
    NSInteger pre = [self.pickedImageArray count];
    [self.pickedImageArray addObject:image];
    [self reloadPickedImages];

    if(pre==0) {
        [self resetLayout:self.curLayoutType];
        [self.view layoutIfNeeded];

    }
}

- (void) reloadPickedImages {
    [self.collectionView reloadData];
//    [self resetLayout:self.curLayoutType];

//    //scroll to last
//    NSInteger section = [self.collectionView numberOfSections] - 1;
//    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
//    if(item <0) {
//        return;
//    }
//    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
//    [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pickedImageArray.count;
}
//
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    CameraPickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.CameraViewCellIdentifier forIndexPath:indexPath];
    
    cell.image = self.pickedImageArray[indexPath.row];
    cell.delegate = self;
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
