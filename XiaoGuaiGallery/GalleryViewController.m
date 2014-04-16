//
//  GalleryViewController.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-12.
//  Copyright (c) 2014年 nju. All rights reserved.
//  
//

#import "GalleryViewController.h"
#import "Layout.h"
#import "GalleryPhoto.h"
#import "GalleryCell.h"
#import "GalleryDetailController.h"


NSString * const GalleryCellIdentifier = @"GalleryCell";


@interface GalleryViewController ()

@property(nonatomic) NSString* docRootPath;

@end

@implementation GalleryViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self resetCurrentLayout:[[UIApplication sharedApplication] statusBarOrientation]];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	self.docRootPath = [[paths objectAtIndex:0] stringByAppendingString:@"/"];
    
    [self reloadImages];
}

- (void) reloadImages {
    if(self.picArray) {
        [self.picArray removeAllObjects];
    } else {
        self.picArray = [[NSMutableArray alloc] init];
    }
    static NSArray* imgExt;
    if(imgExt == nil) {
        imgExt = [[NSArray alloc] initWithObjects:@"jpg", @"png", @"bmp", @"jpeg", @"gif", nil];
    }
    
    NSError* err;
    BOOL isFileExists;
    BOOL isDirectory;
    NSMutableArray* thumbNameList = [[NSMutableArray alloc] init];
    NSMutableArray* imageNameList = [[NSMutableArray alloc] init];
    NSMutableArray* imageExtList = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* thumbPath = [self.docRootPath stringByAppendingString:@"thumbnails/"];
    
    isFileExists = [fileManager fileExistsAtPath:thumbPath isDirectory:&isDirectory];
    
    if(!(isFileExists && isDirectory)) {
        //if thumbnail dirctory is not exists
        BOOL cs = [fileManager createDirectoryAtPath:thumbPath withIntermediateDirectories:YES attributes:nil error:&err];
        if(!cs) {
            NSLog(@"could not create thumbnail directory");
            //todo show message to user.
            return;
        }
    }
    
    NSArray *tlist = [fileManager contentsOfDirectoryAtPath:thumbPath error:&err];
    
    
    NSString* fname;
    
    for (fname in tlist) {
        isFileExists = [fileManager fileExistsAtPath:[thumbPath stringByAppendingString:fname]isDirectory:&isDirectory];
        if (isFileExists && !isDirectory && [fname hasSuffix:@".thumb.png"]) {
            [thumbNameList addObject:[fname substringToIndex:fname.length - 10]];
        }
    }
    
    tlist = [fileManager contentsOfDirectoryAtPath:self.docRootPath error:&err];
    for (fname in tlist) {
        isFileExists = [fileManager fileExistsAtPath:[self.docRootPath stringByAppendingString:fname]isDirectory:&isDirectory];
        if(isFileExists && !isDirectory && [imgExt containsObject:[fname pathExtension]]) {
            [imageNameList addObject:[fname stringByDeletingPathExtension]];
            [imageExtList addObject:[fname pathExtension]];
        }
    }
    
    int i = 0;
    for(fname in imageNameList) {
        if(![thumbNameList containsObject:fname]) {
            [self saveThumbnail:fname imageExtension:[imageExtList objectAtIndex:i]];
        }
        i++;
    }
    
    i=0;
    for(fname in imageNameList) {
        GalleryPhoto* photo = [[GalleryPhoto alloc] init];
        photo.title = fname;
        NSString* imgPath = [thumbPath stringByAppendingFormat:@"%@.thumb.png", fname];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        photo.thumbnail = [UIImage imageWithData:imgData];
        photo.imageFile = [fname stringByAppendingFormat:@".%@", imageExtList[i]];
        [self.picArray addObject:photo];
        i++;
    }
    //clear
    [thumbNameList removeAllObjects];
    [imageExtList removeAllObjects];
    [imageNameList removeAllObjects];
    
     
    
}

- (void) saveThumbnail:(NSString*) imageName imageExtension:(NSString*) imageExt {
    NSLog(@"save");
}

- (UIImage*) loadImage:(GalleryPhoto*) photo {
    NSString* imgPath = [self.docRootPath stringByAppendingString:photo.imageFile];
    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
    return [UIImage imageWithData:imgData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // todo 每次加载了大图片后，都会一直放在内存中。如果遇到内存警告，则主动将picArray中的大图片归还。
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    /*
     * 旋转设备后，重新布局。
     */
    [self resetCurrentLayout:toInterfaceOrientation];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void) resetCurrentLayout:(UIInterfaceOrientation) currentOrientation {
    BOOL is_landscape = UIDeviceOrientationIsLandscape(currentOrientation);
    BOOL is_iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    if(is_iPad && is_landscape) {
        self.curLayoutType = IPAD_LANDSCAPE;
    } else if(is_iPad && !is_landscape) {
        self.curLayoutType = IPAD_PORTRAIT;
    } else if(!is_iPad && is_landscape) {
        self.curLayoutType = IPHONE_LANDSCAPE;
    } else {
        self.curLayoutType = IPHONE_PORTRAIT;
    }
    
}

#pragma mark - Flowlayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(LAYOUT_SIZE_WIDTH[self.curLayoutType], LAYOUT_SIZE_HEIGHT[self.curLayoutType]);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return LAYOUT_MIN_LINE_SPACE[self.curLayoutType];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return LAYOUT_MIN_CELL_SPACE[self.curLayoutType];
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    int i = self.curLayoutType;
    return UIEdgeInsetsMake(LAYOUT_EDGE_TOP[i], LAYOUT_EDGE_LEFT[i], LAYOUT_EDGE_BOTTOM[i], LAYOUT_EDGE_RIGHT[i]);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        GalleryDetailController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        //init detail controller
        destViewController.size = self.view.bounds.size;
        destViewController.picArray = self.picArray;
        destViewController.curImageIndex = indexPath.row;
        destViewController.docRootPath = self.docRootPath;
       
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Collection View Data Source
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSLog([NSString stringWithFormat:@"number %@", [NSNumber numberWithInt:self.picArray.count]]);
    return self.picArray.count;
}
//
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GalleryCellIdentifier forIndexPath:indexPath];
    cell.photo = self.picArray[indexPath.row];
    cell.curLayoutType = self.curLayoutType;
    return cell;
}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    CTAssetsSupplementaryView *view =
//    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
//                                       withReuseIdentifier:CTAssetsSupplementaryViewIdentifier
//                                              forIndexPath:indexPath];
//    
//    [view bind:self.assets];
//    
//    return view;
//}
//
//
#pragma mark - Collection View Delegate
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//    
//    CTAssetsViewCell *cell = (CTAssetsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    
//    if (!cell.isEnabled)
//        return NO;
//    else if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)])
//        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
//    else
//        return YES;
//}
//
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//    
//    [self.picker selectAsset:asset];
//    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)])
//        [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)])
//        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
//    else
//        return YES;
//}
//
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//    
//    [self.picker deselectAsset:asset];
//    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)])
//        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
//        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
//    else
//        return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
//        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//    
//    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
//        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
//}

@end
