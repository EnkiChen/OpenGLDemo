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
    
    MLShape *tempShape = [[MLShape alloc] init];
    
    [self getBezier:CGPointMake(1024.f / 4, 768.f / 2.f)
           control1:CGPointMake(1024.f / 2, 768.f / 4.f)
           control2:CGPointMake(1024.f / 4 * 3, 768.f / 2.f)
              shape:tempShape];
    [self.openGLView addShape:tempShape];
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
        [self.shape setInitPoint:locationPoint];
        [self.openGLView addShape:self.shape];
        
    } else if ( UIGestureRecognizerStateChanged == tapGesture.state ) {
    
        [self.shape addTouchPoint:locationPoint];
        [self.openGLView drawView];
        
    } else if ( UIGestureRecognizerStateEnded == tapGesture.state ) {
        
        [self.shape addTouchPoint:locationPoint];
        
        [self.shape updateGenBuffers];
        [self.openGLView drawView];
        self.shape = nil;
    }
    
}

- (IBAction) handleTrasdform:(UIPanGestureRecognizer*) sender
{
    UIPanGestureRecognizer *panGesture = sender;
    
    CGPoint translation = [panGesture translationInView:panGesture.view];
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
    
    if ( UIGestureRecognizerStateBegan == panGesture.state ) {
        
        [self.openGLView transform:translation.x ty:translation.y];
        
    } else if ( UIGestureRecognizerStateChanged == panGesture.state ) {
        
        [self.openGLView transform:translation.x ty:translation.y];
        [self.openGLView drawView];
        
    } else if ( UIGestureRecognizerStateEnded == panGesture.state ) {
        
        [self.openGLView transform:translation.x ty:translation.y];
        [self.openGLView drawView];
    }
}

- (NSMutableArray*) getBezier:(CGPoint) p0 control1:(CGPoint) p1 control2:(CGPoint) p2 shape:(MLShape*) shape
{
    NSMutableArray *bezierpoint = [NSMutableArray array];
    
    for ( CGFloat t = 0.01; t < 1.0; t += 0.01 ) {
        CGPoint p = CGPointZero;
        p.x = pow( 1 - t , 2) * p0.x + 2 * t * (1-t) * p1.x + pow(t, 2) * p2.x;
        p.y = pow( 1 - t , 2) * p0.y + 2 * t * (1-t) * p1.y + pow(t, 2) * p2.y;
        
        [shape addBezierPoint:[NSValue valueWithCGPoint:p]];
    }
    
    return bezierpoint;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
