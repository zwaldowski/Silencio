//
//  Silencio.m
//  Silencio
//
//  Created by Zachary Waldowski on 1/9/15.
//  Copyright (c) 2015 Zachary Waldowski. All rights reserved.
//


#import "Silencio.h"
#import <IDELanguageSupportUI/IDEPlaygroundDocument.h>
@import ObjectiveC.runtime;
#import "JRSwizzle.h"

@interface NSObject ()

- (void)sln_sourceLanguageServiceAvailabilityNotification:(BOOL)show message:(id)message;

@end

static void SLN_empty_sourceLanguageServiceAvailabilityNotification_message(id self, SEL _cmd, BOOL show, id message) {
    NSLog(@"!");
    // this method purposefully left empty
}

static NSString *const SLNPluginEnabledKey = @"me.waldowski.Silencio.enabled";

static Silencio *sharedPlugin = nil;
static NSString *const xcodeBundleID = @"com.apple.dt.Xcode";
static Class _IDESourceCodeDocument = Nil;
static Class _IDEPlaygroundDocument = Nil;

@interface Silencio ()

@property (weak) NSMenuItem *enabledMenuItem;
@property (readonly, getter=isPluginEnabled) BOOL pluginEnabled;

@end

@implementation Silencio

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    if ([NSRunningApplication.currentApplication.bundleIdentifier hasPrefix:@"com.apple.dt.Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (instancetype)initWithBundle:(NSBundle *)plugin
{
    self = [super init];
    if (!self) { return nil; }
    
    // reference to plugin's bundle, for resource access
    _bundle = plugin;
    
    // Create menu items, initialize UI, etc.
    [self modifyViewMenu:nil];
    
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc addObserver:self selector:@selector(menuDidChange:) name:NSMenuDidChangeItemNotification object:nil];
    
    // when installing through Alcatraz the application has already launched
    if (NSApplication.sharedApplication.currentEvent) {
        [self applicationDidFinishLaunching:nil];
    } else {
        [nc addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
    }

    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Notifications

- (void)applicationDidFinishLaunching:(NSNotification *)note // NSApplicationDidFinishLaunchingNotification
{
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    NSUserDefaults *sud = NSUserDefaults.standardUserDefaults;

    [nc removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    [sud registerDefaults:@{
        SLNPluginEnabledKey: @YES
    }];

    if (self.pluginEnabled) {
        [self swizzleMethods];
    }

}

- (void)menuDidChange:(NSNotification *)note // NSMenuDidChangeItemNotification
{
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc removeObserver:self name:NSMenuDidChangeItemNotification object:nil];
    [self modifyViewMenu:note.object];
}

#pragma mark - Actions


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    return YES;
}

- (void)modifyViewMenu:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMenuItem *menuItem = [NSApplication.sharedApplication.mainMenu itemWithTitle:@"View"];
        NSString *name = [self.bundle objectForInfoDictionaryKey:(__bridge id)kCFBundleNameKey];
        
        if (menuItem != nil && [menuItem.submenu itemWithTitle:name] == nil) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:name action:@selector(togglePlugin:) keyEquivalent:@""];
            [item setTarget:self];
            if (self.pluginEnabled) {
                item.state = NSOnState;
            }
            self.enabledMenuItem = item;
            
            [menuItem.submenu addItem:NSMenuItem.separatorItem];
            [menuItem.submenu addItem:item];
        }
        
        NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
        [nc addObserver:self selector:@selector(menuDidChange:) name:NSMenuDidChangeItemNotification object:nil];
    });
}

- (void)togglePlugin:(id)sender
{
    BOOL newValue = !self.isPluginEnabled;
    [NSUserDefaults.standardUserDefaults setBool:newValue forKey:SLNPluginEnabledKey];
    
    self.enabledMenuItem.state = newValue ? NSOnState : NSOffState;
}

- (BOOL)isPluginEnabled
{
    return [NSUserDefaults.standardUserDefaults boolForKey:SLNPluginEnabledKey];
}

- (void)pluginToggled:(NSNotification *)note
{
    [self swizzleMethods];
}

- (void)swizzleMethods
{
    if (_IDEPlaygroundDocument == Nil) {
        _IDEPlaygroundDocument = objc_lookUpClass("IDEPlaygroundDocument");
        SEL selector = @selector(sln_sourceLanguageServiceAvailabilityNotification:message:);
        class_addMethod(_IDEPlaygroundDocument, selector, (IMP)SLN_empty_sourceLanguageServiceAvailabilityNotification_message, "v@:b@");
    }
    
    if (_IDESourceCodeDocument == Nil) {
        _IDESourceCodeDocument = objc_lookUpClass("IDESourceCodeDocument");
        SEL selector = @selector(sln_sourceLanguageServiceAvailabilityNotification:message:);
        class_addMethod(_IDESourceCodeDocument, selector, (IMP)SLN_empty_sourceLanguageServiceAvailabilityNotification_message, "v@:b@");
    }
    
    [_IDESourceCodeDocument jr_swizzleMethod:@selector(sourceLanguageServiceAvailabilityNotification:message:) withMethod:@selector(sln_sourceLanguageServiceAvailabilityNotification:message:) error:NULL];
    [_IDEPlaygroundDocument jr_swizzleMethod:@selector(sourceLanguageServiceAvailabilityNotification:message:) withMethod:@selector(sln_sourceLanguageServiceAvailabilityNotification:message:) error:NULL];
}

@end
