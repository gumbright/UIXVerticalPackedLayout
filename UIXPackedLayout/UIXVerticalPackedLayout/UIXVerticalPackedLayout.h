//
//  UIXVerticalPackedCollectionViewLayout.h
//  HomewreckerHack
//
//  Created by Guy Umbright on 4/30/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXPackedLayout.h"

@interface UIXVerticalPackedLayout : UIXPackedLayout

@property (nonatomic, assign) CGFloat verticalSpacing;
@property (nonatomic, assign) CGFloat columnSpacing;
@property (nonatomic, assign) CGFloat columnWidth;

@property (nonatomic, assign) BOOL justified; //forces first and last to edges and spreads rest in between
@property (nonatomic, assign) BOOL singleColumn; //layout as a single stack as tall as needed
//could also have mode where if the seperation is beyond some threshold it instead centers like <edge><pad><item><pad><item><pad><edge>
@end
