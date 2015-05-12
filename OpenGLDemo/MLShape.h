//
//  MLShape.h
//  OpenGLDemo
//
//  Created by Enki on 15/4/22.
//  Copyright (c) 2015年 seewo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct _Vertex{
    GLfloat x;
    GLfloat y;
}Vertex3D;

@interface MLShape : NSObject

- (void) setInitPoint:(CGPoint) point;
- (void) addTouchPoint:(CGPoint) point;
- (void) addBezierPoint:(NSValue*) value;
- (void) updateGenBuffers;
- (void) draw;
- (void) scale:(CGFloat) scale anchorPoint:(CGPoint) anchorPoint;
- (void) transform:(CGFloat) tx ty:(CGFloat) ty;
@end
