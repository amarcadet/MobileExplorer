//
//  METreeItemSection.m
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import "METreeItemSection.h"

@implementation METreeItemSection

- (void)dealloc
{
    [_title release];
    [super dealloc];
}

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title = [title retain];
    }
    return self;
}

@end
