//
//  UIXVerticalPackedCollectionViewLayout.h
//  HomewreckerHack
//
//  Created by Guy Umbright on 4/30/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIXVerticalPackedLayout;

@protocol UIXVerticalPackedLayoutDelegate <NSObject>

- (CGSize) UIXVerticalPackedLayout: (UIXVerticalPackedLayout*) layout sizeForItemAtIndex:(NSIndexPath*) indexPath;

@end

@interface UIXVerticalPackedLayout : UICollectionViewLayout

@property (nonatomic, weak) IBOutlet NSObject<UIXVerticalPackedLayoutDelegate>* delegate;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, assign) CGFloat verticalSpacing;
@property (nonatomic, assign) CGFloat columnSpacing;
@property (nonatomic, assign) CGFloat columnWidth;

@property (nonatomic, assign) BOOL justified; //forces first and last to edges and spreads rest in between
//could also have mode where if the seperation is beyond some threshold it instead centers like <edge><pad><item><pad><item><pad><edge>
@end
