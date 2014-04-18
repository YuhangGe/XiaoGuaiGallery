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
#import "CTAssetsPickerController.h"
#import "SearchDialogViewController.h"

NSString * const GalleryCellIdentifier = @"GalleryCell";
NSString * const GallerySearchResuableView = @"GallerySearchResuableView";

@interface GalleryViewController ()
<UINavigationControllerDelegate, CTAssetsPickerControllerDelegate, UIPopoverControllerDelegate,SearchDialogViewControllerDelegate>

@property(nonatomic) NSString* docRootPath;
@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, strong) UIPopoverController *popover;

@property(nonatomic, copy) NSString* curSearchText;
@property(nonatomic) NSMutableArray* curPicArray;

@end

@implementation GalleryViewController


//#pragma mark - Search Bar Delegate
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    [UIView animateWithDuration:0.6 animations:^{
//        [searchBar setShowsCancelButton:YES];
//        [self.navigationController setNavigationBarHidden:YES];
//    }];
//    
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    [searchBar setShowsCancelButton:NO animated:YES];
//}

#pragma mark - init load

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
    // Do any additional setup after loading the view.
    [self setupNavigationBarAndToolBar];

    [self resetCurrentLayout:[[UIApplication sharedApplication] statusBarOrientation]];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	self.docRootPath = [[paths objectAtIndex:0] stringByAppendingString:@"/"];
    
    self.navigationItem.title = NSLocalizedString(@"App_Name", nil);
    [self reloadImages];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.curLayoutType == 0 || self.curLayoutType==1) {
        [self.collectionView setContentOffset:CGPointMake(0, 22) animated:YES];
    }
}

#pragma mark - Navigation Bar & Event
-(void) setupNavigationBarAndToolBar {
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButtonClick:)];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearchButtonClick:)];
    
//    NSArray* leftBarArray;
//    /*
//     * 如果是iphone，则不需要显示searchItem。searchBar会在collection view的header部分显示。
//     *
//     */
//    if(self.curLayoutType == 2 || self.curLayoutType==3) {
//        leftBarArray = @[addItem, searchItem];
//    } else {
//        leftBarArray = @[addItem];
//    }
    NSArray* leftBarArray = @[addItem, searchItem];
    
    self.navigationItem.leftBarButtonItems = leftBarArray;
    
    UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(onSelectButtonClick:)];
    
    self.navigationItem.rightBarButtonItem = selectItem;
    
    UIBarButtonItem *renameItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Rename", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onRenameButtonClick:)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    UIBarButtonItem *trashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onTrashButtonClick:)];
    
    NSArray* toolBarArray = @[renameItem, spaceItem, trashItem];
    
    self.toolbarItems = toolBarArray;
    [self.navigationController setToolbarHidden:YES];
    
    
}

-(void) onAddButtonClick:(id)sender {
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allPhotos];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.selectedAssets       = [NSMutableArray arrayWithArray:self.assets];
    
    // iPad
    if (self.curLayoutType >= 2) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popover.delegate = self;
        [self.popover presentPopoverFromBarButtonItem:sender
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
    }
    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }

}
-(void) onSearchButtonClick:(id)sender {
    if (self.curLayoutType >= 2) {
        //ipad
        SearchDialogViewController *searchDialogViewController = [[SearchDialogViewController alloc] initWithNibName:@"SearchDialogViewController" bundle:nil];
        
        searchDialogViewController.delegate = self;
        searchDialogViewController.curSearchText = self.curSearchText;
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:searchDialogViewController];
        [self.popover setDelegate:self];
        [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        
    }
}

-(void)onSelectButtonClick:(id)sender {
    if(self.navigationController.isToolbarHidden) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

-(void)onRenameButtonClick:(id)sender {
    
}

-(void)onTrashButtonClick:(id)sender {
    
}

#pragma mark - deal Search delegate

//search text changed
- (void) searchDialogViewController:(NSString *)searchTextInput {
    if(self.popover != nil) {
        [self.popover dismissPopoverAnimated:YES];
    }

    self.curSearchText = searchTextInput;
    [self doSearchFiler];
}

//search canceled
- (void) searchDialogViewController {
    if(self.popover != nil) {
        [self.popover dismissPopoverAnimated:YES];
    }
}

#pragma mark - Popover Controller Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (self.popover != nil)
        [self.popover dismissPopoverAnimated:YES];
    else
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.assets = [NSMutableArray arrayWithArray:assets];
    
    [self importPhotos];
}

//- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAssetForSelection:(ALAsset *)asset
//{
//    return YES;
//}
//
//- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
//{
//    return YES;
//}
//
#pragma mark - Main Logistics

- (void) reloadImages {
    if(self.picArray) {
        [self.picArray removeAllObjects];
    } else {
        self.picArray = [[NSMutableArray alloc] init];
    }
    if(self.curPicArray) {
        [self.curPicArray removeAllObjects];
    } else {
        self.curPicArray = [[NSMutableArray alloc] init];
    }
    self.curSearchText = @"";
    
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
        [self.curPicArray addObject:photo];
        
        i++;
    }
    //clear
    [thumbNameList removeAllObjects];
    [imageExtList removeAllObjects];
    [imageNameList removeAllObjects];
    
     
    
}

- (void) doSearchFiler {
    [self.curPicArray removeAllObjects];
    for (GalleryPhoto* p in self.picArray) {
        if(self.curSearchText.length==0 || [p.title rangeOfString:self.curSearchText].location != NSNotFound) {
            [self.curPicArray addObject:p];
        }
    }
    if(self.curSearchText.length==0) {
        self.navigationItem.title = NSLocalizedString(@"App_Name", nil);
    } else {
        self.navigationItem.title = [NSLocalizedString(@"Search", nil) stringByAppendingFormat:@": %@", self.curSearchText];
    }
    [self.collectionView reloadData];
}

- (void) importPhotos {
    UIAlertView* promptView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App_Name", nil) message:NSLocalizedString(@"Promot_Title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
    promptView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
//    for (ALAsset* asset in self.assets) {
//        UIImage* img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
//        NSData* data = UIImagePNGRepresentation(img);
//        NSString* save_file = [path stringByAppendingFormat:@"/%@(%d).png", file_name, cur+1];
//        //                NSLog(@"file:%@", save_file);
//        if(![data writeToFile:save_file atomically:TRUE]) {
//            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error on write image file"]
//                                        callbackId:command.callbackId ];
//        } else {
//            //                    NSLog(@"write image %@", save_file);
//        }
//
//    }
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
        destViewController.picArray = self.curPicArray;
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
    return self.curPicArray.count;
}
//
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GalleryCellIdentifier forIndexPath:indexPath];
    cell.photo = self.curPicArray[indexPath.row];
    cell.curLayoutType = self.curLayoutType;
    return cell;
}
//
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    /*
     * 如果是iphone，我们把搜索框放在collection view的header部分。
     */
    if(self.curLayoutType==0 || self.curLayoutType==1) {
        UICollectionReusableView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:GallerySearchResuableView
                                                  forIndexPath:indexPath];
        return view;
    } else {
        return nil;
    }
}
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
