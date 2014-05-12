//
//  METreeItem.h
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import <Cocoa/Cocoa.h>

@protocol ATTreeItemProtocol

- (NSString *)title;

@end


@interface METreeItem : NSObject <ATTreeItemProtocol>

@property (nonatomic, readonly, retain) NSMutableArray *items;
@property (nonatomic, retain) NSImage *image;

@property (nonatomic, readonly) BOOL hasChildren;

- (BOOL)addItem:(METreeItem *)item;
- (BOOL)addItem:(METreeItem *)item atIndex:(NSInteger)index;
- (BOOL)removeItem:(METreeItem *)item;
- (id)objectAtIndex:(NSInteger)index;
- (NSInteger)numberOfChildren;

@end
