//
//  ViewController.m
//  OpenGLDemo
//
//  Created by Enki on 15/4/22.
//  Copyright (c) 2015年 seewo. All rights reserved.
//

#import "ViewController.h"
#import "MLOpenGLView.h"
#import "MLShape.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MLOpenGLView *openGLView;
@property (nonatomic, strong) MLShape *shape;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.shape = [[MLShape alloc] init];
    
    [self.shape addPoint:[NSValue valueWithCGPoint:CGPointMake(0.f, 0.f)]];
    for ( int i = 0; i<100; i++ ) {
        [self.shape addPoint:[NSValue valueWithCGPoint:CGPointMake(rand() % 200 , rand() % 200)]];
    }
    
    [self.openGLView addShape:self.shape];
    [self.shape updateGenBuffers];
    
//    [self.openGLView startAnimate];
    
}

- (IBAction)handlePinch:(id)sender {
    
    UIPinchGestureRecognizer *rcognizer = sender;
    [self.openGLView setScal:rcognizer.scale];
    [self.openGLView drawView];
    rcognizer.scale = 1.f;
}

- (IBAction)handleTap:(id)sender {
    
    UIPanGestureRecognizer *tapGesture = sender;
    
    CGPoint locationPoint = [tapGesture locationInView:tapGesture.view];

    if ( UIGestureRecognizerStateBegan == tapGesture.state ) {
        
        self.shape = [[MLShape alloc] init];
        [self.shape addPoint:[NSValue valueWithCGPoint:locationPoint]];
        [self.shape addPoint:[NSValue valueWithCGPoint:locationPoint]];
        [self.openGLView addShape:self.shape];
        
    } else if ( UIGestureRecognizerStateChanged == tapGesture.state ) {
    
        [self.shape addPoint:[NSValue valueWithCGPoint:locationPoint]];
        [self.openGLView drawView];
        
    } else if ( UIGestureRecognizerStateEnded == tapGesture.state ) {
        
        [self.shape addPoint:[NSValue valueWithCGPoint:locationPoint]];
        [self.shape updateGenBuffers];
        [self.openGLView drawView];
        self.shape = nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
