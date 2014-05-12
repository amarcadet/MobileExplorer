//
//  MEOutlineView.m
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import "MEOutlineView.h"

@implementation MEOutlineView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypePNG, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo> )sender
{
    NSLog(@"Dragging entered");
    return NSDragOperationNone;
}

- (void)reloadData
{
    [super reloadData];

    for (NSInteger i = 0; i < [self numberOfRows]; i++) {
        NSTreeNode *item = [self itemAtRow:i];
        [self expandItem:item];
    }
}

@end
