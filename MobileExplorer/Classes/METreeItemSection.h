//
//  METreeItemSection.h
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import <Cocoa/Cocoa.h>
#import "METreeItem.h"

@interface METreeItemSection : METreeItem

@property (nonatomic, retain) NSString *title;

- (id)initWithTitle:(NSString *)title;

@end
