//
//  MainViewController.m
//  UIXVerticalPackedLayoutDemo
//
//  Created by Guy Umbright on 6/24/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "VerticalExampleViewController.h"
#import "HorizontalExampleViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) horizontalPressed:(id)sender
{
    UIViewController* vc = [[HorizontalExampleViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction) verticalPressed:(id)sender
{
    UIViewController* vc = [[VerticalExampleViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
