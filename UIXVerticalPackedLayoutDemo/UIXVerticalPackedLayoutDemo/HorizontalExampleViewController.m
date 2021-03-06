//
//  ViewController.m
//  UIXVerticalPackedLayoutDemo
//
//  Created by Guy Umbright on 5/1/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "HorizontalExampleViewController.h"
#import "UIXHorizontalPackedLayout.h"
#import "HorizontalHeader.h"

#define NUM_ITEMS 30
#define NUM_DATA_ITEMS 10
#define ROW_HEIGHT 100

@interface HorizontalExampleViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView* collection;
@property (nonatomic, strong) NSArray* theData;
@property (nonatomic, strong) NSArray* colors;
@end

@implementation HorizontalExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    srandom(time(NULL));
    
    
    self.colors = [NSArray arrayWithObjects:[UIColor purpleColor],[UIColor orangeColor],[UIColor magentaColor],[UIColor cyanColor],[UIColor blueColor],[UIColor greenColor], [UIColor redColor],[UIColor purpleColor],nil];

    [self.collection registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellWithReuseIdentifier:@"cell"];

    NSMutableArray* arr = [NSMutableArray array];
    for (int ndx = 0; ndx < NUM_ITEMS; ++ndx)
    {
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:random() % 400],@"width",
                        self.colors[random() % self.colors.count],@"color",nil]];
    }
    self.theData = arr;

    UIXHorizontalPackedLayout* layout = (UIXHorizontalPackedLayout*) self.collection.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    layout.horizontalSpacing = 20;
    layout.rowSpacing = 20;
    layout.justified = NO;
    layout.rowHeight = ROW_HEIGHT;
    
    [self.collection registerNib:[UINib nibWithNibName:@"HorizontalHeader" bundle:nil]
      forSupplementaryViewOfKind:@"header"
             withReuseIdentifier:@"header"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* data = self.theData[indexPath.item];
//    NSNumber* n = data[@"height"];
    
    UICollectionViewCell* cell = [self.collection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor=data[@"color"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* header = [self.collection dequeueReusableSupplementaryViewOfKind:@"header"
                                                                           withReuseIdentifier:@"header"
                                                                                  forIndexPath:indexPath];
    HorizontalHeader* hh = (HorizontalHeader*) header;
    hh.label.text = [NSString stringWithFormat:@"Section #%d",indexPath.section];
    return header;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return NUM_ITEMS;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView*) collectinView
{
    return 2;
}

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeForItemAtIndex:(NSIndexPath*) indexPath
{
    CGSize result = CGSizeZero;
    
    NSNumber* n = self.theData[indexPath.item][@"width"];
    result = CGSizeMake([n floatValue],ROW_HEIGHT);
    
    return result;
}

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeOfHeaderForSection:(NSInteger)section
{
    CGSize result = CGSizeZero;
    
    result = CGSizeMake(self.collection.bounds.size.width,50);
    
    return result;
}
@end
