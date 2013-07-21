//
//  UIXHorizontalPackedCollectionViewLayout.m
//  HomewreckerHack
//
//  Created by Guy Umbright on 4/30/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "UIXHorizontalPackedLayout.h"

@interface UIXHorizontalPackedLayout ()
@property (nonatomic, assign) CGFloat maxWidth;
@end

@implementation UIXHorizontalPackedLayout
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) commonInit
{
    self.horizontalSpacing = 0;
    self.rowSpacing = 0;
    self.rowHeight = 100;
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
- (void) justify:(NSArray*) currentRow
{
    //if item = 1, stick it to top
    if (currentRow.count > 1)
    {
        CGFloat totalWidth = 0;
        
        for (UICollectionViewLayoutAttributes* attr in currentRow)
        {
            totalWidth += attr.frame.size.width;
        }
        
        CGFloat totalPad = self.maxWidth - totalWidth;
        CGFloat itemPad = totalPad / (currentRow.count - 1);

        UICollectionViewLayoutAttributes* attr0 = currentRow[0];
        CGFloat currentX = CGRectGetMaxX(attr0.frame) + itemPad;
        
        for (UICollectionViewLayoutAttributes* attr in currentRow)
        {
            if (attr != currentRow[0])
            {
                CGRect frame = attr.frame;
                frame.origin.x = currentX;
                attr.frame = frame;
                
                currentX = CGRectGetMaxX(frame)+itemPad;
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
    NSMutableArray* headerData;
    CGSize sz;
    CGRect frame;
    NSIndexPath* indexPath;
    
    UICollectionViewLayoutAttributes* attr;
    
    currentX = self.sectionInset.left;
    currentY = self.sectionInset.top;
    self.maxWidth = self.collectionView.bounds.size.width - (self.sectionInset.left + self.sectionInset.right);
    NSMutableArray* currentRow = [NSMutableArray array];
    
    numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    sectionData = [NSMutableArray arrayWithCapacity:numSections];
    headerData = [NSMutableArray arrayWithCapacity:numSections];
    
    for (int sectionNdx=0; sectionNdx < numSections; ++sectionNdx)
    {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:sectionNdx];
        sz = CGSizeZero;
        if ([self.delegate respondsToSelector:@selector(UIXPackedLayout:sizeOfHeaderForSection:)])
        {
            sz = [self.delegate UIXPackedLayout:self sizeOfHeaderForSection:sectionNdx];
        }
        
        if (sz.height != 0)
        {
            attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"header" withIndexPath:indexPath];
            frame = CGRectMake(self.sectionInset.left, currentY, sz.width, sz.height);
            attr.frame = frame;
            currentY += (frame.size.height + self.rowSpacing);
            [headerData addObject:attr];
        }

        numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionNdx];
        NSMutableArray* itemData = [NSMutableArray arrayWithCapacity:numItems];
        for (int itemNdx = 0; itemNdx < numItems; ++itemNdx)
        {
            sz = [self.delegate UIXPackedLayout: self sizeForItemAtIndex:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            
            if (currentX + sz.width > self.maxWidth)
            {
                currentY+= (self.rowHeight + self.rowSpacing);
                currentX = self.sectionInset.left;
                
                if (self.justified)
                {
                    [self justify:currentRow];
                }
                currentRow = [NSMutableArray array];
            }
            
            //if an item does not fit after advancing the column, just let it hang off the bottom
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:itemNdx inSection:sectionNdx]];
            frame = CGRectMake(currentX, currentY, sz.width, sz.height);
            attr.frame = frame;
            [itemData addObject:attr];
            [currentRow addObject:attr];
            
            currentX += (sz.width + self.horizontalSpacing);
        }
        
        [sectionData addObject:itemData];

        currentY += (self.rowHeight + self.rowSpacing);
        currentX = self.sectionInset.left;
        if (self.justified)
        {
            [self justify:currentRow];
        }
        currentRow = [NSMutableArray array];
    }
    
    self.layoutData = sectionData;
    self.headerData = headerData;
    self.layoutContentSize = CGSizeMake(self.collectionView.bounds.size.width,currentY-self.rowSpacing + self.sectionInset.bottom);
}

@end
