//
//  VerticalSingleColumnExampleViewController.m
//  UIXVerticalPackedLayoutDemo
//
//  Created by Guy Umbright on 5/1/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "VerticalSingleColumnExampleViewController.h"
#import "UIXVerticalPackedLayout.h"

#define NUM_ITEMS 20
#define NUM_DATA_ITEMS 10
#define COLUMN_WIDTH 400

@interface VerticalSingleColumnExampleViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView* collection;
@property (nonatomic, strong) NSMutableArray* theData;
@property (nonatomic, strong) NSArray* colors;
@end

@implementation VerticalSingleColumnExampleViewController

- (NSDictionary*) generateDataItem
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:random() % 300],@"height",
            self.colors[random() % self.colors.count],@"color",nil];
}

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
        [arr addObject:[self generateDataItem]];
    }
    self.theData = arr;

    UIXVerticalPackedLayout* layout = (UIXVerticalPackedLayout*) self.collection.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    layout.verticalSpacing = 20;
    layout.columnSpacing = 20;
    layout.justified = NO;
    layout.columnWidth = COLUMN_WIDTH;
    layout.singleColumn = YES;
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
    return self.theData.count;
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

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (IBAction) addRandomPressed:(id) sender
{
   NSInteger n = random() % self.theData.count;
   
   NSDictionary* newItem = [self generateDataItem];
   
   [self.theData insertObject:newItem atIndex:n];
   [self.collection insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:n  inSection:0]]];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (IBAction) removeRandomPressed:(id) sender
{
    NSInteger n = random() % self.theData.count;
        
    [self.theData removeObjectAtIndex:n];
    [self.collection deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:n  inSection:0]]];
}

@end
