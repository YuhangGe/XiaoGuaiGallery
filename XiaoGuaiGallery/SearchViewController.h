//
//  SearchDialogViewController.h
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-18.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewControllerDelegate;

@interface SearchViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, weak) id <UINavigationControllerDelegate, SearchViewControllerDelegate> delegate;

@property (nonatomic, copy)NSString* curSearchText;

@end

@protocol SearchViewControllerDelegate <NSObject>

//search text changed;
-(void) searchViewController:(NSString*) searchTextInput;

@optional
//search canceled;
-(void) searchViewController;

@end
