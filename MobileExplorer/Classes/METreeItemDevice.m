//
//  METreeItemDevice.m
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import "METreeItemDevice.h"

@interface METreeItemDevice ()

@property (nonatomic, readwrite, retain) AMDevice *device;

@end


@implementation METreeItemDevice

- (void)dealloc
{
    [_device release];
    [super dealloc];
}

- (id)initWithDevice:(AMDevice *)device
{
    self = [super init];
    if (self) {
        _device = [device retain];
    }
    return self;
}

- (NSString *)title
{
    return self.device.deviceName;
}

@end
