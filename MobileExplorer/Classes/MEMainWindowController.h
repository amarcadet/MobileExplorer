//
//  MEMainWindowController.h
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import <Cocoa/Cocoa.h>

@class MobileDeviceAccess;

@interface MEMainWindowController : NSWindowController

@property (nonatomic, retain) MobileDeviceAccess *deviceAccess;

- (id)initWithMobileDeviceAccess:(MobileDeviceAccess *)mobileDeviceAccess;

@end
