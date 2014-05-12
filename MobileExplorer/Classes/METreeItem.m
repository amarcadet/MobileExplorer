//
//  METreeItem.m
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import "METreeItem.h"

@interface METreeItem ()

@property (nonatomic, readwrite, retain) NSMutableArray *items;

@end


@implementation METreeItem

- (void)dealloc
{
    [_items release];
    [_image release];

    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Getters & setters

- (NSString *)title
{
    return @"";
}

- (BOOL)hasChildren
{
    return ([self.items count] != 0);
}

#pragma mark - Sub items managment

- (BOOL)addItem:(METreeItem *)item
{
    if (item != nil) {
        [self.items addObject:item];
        return [self.items containsObject:item];
    }

    return NO;
}

- (BOOL)addItem:(METreeItem *)item atIndex:(NSInteger)index
{
    if (item != nil) {
        [self.items insertObject:item atIndex:index];
        return [self.items containsObject:item];
    }

    return NO;
}

- (BOOL)removeItem:(METreeItem *)item
{
    if (item != nil) {
        if (![self.items containsObject:item]) {
            return NO;
        }

        [self.items removeObject:item];
        return ![self.items containsObject:item];
    }

    return NO;
}

- (id)objectAtIndex:(NSInteger)index
{
    return [self.items objectAtIndex:index];
}

- (NSInteger)numberOfChildren
{
    return [self.items count];
}


#pragma mark -

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> { title: %@, items: %@ }",
            NSStringFromClass([self class]),
            self,
            self.title,
            self.items];
}

@end
