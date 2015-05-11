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
    
}

- (IBAction)handlePinch:(id)sender {
    
    UIPinchGestureRecognizer *rcognizer = sender;
    
    if ( rcognizer.numberOfTouches == 2 && !isnan(rcognizer.scale) ) {
        
        CGPoint p1 = [rcognizer locationOfTouch: 0 inView:rcognizer.view ];
        CGPoint p2 = [rcognizer locationOfTouch: 1 inView:rcognizer.view ];
        CGPoint anchorPoint = CGPointMake( (p1.x+p2.x)/2,(p1.y+p2.y)/2);
        CGFloat scale = rcognizer.scale;
        [self.openGLView scale:scale anchorPoint:anchorPoint];
        [self.openGLView drawView];
        rcognizer.scale = 1.f;
    }
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
