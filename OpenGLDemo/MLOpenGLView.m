//
//  MLOpenGLView.m
//  OpenGLDemo
//
//  Created by Enki on 15/4/22.
//  Copyright (c) 2015年 seewo. All rights reserved.
//

#import "MLOpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "MLShape.h"

@interface MLOpenGLView ()

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end

@implementation MLOpenGLView
{
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    GLuint msaaFramebuffer, msaaRenderbuffer, msaaDepthbuffer;
    
    CADisplayLink *displayLink;
    GLfloat degree;
    GLfloat _scale;
    
    MLShape *shape;
    
    NSMutableArray *shapes;
    
    Vertex3D horizontalLine[2];
    Vertex3D verticalLine[2];
}

// initialize a CAEAGLLayer object rather than a CALayer object.
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return self.superview;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self setupLayer];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [self setupLayer];
}

- (void) setupLayer
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @NO,
                                     kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    
    degree = 0.0f;
    
    self.userInteractionEnabled = NO;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    
    shape = [[MLShape alloc] init];
    shapes = [NSMutableArray array];
    
    _scale = 1.f;
    
    horizontalLine[0].x = 0.f;
    horizontalLine[0].y = 768 / 2.f * [UIScreen mainScreen].scale;
//    horizontalLine[0].z = 0;
    horizontalLine[1].x = 1024.f * [UIScreen mainScreen].scale;
    horizontalLine[1].y = 768 / 2.f * [UIScreen mainScreen].scale;
//    horizontalLine[1].z = 0;
    
    verticalLine[0].x = 1024 / 2.f * [UIScreen mainScreen].scale;
    verticalLine[0].y = 0.f;
//    verticalLine[0].z = 0;
    verticalLine[1].x = 1024.f / 2.f * [UIScreen mainScreen].scale;
    verticalLine[1].y = 768.f * [UIScreen mainScreen].scale;
//    verticalLine[1].z = 0;
}

- (void)startAnimate
{
    if(displayLink !=nil)
        return;
    displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(animateHandler:)];
    displayLink.frameInterval = 2;  // 30 fps
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) stopAnimate
{
    if(displayLink != nil)
    {
        [displayLink invalidate];
        displayLink = nil;
    }
}

- (void) scale:(CGFloat) scale anchorPoint:(CGPoint) anchorPoint
{
    for ( MLShape *shapeobj in shapes ) {
        [shapeobj scale:scale anchorPoint:anchorPoint];
    }
}

- (void) transform:(CGFloat) tx ty:(CGFloat) ty
{
    for ( MLShape *shapeobj in shapes ) {
        [shapeobj transform:tx ty:ty];
    }
}

- (void) addShape:(id) shapeobj
{
    [shapes addObject:shapeobj];
}

- (void)drawView
{
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    
    // Model view translates
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glScalef(1.f, -1.f, 1.f);
    
    // 绑定FBO
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderbuffer);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glLineWidth(1.f);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, (const GLvoid*)horizontalLine);
    glDrawArrays(GL_LINE_STRIP, 0, 2);
    
    glVertexPointer(2, GL_FLOAT, 0, (const GLvoid*)verticalLine);
    glDrawArrays(GL_LINE_STRIP, 0, 2);
    
    for ( MLShape *shapeobj in shapes ) {
        [shapeobj draw];
    }
    
    // and calling the presentRenderbuffer: method on your rendering context.
    glBindFramebufferOES(GL_READ_FRAMEBUFFER_APPLE, msaaFramebuffer);
    glBindFramebufferOES(GL_DRAW_FRAMEBUFFER_APPLE, viewFramebuffer);
    glResolveMultisampleFramebufferAPPLE();
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    NSLog(@"%.f", ([[NSDate date] timeIntervalSince1970] - start) * 1000);
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (void)animateHandler:(CADisplayLink*)link
{
    degree += 1.0f;
    [self drawView];
    
}

- (BOOL)createFramebuffer
{
    // An OpenGL ES 2.0 application would omit the OES suffix.
    
    // Create the framebuffer and bind it so that future OpenGL ES framebuffer commands are directed to it.
    glGenFramebuffersOES(1, &viewFramebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    // Create a color renderbuffer, allocate storage for it, and attach it to the framebuffer.
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    // Create the color renderbuffer and call the rendering context to allocate the storage on our Core Animation layer.
    // The width, height, and format of the renderbuffer storage are derived from the bounds and properties of the CAEAGLLayer object
    // at the moment the renderbufferStorage:fromDrawable: method is called.
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    // Retrieve the height and width of the color renderbuffer.
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    glGenFramebuffersOES(1, &msaaFramebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
    glGenRenderbuffersOES(1, &msaaRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, 4, GL_RGBA8_OES, backingWidth, backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, msaaRenderbuffer);
    
    // Test the framebuffer for completeness.
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    // Initialize the OpenGL ES context state
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderbuffer);
    
    glViewport(0, 0, backingWidth, backingHeight);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glOrthof(0.f, backingWidth, -backingHeight, 0, -1.0f, 1.0f);
    glClearColor(0.4f, 0.4f, 0.4f, 0.0f);
    
    glEnable(GL_MULTISAMPLE);
    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH, GL_NICEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    

    
    return YES;
}

- (void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    glDeleteFramebuffersOES(1, &msaaFramebuffer);
    msaaFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &msaaRenderbuffer);
    msaaRenderbuffer = 0;
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [self stopAnimate];
    [self destroyFramebuffer];

}

@end
