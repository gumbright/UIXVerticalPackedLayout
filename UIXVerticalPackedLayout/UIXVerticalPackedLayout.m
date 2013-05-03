//
//  UIXVerticalPackedCollectionViewLayout.m
//  HomewreckerHack
//
//  Created by Guy Umbright on 4/30/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "UIXVerticalPackedLayout.h"

@interface UIXVerticalPackedLayout ()
@property (nonatomic, strong) NSArray* layoutData;
@property (nonatomic, assign) CGSize layoutContentSize;
@property (nonatomic, assign) CGFloat maxHeight;
@end

@implementation UIXVerticalPackedLayout
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) commonInit
{
    self.sectionInset = UIEdgeInsetsZero;
    self.verticalSpacing = 0;
    self.columnSpacing = 0;
    self.columnWidth = 100;
    self.justified = NO;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (id) init
{
    if (self = [super init])
    {
        [self commonInit];
    }
    
    return self;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) awakeFromNib
{
    [self commonInit];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) justify:(NSArray*) currentColumn
{
    //if item = 1, stick it to top
    if (currentColumn.count > 1)
    {
        CGFloat totalHeight = 0;
        
        for (UICollectionViewLayoutAttributes* attr in currentColumn)
        {
            totalHeight += attr.frame.size.height;
        }
        
        CGFloat totalPad = self.maxHeight - totalHeight;
        CGFloat itemPad = totalPad / (currentColumn.count - 1);

        UICollectionViewLayoutAttributes* attr0 = currentColumn[0];
        CGFloat currentY = CGRectGetMaxY(attr0.frame) + itemPad;
        
        for (UICollectionViewLayoutAttributes* attr in currentColumn)
        {
            if (attr != currentColumn[0])
            {
                CGRect frame = attr.frame;
                frame.origin.y = currentY;
                attr.frame = frame;
                
                currentY = CGRectGetMaxY(frame)+itemPad;
            }
        }
    }
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) prepareLayout
{
    CGFloat currentX, currentY;
    NSUInteger numSections;
    NSUInteger numItems;
    NSMutableArray* sectionData;
    currentX = self.sectionInset.left;
    currentY = self.sectionInset.top;
    self.maxHeight = self.collectionView.bounds.size.height - (self.sectionInset.top + self.sectionInset.bottom);
    NSMutableArray* currentColumn = [NSMutableArray array];
    
    numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView.dataSource];
    sectionData = [NSMutableArray arrayWithCapacity:numSections];

    for (int sectionNdx=0; sectionNdx < numSections; ++sectionNdx)
    {
        numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionNdx];
        NSMutableArray* itemData = [NSMutableArray arrayWithCapacity:numItems];
        for (int itemNdx = 0; itemNdx < numItems; ++itemNdx)
        {
            CGSize sz = [self.delegate UIXVerticalPackedLayout: self sizeForItemAtIndex:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            
            if (currentY + sz.height > self.maxHeight)
            {
                currentX += (self.columnWidth + self.columnSpacing);
                currentY = self.sectionInset.top;
                
                if (self.justified)
                {
                    [self justify:currentColumn];
                }
                currentColumn = [NSMutableArray array];
            }
            
            //if an item does not fit after advancing the column, just let it hang off the bottom
            UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            CGRect frame = CGRectMake(currentX, currentY, sz.width, sz.height);
            attr.frame = frame;
            [itemData addObject:attr];
            [currentColumn addObject:attr];
            
            currentY += (sz.height + self.verticalSpacing);
        }
        
        [sectionData addObject:itemData];

        currentX += (self.columnWidth + self.columnSpacing);
        currentY = self.sectionInset.top;
        if (self.justified)
        {
            [self justify:currentColumn];
        }
        currentColumn = [NSMutableArray array];
    }
    
    self.layoutData = sectionData;
    self.layoutContentSize = CGSizeMake(currentX-self.columnSpacing + self.sectionInset.right, self.collectionView.bounds.size.height);
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (CGSize) collectionViewContentSize
{
    return self.layoutContentSize;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* result = [NSMutableArray array];
    
    for (int sectionNdx=0; sectionNdx < self.layoutData.count; ++sectionNdx)
    {
        NSArray* itemArr = self.layoutData[sectionNdx];
        for (int itemNdx=0; itemNdx < itemArr.count; ++itemNdx)
        {
            UICollectionViewLayoutAttributes* attr = itemArr[itemNdx];
            CGRect intersect = CGRectIntersection(rect, attr.frame);
            if (!CGRectIsEmpty(intersect))
            {
                [result addObject:attr];
            }
        }
    }
    return result;
}

/////////////////////////////////////////////////////
//
////////////////////////////////////////////////////
- (UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* arr = self.layoutData[indexPath.section];
    return arr[indexPath.item];
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
@end
