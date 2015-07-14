//
//  NSObject_Extension.m
//  SamplePlugin
//
//  Created by Rajesh R. on 7/9/15.
//  Copyright (c) 2015 MyCompany. All rights reserved.
//


#import "NSObject_Extension.h"
#import "SamplePlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[SamplePlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
