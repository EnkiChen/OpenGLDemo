//
//  MLOpenGLView.h
//  OpenGLDemo
//
//  Created by Enki on 15/4/22.
//  Copyright (c) 2015年 seewo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLOpenGLView : UIView
- (void)startAnimate;
- (void)stopAnimate;
- (void) addShape:(id) shape;
- (void) scale:(CGFloat) scale anchorPoint:(CGPoint) anchorPoint;
- (void) transform:(CGFloat) tx ty:(CGFloat) ty;
- (void)drawView;
@end
