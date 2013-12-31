#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PhotosUI/PUPhotoBrowserController.h>
#import <PhotoLibraryServices/PLManagedAsset.h>

%hook PUPhotoBrowserController

static NSArray *itemsToAdd = nil;
static NSIndexSet *insertionIndices = nil;

// This needs to be a static variable, since otherwise the controller deallocates in the middle of an activity
// (It is like the UIActivity classes)
static UIDocumentInteractionController *controller = nil;

- (NSArray *)_standardToolbarItemsForCurrentAsset
{
    // This method is called every time the asset changes,
    // which can be a lot when scrolling through media quickly
    // So lets not get repetitive with all the allocations and stuff
    NSArray *ret = %orig();
    if (!ret) {
        return nil;
    }
    if (!itemsToAdd) {
        UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                 target:self
                                                                                 action:@selector(pta_openDocumentController:)] autorelease];
        UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        itemsToAdd = [@[flex, button] retain];
        insertionIndices = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, 2)];
        controller = [[UIDocumentInteractionController interactionControllerWithURL:self.currentAsset.mainFileURL] retain];
    }   
    NSMutableArray *moddedItems = [ret mutableCopy];
    [moddedItems insertObjects:itemsToAdd atIndexes:insertionIndices];
    
    return [moddedItems autorelease];
}

- (void)dealloc
{
    [itemsToAdd release];
    [insertionIndices release];
    [controller release];
    itemsToAdd = nil;
    insertionIndices = nil;
    controller = nil;

    %orig();
}

%new
- (void)pta_openDocumentController:(UIBarButtonItem *)sender
{
    controller.URL = self.currentAsset.mainFileURL;
    [controller presentOpenInMenuFromBarButtonItem:sender animated:YES];
}

%end
