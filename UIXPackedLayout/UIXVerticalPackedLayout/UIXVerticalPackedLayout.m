//
//  UIXVerticalPackedCollectionViewLayout.m
//  HomewreckerHack
//
//  Created by Guy Umbright on 4/30/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "UIXVerticalPackedLayout.h"

@interface UIXVerticalPackedLayout ()
@property (nonatomic, assign) CGFloat maxHeight;

@property (nonatomic, strong) NSMutableArray* deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray* insertIndexPaths;
@end

@implementation UIXVerticalPackedLayout
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) commonInit
{
    self.verticalSpacing = 0;
    self.columnSpacing = 0;
    self.columnWidth = 100;
    self.singleColumn = NO;
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
    [super awakeFromNib];
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
NSLog(@"PREPARE LAYOUT");

    [super prepareLayout];
    
    CGFloat currentX, currentY;
    NSUInteger numSections;
    NSUInteger numItems;
    NSMutableArray* sectionData;
    currentX = self.sectionInset.left;
    currentY = self.sectionInset.top;
    self.maxHeight = self.collectionView.bounds.size.height - (self.sectionInset.top + self.sectionInset.bottom);
    NSMutableArray* currentColumn = [NSMutableArray array];
    
    numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    sectionData = [NSMutableArray arrayWithCapacity:numSections];

    for (int sectionNdx=0; sectionNdx < numSections; ++sectionNdx)
    {
        numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionNdx];
        NSMutableArray* itemData = [NSMutableArray arrayWithCapacity:numItems];
        for (int itemNdx = 0; itemNdx < numItems; ++itemNdx)
        {
            CGSize sz = [self.delegate UIXPackedLayout: self sizeForItemAtIndex:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            
            if (!self.singleColumn && currentY + sz.height > self.maxHeight)
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

        if (!self.singleColumn)
        {
            currentX += (self.columnWidth + self.columnSpacing);
            currentY = self.sectionInset.top;
            if (self.justified)
            {
                [self justify:currentColumn];
            }
            currentColumn = [NSMutableArray array];
        }
    }
    
    self.layoutData = sectionData;
    
    if (self.singleColumn)
    {
        self.layoutContentSize = CGSizeMake(self.collectionView.bounds.size.width,currentY);
    }
    else
    {
        self.layoutContentSize = CGSizeMake(currentX-self.columnSpacing + self.sectionInset.right, self.collectionView.bounds.size.height);
    }
}

/////////////////////////////////////////////////////
//
// this gives a list of all the update items, so record the things that are deleted and
// the things that are inserted
/////////////////////////////////////////////////////
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete)
        {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}
 

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
    {
        // Must call super
        UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
        
        if ([self.insertIndexPaths containsObject:itemIndexPath])
        {
            // only change attributes on inserted cells
            if (!attributes)
                attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
            
            // Configure attributes ...
//            attributes.alpha = 0.0;
        }

        NSLog(@"INITIAL: %@ = %@",itemIndexPath,attributes);
        return attributes;
    }
    
    // Note: name of method changed
    // Also this gets called for all visible cells (not just the deleted ones) and
    // even gets called when inserting cells!
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
    {
        // So far, calling super hasn't been strictly necessary here, but leaving it in
        // for good measure
        UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
//
//        if ([self.deleteIndexPaths containsObject:itemIndexPath])
//        {
//            // only change attributes on deleted cells
//            if (!attributes)
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//            
//            // Configure attributes ...
//            attributes.alpha = 0.0;
//            attributes.center = CGPointMake(_center.x, _center.y);
//            attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
//        }
//        
        NSLog(@"FINAL: %@ = %@",itemIndexPath,attributes);
        return attributes;
    }

@end
