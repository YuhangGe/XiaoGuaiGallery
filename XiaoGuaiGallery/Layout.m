//
//  Layout.m
//  XiaoGuaiGallery
//
//  Created by 葛羽航 on 14-4-13.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "Layout.h"


int const IPHONE_LANDSCAPE = 0;
int const IPHONE_PORTRAIT = 1;
int const IPAD_LANDSCAPE = 2;
int const IPAD_PORTRAIT = 3;

int const LAYOUT_SIZE_WIDTH[] = {160, 90, 210, 160};
int const LAYOUT_SIZE_HEIGHT[] = {220, 140, 290, 210};
int const LAYOUT_EDGE_LEFT[] = {20, 12, 35, 25};
int const LAYOUT_EDGE_RIGHT[] = {20, 12, 35, 25};
int const LAYOUT_EDGE_TOP[] = {20, 12, 30, 23};
int const LAYOUT_EDGE_BOTTOM[] = {20, 12, 30, 25};

int const LAYOUT_TITLE_FONTSIZE[] = {12, 12, 17, 17};
int const LAYOUT_TITLE_HEIGHT[] = {20, 20, 30, 30};

int const LAYOUT_MIN_CELL_SPACE[] = {15, 10, 30, 20};
int const LAYOUT_MIN_LINE_SPACE[] = {30, 26, 50, 26};

CGSize const SEARCH_DIALOG_SIZE = {262, 90};
int const SEARCH_POPOVER_HEIGHT = 102;