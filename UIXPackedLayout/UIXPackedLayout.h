//
//  UIXPackedLayout.h
//  
//
//  Created by Guy Umbright on 6/25/13.
//
//

@class UIXPackedLayout;

@protocol UIXPackedLayoutDelegate <NSObject>

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeForItemAtIndex:(NSIndexPath*) indexPath;

@optional
- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeOfHeaderForSection:(NSInteger) section;

@end

@interface UIXPackedLayout : UICollectionViewLayout
@property (nonatomic, weak) IBOutlet NSObject<UIXPackedLayoutDelegate>* delegate;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) BOOL justified; //forces first and last to edges and spreads rest in between
//could also have mode where if the seperation is beyond some threshold it instead centers like <edge><pad><item><pad><item><pad><edge>

@property (nonatomic, strong) NSArray* layoutData;
@property (nonatomic, strong) NSArray* headerData;

@property (nonatomic, assign) CGSize layoutContentSize;

@end
