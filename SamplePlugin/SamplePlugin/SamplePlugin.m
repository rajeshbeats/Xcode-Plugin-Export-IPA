//
//  SamplePlugin.m
//  SamplePlugin
//
//  Created by Rajesh R. on 7/9/15.
//  Copyright (c) 2015 MyCompany. All rights reserved.
//

#import "SamplePlugin.h"
#import "WindowController.h"

@interface SamplePlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) WindowController *wc;
@end

@implementation SamplePlugin

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Export IPA" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    self.wc = [[WindowController alloc] initWithWindowNibName:NSStringFromClass(WindowController.class)];
    [self.wc.window makeKeyWindow];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[[NSApplication sharedApplication] mainWindow] ma]
}

@end
