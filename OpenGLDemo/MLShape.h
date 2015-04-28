//
//  MLShape.h
//  OpenGLDemo
//
//  Created by Enki on 15/4/22.
//  Copyright (c) 2015年 seewo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLShape : NSObject
- (void) addPoint:(NSValue*) value;
- (void) updateGenBuffers;
- (void) draw;
@end
