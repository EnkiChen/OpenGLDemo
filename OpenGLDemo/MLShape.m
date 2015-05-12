//
//  MLShape.m
//  OpenGLDemo
//
//  Created by Enki on 15/4/22.
//  Copyright (c) 2015年 seewo. All rights reserved.
//

#import "MLShape.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


static const GLfloat vertexInfoList[] = {
    -150.f, 150.f, 0.0f,       // top left
    -150.f, -150.f, 0.0f,      // bottom left
    150.f, 150.f, 0.0f,        // top right
    150.f, -150.f, 0.0f,       // bottom right
};

static const GLfloat colorInfoList[] = {
    0.99f, 0.01f, 0.01f, 1.0f,
    0.01f, 0.99f, 0.01, 1.0f,
    0.01f, 0.01f, 0.99f, 1.0f,
    0.01f, 0.02f, 0.01f, 1.0f
};

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

@interface MLShape ()

@property (nonatomic, assign) CGPoint contrlLocation;
@property (nonatomic, assign) CGPoint basePoint;

@end

@implementation MLShape
{
    GLuint vao;
    GLuint vboVertices, vboColors;
    NSMutableArray *_points;
    Vertex3D *_pVertex3D;
    BOOL isVAO;
    CGFloat _scale;
    CGFloat _offsetX;
    CGFloat _offsetY;
    
    
}

- (instancetype) init
{
    self = [super init];
    if ( self ) {
        _scale = 1.f;
        _offsetX = 0.f;
        _offsetY = 0.f;
        _points = [NSMutableArray array];
        GLsizeiptr vertexsize = sizeof(Vertex3D) * 5000;
        _pVertex3D = malloc( vertexsize );
    }
    
    return self;
}

- (void) setInitPoint:(CGPoint) point
{
    [self addBezierPoint:[NSValue valueWithCGPoint:point]];
    self.basePoint = point;
    self.contrlLocation = point;
}

- (void) addTouchPoint:(CGPoint) point
{
    CGPoint midpoint = midPoint(point, self.contrlLocation);
    
    [self updateBezier:self.basePoint control1:self.contrlLocation control2:midpoint];
    
    self.basePoint = midpoint;
    self.contrlLocation = point;
}

- (void) addBezierPoint:(NSValue*) value
{
    if ( value ) {
        [_points addObject:value];
        CGPoint point = [value CGPointValue];
        _pVertex3D[_points.count-1].x = point.x * [UIScreen mainScreen].scale;
        _pVertex3D[_points.count-1].y = point.y * [UIScreen mainScreen].scale;
    }
}

- (NSMutableArray*) updateBezier:(CGPoint) p0 control1:(CGPoint) p1 control2:(CGPoint) p2
{
    NSMutableArray *bezierpoint = [NSMutableArray array];
    
    for ( CGFloat t = 0.1; t <= 1.0; t += 0.1 ) {
        
        CGPoint p = CGPointZero;
        p.x = pow( 1 - t , 2) * p0.x + 2 * t * (1-t) * p1.x + pow(t, 2) * p2.x;
        p.y = pow( 1 - t , 2) * p0.y + 2 * t * (1-t) * p1.y + pow(t, 2) * p2.y;
        
        [self addBezierPoint:[NSValue valueWithCGPoint:p]];
    }
    
    return bezierpoint;
}

- (void) updateGenBuffers
{
    return;
    isVAO = YES;
    GLsizeiptr vertexsize = sizeof(Vertex3D) * _points.count;
    Vertex3D *pv = malloc( vertexsize );
    GLvoid *pdata = pv;
    for ( NSValue *value in _points ) {
        CGPoint point = [value CGPointValue];
        pv->x = point.x * [UIScreen mainScreen].scale;
        pv->y = point.y * [UIScreen mainScreen].scale;
        pv++;
    }
    
    glGenVertexArraysOES(1, &vao);  // 生成VAO
    glBindVertexArrayOES(vao);      // 绑定VAO
    
    glGenBuffers(1, &vboVertices);  // 生成顶点VBO
    glBindBuffer(GL_ARRAY_BUFFER, vboVertices); // 绑定VBO
    // 指定顶点缓存数据
    glBufferData(GL_ARRAY_BUFFER, vertexsize, pdata, GL_STATIC_DRAW);
    // 注意这里对glEnableClientState(GL_VERTEX_ARRAY)的调用必须紧跟着glVertexPointer，否则调用无效！
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*)0);
    
    // 取消VAO的绑定
    glBindVertexArrayOES(0);
    glDisableClientState(GL_VERTEX_ARRAY);
    free(pdata);
}

- (void) scale:(CGFloat) scale anchorPoint:(CGPoint) anchorPoint
{
    anchorPoint.x *= [UIScreen mainScreen].scale;
    anchorPoint.y *= [UIScreen mainScreen].scale;
    
    _scale *= scale;
    _offsetX = anchorPoint.x * scale - anchorPoint.x;
    _offsetY = anchorPoint.y * scale - anchorPoint.y;
    
    for ( int i = 0; i < _points.count; i++ ) {
    
        _pVertex3D[i].x *= scale;
        _pVertex3D[i].y *= scale;
        
        _pVertex3D[i].x -= _offsetX;
        _pVertex3D[i].y -= _offsetY;
        
    }
}

- (void) transform:(CGFloat) tx ty:(CGFloat) ty
{
    for ( int i = 0; i < _points.count; i++ ) {
        
        _pVertex3D[i].x += tx * [UIScreen mainScreen].scale;
        _pVertex3D[i].y += ty * [UIScreen mainScreen].scale;
        
    }
}

- (void) draw
{
    glColor4f(0.9, 0.9f, 0.9f, 1.f);
    glLineWidth(2.f);
    glPointSize(2.f);
    
    if ( isVAO ) {
        
        glBindVertexArrayOES(vao);
        glDrawArrays(GL_LINE_STRIP, 0, (GLsizei)_points.count);
        
    } else {
    
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(2, GL_FLOAT, 0, (const GLvoid*)_pVertex3D);
        glDrawArrays(GL_LINE_STRIP, 0, (GLsizei)_points.count);
        glVertexPointer(2, GL_FLOAT, 0, (const GLvoid*)_pVertex3D);
        glDrawArrays(GL_POINTS, 0, (GLsizei)_points.count);
        glDisableClientState(GL_VERTEX_ARRAY);
    
    }

}


- (void) setup
{
    glGenVertexArraysOES(1, &vao);  // 生成VAO
    glBindVertexArrayOES(vao);      // 绑定VAO
    
    glGenBuffers(1, &vboVertices);  // 生成顶点VBO
    glBindBuffer(GL_ARRAY_BUFFER, vboVertices); // 绑定VBO
    // 指定顶点缓存数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexInfoList), vertexInfoList, GL_STATIC_DRAW);
    // 注意这里对glEnableClientState(GL_VERTEX_ARRAY)的调用必须紧跟着glVertexPointer，否则调用无效！
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*)0);
    
    glGenBuffers(1, &vboColors);    // 生成颜色VBO
    glBindBuffer(GL_ARRAY_BUFFER, vboColors);   // 绑定VBO
    // 指定颜色缓存数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(colorInfoList), colorInfoList, GL_STATIC_DRAW);
    // 注意这里对glEnableClientState(GL_COLOR_ARRAY)的调用必须紧跟着glColorPointer，否则调用无效！
    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(4, GL_FLOAT, 0, (const GLvoid*)0);

    // 取消VAO的绑定
    glBindVertexArrayOES(0);
}



- (void) dealloc
{
    free(_pVertex3D);
    glDeleteVertexArraysOES(1, &vao);
    glDeleteBuffers(1, &vboVertices);
    glDeleteBuffers(1, &vboColors);
}

@end
