//
//  MEMainWindowController.m
//  MobileExplorer
//
//  Created by Antoine on 26/02/11.
//

#import <MobileDeviceAccess.h>

#import "MEMainWindowController.h"

#import "METreeItem.h"
#import "METreeItemDevice.h"
#import "METreeItemSection.h"
#import "MEOutlineView.h"

static dispatch_queue_t me_mobile_device_access_queue()
{
    static dispatch_once_t onceToken;
    static dispatch_queue_t __me_mobile_device_access_queue;
    dispatch_once(&onceToken, ^{
        __me_mobile_device_access_queue = dispatch_queue_create("mobiledeviceaccess", DISPATCH_QUEUE_CONCURRENT);
    });
    return __me_mobile_device_access_queue;
}

@interface MEMainWindowController () <NSOutlineViewDelegate, NSOutlineViewDataSource, MobileDeviceAccessListener, NSSplitViewDelegate>

@property (nonatomic, retain) IBOutlet MEOutlineView *leftOutlineView;

@property (nonatomic, retain) IBOutlet NSSplitView *splitView;
@property (nonatomic, retain) IBOutlet NSView *leftView;
@property (nonatomic, retain) IBOutlet NSView *rightView;

@property (nonatomic, retain) IBOutlet NSView *detailView;
@property (nonatomic, retain) IBOutlet NSTextField *deviceNameField;
@property (nonatomic, retain) IBOutlet NSTextField *deviceModelField;
@property (nonatomic, retain) IBOutlet NSTextField *deviceUDIDField;
@property (nonatomic, retain) IBOutlet NSTextField *deviceSerialField;
@property (nonatomic, retain) IBOutlet NSTableView *deviceApplicationsTableView;
@property (nonatomic, retain) IBOutlet NSTextField *deviceInstalledApplicationCountLabel;

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableDictionary *keyedItems;

@property (nonatomic, retain) METreeItemSection *deviceSection;

@property (nonatomic, retain) AMDevice *selectedDevice;
@property (nonatomic, retain) NSArray *selectedDeviceApplications;

@end


@implementation MEMainWindowController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSOutlineViewSelectionDidChangeNotification object:self.leftOutlineView];

    [_leftOutlineView release];

    [_splitView release];
    [_leftView release];
    [_rightView release];

    [_detailView release];
    [_deviceNameField release];
    [_deviceModelField release];
    [_deviceUDIDField release];
    [_deviceSerialField release];
    [_deviceApplicationsTableView release];
    [_deviceInstalledApplicationCountLabel release];

    [_deviceSection release];

    [_items release];
    [_keyedItems release];

    [_deviceAccess release];

    [super dealloc];
}

- (id)initWithMobileDeviceAccess:(MobileDeviceAccess *)mobileDeviceAccess
{
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        self.items = [NSMutableArray array];
        self.keyedItems = [NSMutableDictionary dictionary];

        self.deviceSection = [[METreeItemSection alloc] initWithTitle:@"Devices"];
        [self.items addObject:self.deviceSection];

        self.deviceAccess = mobileDeviceAccess;
        [self.deviceAccess setListener:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outlineViewSelectionDidChange:) name:NSOutlineViewSelectionDidChangeNotification object:self.leftOutlineView];
    }
    return self;
}


#pragma mark -

- (void)windowDidLoad
{
    [super windowDidLoad];

    dispatch_async(me_mobile_device_access_queue(), ^{
        [self.deviceAccess waitForConnection];
    });
}


#pragma mark - NSOutlineViewDatasource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if ([item isKindOfClass:[METreeItem class]]) {
        METreeItem *treeItem = (METreeItem *) item;
        return [treeItem numberOfChildren];
    }
    else {
        return [self.items count];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[METreeItem class]]) {
        METreeItem *treeItem = (METreeItem *) item;
        return [treeItem hasChildren];
    }
    else {
        return NO;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if ([item isKindOfClass:[METreeItem class]]) {
        METreeItem *treeItem = (METreeItem *) item;
        return [treeItem objectAtIndex:index];
    }
    else {
        return [self.items objectAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(METreeItem *)item
{
    return [item title];
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSCell *cell = nil;
    METreeItem *treeItem = (METreeItem *) item;

    if ([treeItem isKindOfClass:[METreeItemSection class]]) {
        NSTextFieldCell *textCell = [[[NSTextFieldCell alloc] initTextCell:treeItem.title] autorelease];
        [textCell setFont:[NSFont boldSystemFontOfSize:13.0]];
        cell = textCell;
    }
    else {
        NSTextFieldCell *textCell = [[[NSTextFieldCell alloc] initTextCell:treeItem.title] autorelease];
        [textCell setFont:[NSFont systemFontOfSize:13.0]];
        cell = textCell;
    }

    return cell;
}


#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if ([item isKindOfClass:[METreeItemDevice class]]) {
        return YES;
    }

    return NO;
}


#pragma mark -

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSOutlineView *outlineViewSelected = (NSOutlineView *) [notification object];

    id selectedItem = [outlineViewSelected itemAtRow:[outlineViewSelected selectedRow]];
    if ([selectedItem isKindOfClass:[METreeItemDevice class]]) {
        self.selectedDevice = ((METreeItemDevice *) [self.leftOutlineView itemAtRow:[self.leftOutlineView selectedRow]]).device;
        self.selectedDeviceApplications = [self.selectedDevice installedApplications];

        self.deviceInstalledApplicationCountLabel.stringValue = [NSString stringWithFormat:@"%@ installed applications:", @([self.selectedDeviceApplications count])];
        self.deviceNameField.stringValue = self.selectedDevice.deviceName;
        self.deviceModelField.stringValue = self.selectedDevice.productType;
        self.deviceUDIDField.stringValue = self.selectedDevice.udid;
        self.deviceSerialField.stringValue = self.selectedDevice.serialNumber;

        NSLog(@"imei %@", [self.selectedDevice deviceValueForKey:@"InternationalMobileEquipmentIdentity"]);

        [self.deviceApplicationsTableView reloadData];
    }
}

- (void)clearDetailView
{
    self.deviceInstalledApplicationCountLabel.stringValue = @"Installed applications:";
    self.deviceNameField.stringValue = @"";
    self.deviceModelField.stringValue = @"";
    self.deviceUDIDField.stringValue = @"";
    self.deviceSerialField.stringValue = @"";
}


#pragma mark - NSTableViewDatasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (self.selectedDeviceApplications) {
        return [self.selectedDeviceApplications count];
    }
    else {
        return 0;
    }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    AMApplication *application = [self.selectedDeviceApplications objectAtIndex:rowIndex];
    NSString *columIdentifier = (NSString *) [aTableColumn identifier];
    if ([columIdentifier isEqualToString:@"applicationName"]) {
        return application.appname;
    }
    else if ([columIdentifier isEqualToString:@"bundleIdentifier"]) {
        return application.bundleid;
    }
    else {
        return @"";
    }
}


#pragma mark - NSSplitViewDelegate

// fixe la taille de la partie gauche de la split view
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    if (sender != self.splitView) {
        return;
    }

    CGFloat dividerThickness = self.splitView.dividerThickness;
    NSRect leftRect = self.leftView.frame;
    NSRect rightRect = self.rightView.frame;
    NSRect newFrame = self.splitView.frame;

    leftRect.size.height = newFrame.size.height;
    leftRect.origin = NSMakePoint(.0, .0);
    rightRect.size.width = newFrame.size.width - leftRect.size.width - dividerThickness;
    rightRect.size.height = newFrame.size.height;
    rightRect.origin.x = leftRect.size.width + dividerThickness;

    self.leftView.frame = leftRect;
    self.rightView.frame = rightRect;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == 0) {
        return 180.0;
    }
    else {
        return 450.0;
    }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == 0) {
        return 260.0;
    }
    else {
        return 450.0;
    }
}


#pragma mark - MobileDeviceAccessListener

/// This method will be called whenever a device is connected
- (void)deviceConnected:(AMDevice *)device
{
    METreeItemDevice *deviceItem = [[METreeItemDevice alloc] initWithDevice:device];
    [self.deviceSection addItem:deviceItem];
    [deviceItem release];

    [self.leftOutlineView reloadData];
}

/// This method will be called whenever a device is disconnected
- (void)deviceDisconnected:(AMDevice *)device
{
    METreeItemDevice *deviceItemToRemove = nil;

    for (METreeItemDevice *deviceItem in self.deviceSection.items) {
        if ([deviceItem.device.udid isEqualToString:device.udid]) {
            deviceItemToRemove = deviceItem;
        }
    }

    if (deviceItemToRemove != nil) {
        self.selectedDevice = nil;
        self.selectedDeviceApplications = nil;
        [self.deviceSection removeItem:deviceItemToRemove];
        [self.leftOutlineView reloadData];
        [self.deviceApplicationsTableView reloadData];
        [self clearDetailView];
    }
}

@end
