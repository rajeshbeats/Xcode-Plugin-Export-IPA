//
//  SamplePlugin.h
//  SamplePlugin
//
//  Created by Rajesh R. on 7/9/15.
//  Copyright (c) 2015 MyCompany. All rights reserved.
//

#import <AppKit/AppKit.h>

@class SamplePlugin;

static SamplePlugin *sharedPlugin;

@interface SamplePlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end