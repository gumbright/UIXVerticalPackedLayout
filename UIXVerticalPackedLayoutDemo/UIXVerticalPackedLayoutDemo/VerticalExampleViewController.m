//
//  ViewController.m
//  UIXVerticalPackedLayoutDemo
//
//  Created by Guy Umbright on 5/1/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "VerticalExampleViewController.h"
#import "UIXVerticalPackedLayout.h"

#define NUM_ITEMS 30
#define NUM_DATA_ITEMS 10
#define COLUMN_WIDTH 100

@interface VerticalExampleViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView* collection;
@property (nonatomic, strong) NSArray* theData;
@property (nonatomic, strong) NSArray* colors;
@end

@implementation VerticalExampleViewController

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
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:random() % 400],@"height",
                        self.colors[random() % self.colors.count],@"color",nil]];
    }
    self.theData = arr;

    UIXVerticalPackedLayout* layout = (UIXVerticalPackedLayout*) self.collection.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    layout.verticalSpacing = 20;
    layout.columnSpacing = 20;
    layout.justified = NO;
    layout.columnWidth = COLUMN_WIDTH;
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return NUM_ITEMS;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView*) collectinView
{
    return 1;
}

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeForItemAtIndex:(NSIndexPath*) indexPath
{
    CGSize result = CGSizeZero;
    
    NSNumber* n = self.theData[indexPath.item][@"height"];
    result = CGSizeMake(COLUMN_WIDTH, [n floatValue]);
    
    return result;
}
@end
