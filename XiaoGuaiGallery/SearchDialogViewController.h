//
//  SearchDialogViewController.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-18.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchDialogViewControllerDelegate;

@interface SearchDialogViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, weak) id <UINavigationControllerDelegate, SearchDialogViewControllerDelegate> delegate;

@property (nonatomic, copy)NSString* curSearchText;

@end

@protocol SearchDialogViewControllerDelegate <NSObject>

//search text changed;
-(void) searchDialogViewController:(NSString*) searchTextInput;

@optional
//search canceled;
-(void) searchDialogViewController;

@end
