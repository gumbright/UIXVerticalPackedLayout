//
//  UIXHorizontalPackedCollectionViewLayout.m
//  HomewreckerHack
//
//  Created by Guy Umbright on 4/30/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "UIXHorizontalPackedLayout.h"

#define ROWCACHEKEY_STARTINDEX @"startIndex"
#define ROWCACHEKEY_NUMBEROFITEMS @"numberOfItems"
#define ROWCACHEKEY_NEXTROWITEMINDEX @"nextRowItemIndex"

#pragma mark UIXPackedLayoutRowInfo

@interface UIXPackedLayoutRowInfo : NSObject
@property (nonatomic, assign) NSInteger startItemIndex;
@property (nonatomic, assign) NSInteger nextRowItemIndex;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) CGFloat rowY;
@property (nonatomic, strong) NSMutableArray* itemAttrs;

- (NSArray*) attrsForRect:(CGRect) rect;
@end

@implementation UIXPackedLayoutRowInfo
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (id) init
{
    if (self = [super init])
    {
        self.itemAttrs = [NSMutableArray array];
    }
    
    return self;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSArray*) attrsForRect:(CGRect) rect
{
    NSMutableArray* returnAttrs = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes* attr in self.itemAttrs)
    {
        if (CGRectIntersectsRect(rect, attr.frame))
        {
            [returnAttrs addObject:attr];
        }
    }
    
    return returnAttrs;
}

@end

#pragma mark -
#pragma mark UIXPackedLayoutSectionInfo
@interface UIXPackedLayoutSectionInfo : NSObject
@property (nonatomic, assign) CGRect sectionRect;
@property (nonatomic, strong) UICollectionViewLayoutAttributes* headerAttr;
@property (nonatomic, assign) CGRect contentRect;
@property (nonatomic, strong) NSMutableArray* rowInfo;

- (NSArray*) attrsForRect:(CGRect) rect;
@end

@implementation UIXPackedLayoutSectionInfo
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (id) init
{
    if (self = [super init])
    {
        self.rowInfo = [NSMutableArray array];
    }
    
    return self;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (CGRect) sectionRect
{
    CGRect rect;
    
    rect = self.headerAttr.frame;
    rect = CGRectUnion(rect, self.contentRect);
    
    return rect;
}

/////////////////////////////////////////////////////
//
///////////////////////////////////////////////////
- (NSArray*) attrsForRect:(CGRect) rect
{
    NSMutableArray* returnAttrs = [NSMutableArray array];
    
    if (self.headerAttr && CGRectIntersectsRect(self.headerAttr.frame, rect))
    {
        [returnAttrs addObject:self.headerAttr];
    }

    for (UIXPackedLayoutRowInfo* rowInfo in self.rowInfo)
    {
        [returnAttrs addObjectsFromArray:[rowInfo attrsForRect:rect]];
    }
    return returnAttrs;
}
@end

#pragma mark -
#pragma mark UIXHorizontalPackedLayout
@interface UIXHorizontalPackedLayout ()
@property (nonatomic, assign) CGFloat maxWidth;
//@property (nonatomic, strong) NSMutableDictionary* rowDataCache;
@property (nonatomic, strong) NSMutableArray* sectionData;
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
//    self.rowDataCache = [NSMutableDictionary dictionary];
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
    self.sectionData = nil;
    
#if 0
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
#endif
}

#if 0
//generate attribues for row
//
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) generateAttributesForRow:(NSInteger) row
{
    NSNumber* indexKey = [NSNumber numberWithInteger:row];
    NSInteger startItemIndex, currentItemIndex;
    
    NSDictionary* rowDict = [self.rowDataCache objectForKey:indexKey];
    
    if (rowDict)
    {
        return;
    }

    //get previous row for start index (0 if row == 0)
    if (row == 0)
    {
        startItemIndex = 0;
    }
    else
    {
        NSNumber* indexKey = [NSNumber numberWithInteger:row-1];
        NSDictionary* prevRowDict = [self.rowDataCache objectForKey:indexKey];
        NSNumber* n = [prevRowDict objectForKey:ROWCACHEKEY_NEXTROWITEMINDEX];
        startItemIndex = n.integerValue;
    }
    
    currentItemIndex = startItemIndex;
    
    //calc positions until we run out of space
    //create the rowCacheEntry
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) prepareRowsUpTo:(NSInteger) row
{
    for (NSInteger ndx = 0; ndx < row; ++ndx)
    {
        [self generateAttributesForRow:ndx];
    }
}
#endif

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (UIXPackedLayoutRowInfo*) generateRow:(NSInteger) startItemIndex inSection:(NSInteger) section numItems:(NSInteger) numItems startingY:(CGFloat) startingY
{
    CGSize sz;
    CGFloat currentY = startingY;
    CGFloat currentX = self.sectionInset.left;
    NSMutableArray* currentRow = [NSMutableArray array];
    
    UIXPackedLayoutRowInfo* rowInfo = [[UIXPackedLayoutRowInfo alloc] init];
    rowInfo.startItemIndex = startItemIndex;
    rowInfo.rowY = startingY;
    
    int itemNdx;
    for (itemNdx = startItemIndex; itemNdx < numItems; ++itemNdx)
    {
        sz = [self.delegate UIXPackedLayout: self sizeForItemAtIndex:[NSIndexPath indexPathForItem:itemNdx inSection:section]];
        
        if (currentX + sz.width > self.maxWidth)
        {
            break;
        }

        UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:itemNdx inSection:section]];
        CGRect frame = CGRectMake(currentX, currentY, sz.width, sz.height);
        attr.frame = frame;
        [currentRow addObject:attr];
        
        currentX += (sz.width + self.horizontalSpacing);
    }

    if (self.justified)
    {
        [self justify:currentRow];
    }
    
    rowInfo.numberOfItems = currentRow.count;
    rowInfo.nextRowItemIndex = itemNdx;
    [rowInfo.itemAttrs addObjectsFromArray:currentRow];
    
    return rowInfo;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) generateSection:(NSInteger) sectionNdx
{
    CGFloat currentY = 0.0;
    
    UIXPackedLayoutSectionInfo* sectionInfo = [[UIXPackedLayoutSectionInfo alloc] init];
    
    //!!!if section not 0, set the current y from prev sectoin
    CGRect frame;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:sectionNdx];
    UICollectionViewLayoutAttributes* attr;
    
    CGSize sz = CGSizeZero;
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
        sectionInfo.headerAttr = attr;
    }
    
    NSInteger numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionNdx];
    for (int itemNdx = 0; itemNdx < numItems; ++itemNdx)
    {
        UIXPackedLayoutRowInfo* rowInfo = [self generateRow:itemNdx inSection:sectionNdx numItems:numItems startingY:currentY];
        itemNdx = rowInfo.nextRowItemIndex;
        [sectionInfo.rowInfo addObject:rowInfo];
        currentY+= (self.rowHeight + self.rowSpacing);
    }
    
    sectionInfo.contentRect = CGRectMake(0,CGRectGetMaxY(sectionInfo.headerAttr.frame),sz.width,(self.rowHeight * sectionInfo.rowInfo.count)+(self.rowSpacing * (sectionInfo.rowInfo.count - 1)));
    [self.sectionData addObject:sectionInfo];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect
{
    //get # sections
    NSInteger numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    BOOL haveStart = NO, haveEnd = NO;
    NSInteger startSection, endSection;
    
    int sectionNdx;
    for (sectionNdx = 0; sectionNdx < numSections; ++sectionNdx)
    {
        if (self.sectionData.count < (sectionNdx + 1))
        {
            [self generateSection:sectionNdx];
        }
        
        UIXPackedLayoutSectionInfo* sectionInfo = self.sectionData[sectionNdx];
        if (!haveStart)
        {
            if (CGRectContainsPoint(sectionInfo.sectionRect, rect.origin))
            {
                haveStart = YES;
                startSection = sectionNdx;
            }
        }
        
        if (!haveEnd)
        {
            if (CGRectContainsPoint(sectionInfo.sectionRect, CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))))
            {
                haveEnd = YES;
                endSection = sectionNdx;
            }
        }
        
        if (haveStart && haveEnd)
        {
            break;
        }
    }
    
    if (sectionNdx > numSections)
    {
        endSection = numSections -1;
    }
    
    NSMutableArray* attrs = [NSMutableArray array];
    for (int sectionNdx = startSection; sectionNdx <= endSection; ++sectionNdx)
    {
        UIXPackedLayoutSectionInfo* sectionInfo = self.sectionData[sectionNdx];
        [attrs addObjectsFromArray: [sectionInfo attrsForRect:rect]];
    }
    
    return attrs;
}
@end
