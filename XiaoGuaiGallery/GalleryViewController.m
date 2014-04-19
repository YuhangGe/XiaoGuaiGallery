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
#import "SearchViewController.h"
#import "MBProgressHUD.h"
#import "TransitionDelegate.h"

NSString * const GalleryCellIdentifier = @"GalleryCell";
NSString * const GallerySearchResuableView = @"GallerySearchResuableView";

@interface GalleryViewController ()
<UINavigationControllerDelegate, CTAssetsPickerControllerDelegate, UIPopoverControllerDelegate,SearchViewControllerDelegate, UIAlertViewDelegate>

@property(nonatomic) NSString* docRootPath;
@property (nonatomic, copy) NSMutableArray *assets;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) SearchViewController* modalSearchView;

@property(nonatomic, copy) NSString* curSearchText;
@property(nonatomic) NSMutableArray* curPicArray;

@property(nonatomic) BOOL editing;
@property(nonatomic) NSMutableArray* selectPicArray;

@property(nonatomic) NSArray* leftBarArray;

@property (nonatomic, strong) TransitionDelegate *transitionController;

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
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.transitionController = [[TransitionDelegate alloc] init];
    }
    
    // Do any additional setup after loading the view.
    [self setupNavigationBarAndToolBar];

    [self resetCurrentLayout:[[UIApplication sharedApplication] statusBarOrientation]];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	self.docRootPath = [[paths objectAtIndex:0] stringByAppendingString:@"/"];
    
    self.navigationItem.title = NSLocalizedString(@"App_Name", nil);
    [self reloadImages];
}

//- (void) viewDidAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    if(self.curLayoutType == 0 || self.curLayoutType==1) {
//        [self.collectionView setContentOffset:CGPointMake(0, 22) animated:YES];
//    }
//}

- (void) alert:(NSString*) message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App_Name", nil) message:NSLocalizedString(message, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alertView show];
}
- (void) alertComplete:(NSString*) message {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = nil;
	HUD.labelText = NSLocalizedString(message, nil);
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:3];
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
    self.leftBarArray = @[addItem, searchItem];
    
    self.navigationItem.leftBarButtonItems = self.leftBarArray;
    
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
    else {
        [self.assets removeAllObjects];
    }
    
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
        SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController_iPad" bundle:nil];
        
        searchViewController.preferredContentSize = SEARCH_DIALOG_SIZE;
        searchViewController.delegate = self;
        searchViewController.curSearchText = self.curSearchText;
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:searchViewController];
        [self.popover setDelegate:self];
        [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        if(!self.modalSearchView) {
            SearchViewController* searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController_iPhone" bundle:nil];
            
            searchViewController.delegate = self;
            
            [searchViewController setTransitioningDelegate:self.transitionController];
            searchViewController.modalPresentationStyle= UIModalPresentationCustom;
            self.modalSearchView = searchViewController;
        }
        
        self.modalSearchView.curSearchText = self.curSearchText;

        [self presentViewController:self.modalSearchView animated:YES completion:nil];

    }
}

-(void)onSelectButtonClick:(id)sender {
    UIBarButtonItem* editButton = sender;
    
    [self.selectPicArray removeAllObjects];

    if(!self.editing) {
        UIBarButtonItem* btn = self.toolbarItems[0]; //rename button
        btn.enabled = NO;
        btn = self.toolbarItems[2]; //trash button
        btn.enabled = NO;
        self.editing = YES;
        
        editButton.title = NSLocalizedString(@"Done", nil);
        self.navigationItem.leftBarButtonItems = nil;
        [self.collectionView setAllowsMultipleSelection:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        
        self.editing = NO;
        editButton.title = NSLocalizedString(@"Select", nil);
        self.navigationItem.leftBarButtonItems = self.leftBarArray;
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.collectionView setAllowsMultipleSelection:NO];
        
        for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        
    }
}

-(void)onRenameButtonClick:(id)sender {
    
}

-(void)onTrashButtonClick:(id)sender {
    
}

#pragma mark - deal Search delegate

//search text changed
- (void) searchViewController:(NSString *)searchTextInput {
    if(self.popover != nil) {
        [self.popover dismissPopoverAnimated:YES];
    }
    if([self.modalSearchView isViewLoaded]) {
        [self.modalSearchView setTransitioningDelegate:self.transitionController];
        self.modalSearchView.modalPresentationStyle= UIModalPresentationCustom;
        [self.modalSearchView dismissViewControllerAnimated:YES completion:nil];
    }
    
    self.curSearchText = searchTextInput;
    [self doSearchFiler];
}

//search canceled
- (void) searchViewController {
    if(self.popover != nil) {
        [self.popover dismissPopoverAnimated:YES];
    }
    if([self.modalSearchView isViewLoaded]) {
        [self.modalSearchView setTransitioningDelegate:self.transitionController];
        self.modalSearchView.modalPresentationStyle= UIModalPresentationCustom;
        [self.modalSearchView dismissViewControllerAnimated:YES completion:nil];
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
    
    UIAlertView* promptView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App_Name", nil) message:NSLocalizedString(@"Prompt_Title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
    promptView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [promptView show];
//    [self importPhotos];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != 1) {
        return;
    }
    NSString* title = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(title.length==0) {
        return;
    }
    [self importPhotos:title];
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
    if(self.selectPicArray) {
        [self.selectPicArray removeAllObjects];
    } else {
        self.selectPicArray = [[NSMutableArray alloc] init];
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

- (void) importPhotos:(NSString*) title {
    for(GalleryPhoto* p in self.picArray) {
        if([p.title hasPrefix:title]) {
            [self alert:@"Photo_Name_Exist"];
            return;
        }
    }
    int cur = 0;
    for (ALAsset* asset in self.assets) {
        UIImage* img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
        NSData* data = UIImagePNGRepresentation(img);
        NSString* save_file = [self.docRootPath stringByAppendingFormat:@"%@(%d).png", title, cur+1];

        if(![data writeToFile:save_file atomically:TRUE]) {
            [self alert:@"Import_Photo_Error"];
            return;
        }
        cur++;
    }
    [self alertComplete:@"Import_Photo_Success"];
    
    //reload Images
    [self reloadImages];
    [self.collectionView reloadData];

}

- (void) saveThumbnail:(NSString*) imageName imageExtension:(NSString*) imageExt {
//    NSLog(@"save");
    
    float dst_w = 300;
    float dst_h = 300;
    
    float f_scale = 1.0;
    
    NSString* src_file_path = [self.docRootPath stringByAppendingFormat:@"%@.%@", imageName, imageExt];
    UIImage* src_img = [UIImage imageWithContentsOfFile:src_file_path];
    
    if(src_img == nil) {
        NSLog(@"something wrong!");
        return;
    }
    
    float src_w = src_img.size.width, src_h = src_img.size.height;
    float f_w = src_w / dst_w, f_h = src_h / dst_h;
    if(f_w>f_h){
        f_scale = f_w;
    } else {
        f_scale = f_h;
    }
    
    CGSize newSize = CGSizeMake(src_w/f_scale,  src_h/f_scale);
    
    UIGraphicsBeginImageContext(newSize);
    [src_img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* dst_small = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *pngData = UIImagePNGRepresentation(dst_small);
    
    NSString* dst_file_path = [self.docRootPath stringByAppendingFormat:@"thumbnails/%@.thumb.png", imageName];
    
    if(![pngData writeToFile:dst_file_path atomically:YES])
    {
        NSLog(@"error on write thumbnail image");
    }

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
    if ([[segue identifier] isEqualToString:@"showDetailSegue"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        GalleryDetailController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        //init detail controller
        destViewController.size = self.view.bounds.size;
        destViewController.picArray = self.curPicArray;
        destViewController.curImageIndex = indexPath.row;
        destViewController.docRootPath = self.docRootPath;
    }
}

#pragma mark - Collection View Data Source
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSLog([NSString stringWithFormat:@"number %@", [NSNumber numberWithInt:self.picArray.count]]);
    return self.curPicArray.count;
}
//
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GalleryCellIdentifier forIndexPath:indexPath];
    cell.photo = self.curPicArray[indexPath.row];
    cell.curLayoutType = self.curLayoutType;
    return cell;
}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    /*
//     * 如果是iphone，我们把搜索框放在collection view的header部分。
//     */
//    if(self.curLayoutType==0 || self.curLayoutType==1) {
//        UICollectionReusableView *view =
//        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                                           withReuseIdentifier:GallerySearchResuableView
//                                                  forIndexPath:indexPath];
//        return view;
//    } else {
//        return nil;
//    }
//}
//
//
#pragma mark - Collection View Delegate
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{

//}
//
- (void) afterCellSelected {
    UIBarButtonItem* renameButton = self.toolbarItems[0];
    UIBarButtonItem* trashButton = self.toolbarItems[2];
    
    if([self.selectPicArray count]>0) {
        renameButton.enabled = YES;
        trashButton.enabled = YES;
        
    } else {
        renameButton.enabled = NO;
        trashButton.enabled = NO;
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
    if(self.editing) {
        [self.selectPicArray addObject:[NSNumber numberWithInt:indexPath.row]];
        [self afterCellSelected];
    } else {
        [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{

//}
//
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editing) {
        for (NSNumber* idx in self.selectPicArray) {
            if([idx integerValue]==indexPath.row) {
                [self.selectPicArray removeObject:idx];
                [self afterCellSelected];
                return;
            }
        }
    }
}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{

//}
//
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{

//}

@end
