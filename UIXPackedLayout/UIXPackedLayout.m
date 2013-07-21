//
//  UIXPackedLayout.m
//  
//
//  Created by Guy Umbright on 6/25/13.
//
//

#import "UIXPackedLayout.h"

@interface UIXPackedLayout ()
@end

@implementation UIXPackedLayout
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) commonInit
{
    self.sectionInset = UIEdgeInsetsZero;
    self.justified = NO;
    self.layoutData = nil;
    self.headerData = nil;
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
    
    for (UICollectionViewLayoutAttributes* attr in self.headerData)
    {
        CGRect intersect = CGRectIntersection(rect, attr.frame);
        if (!CGRectIsEmpty(intersect))
        {
            [result addObject:attr];
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

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    
}

@end
