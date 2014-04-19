//
//  SearchDialogViewController.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-18.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SearchViewController.h"
#import "Layout.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation SearchViewController

- (void) setSearchText:(NSString *)searchText {
    if(searchText == nil) {
        searchText = @"";
    }
    self.searchBar.text = searchText;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//
//    }
//    return self;
//}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.searchBar.text = self.curSearchText;
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)search:(id)sender {
    [self.searchBar resignFirstResponder];
    [self onSearchTextInput:self.searchBar.text];
}

- (IBAction)showAll:(id)sender {
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self onSearchTextInput:@""];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if([self.delegate respondsToSelector:@selector(searchViewController)]) {
        [self.delegate searchViewController];
    }
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self onSearchTextInput:searchBar.text];
}

- (void) onSearchTextInput:(NSString*) searchText {
//    if([self.delegate respondsToSelector:@selector(searchDialogViewController:)]) {
        [self.delegate searchViewController:searchText];
//    }
}
@end
