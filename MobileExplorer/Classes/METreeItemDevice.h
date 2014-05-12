//
//  METreeItemDevice.h
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import <Cocoa/Cocoa.h>
#import <MobileDeviceAccess.h>

#import "METreeItem.h"

@interface METreeItemDevice : METreeItem

@property (nonatomic, readonly, retain) AMDevice *device;

- (id)initWithDevice:(AMDevice *)device;

@end
