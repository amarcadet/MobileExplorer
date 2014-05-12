//
//  MEAppDelegate.m
//  MobileExplorer
//
//  Created by Antoine on 28/02/11.
//

#import <MobileDeviceAccess.h>

#import "MEAppDelegate.h"
#import "MEMainWindowController.h"

@interface MEAppDelegate ()

@property (nonatomic, retain) MEMainWindowController *mainWindowController;

@end


@implementation MEAppDelegate

- (void)dealloc
{
    [_mainWindowController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _mainWindowController = [[MEMainWindowController alloc] initWithMobileDeviceAccess:[MobileDeviceAccess singleton]];
    [_mainWindowController showWindow:self];
}

@end
