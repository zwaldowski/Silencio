//
//  Silencio.h
//  Silencio
//
//  Created by Zachary Waldowski on 1/9/15.
//  Copyright (c) 2015 Zachary Waldowski. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface Silencio : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, readonly) NSBundle* bundle;
@end