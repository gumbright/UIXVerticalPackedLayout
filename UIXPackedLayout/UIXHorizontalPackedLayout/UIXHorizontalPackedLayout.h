//
//  UIXHorizontalPackedCollectionViewLayout.h
//  HomewreckerHack
//
//  Created by Guy Umbright on 4/30/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXPackedLayout.h"

@class UIXHorizontalPackedLayout;


@interface UIXHorizontalPackedLayout : UIXPackedLayout

@property (nonatomic, assign) CGFloat horizontalSpacing;
@property (nonatomic, assign) CGFloat rowSpacing;
@property (nonatomic, assign) CGFloat rowHeight;

@end
