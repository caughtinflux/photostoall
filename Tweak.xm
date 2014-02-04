#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PhotosUI/PUPhotoBrowserController.h>
#import <PhotoLibraryServices/PLManagedAsset.h>

%hook PUPhotoBrowserController

static NSArray *_itemsToAdd = nil;
static NSIndexSet *_insertionIndices = nil;

static UIDocumentInteractionController *_controller = nil;

- (NSArray *)_standardToolbarItemsForCurrentAsset
{
    // This method is called every time the asset changes,
    // which can be a lot when scrolling through media quickly
    // So lets not get repetitive with all the allocations and stuff
    NSArray *ret = %orig();
    if (!ret) {
        return nil;
    }
    if (!_itemsToAdd) {
        UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                 target:self
                                                                                 action:@selector(pta_openDocumentController:)] autorelease];
        UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        _itemsToAdd = [@[flex, button] retain];
        _insertionIndices = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, 2)];
        _controller = [[UIDocumentInteractionController interactionControllerWithURL:self.currentAsset.mainFileURL] retain];
    }   

    NSMutableArray *moddedItems = [[ret mutableCopy] autorelease];
    if (moddedItems.count == 5) {
        // HAXX!
        [moddedItems insertObject:_itemsToAdd[1] atIndex:0];
    }
    else {
        [moddedItems insertObjects:_itemsToAdd atIndexes:_insertionIndices];
    }
    
    return moddedItems;
}

- (void)dealloc
{
    [_itemsToAdd release];
    [_insertionIndices release];
    [_controller release];
    _itemsToAdd = nil;
    _insertionIndices = nil;
    _controller = nil;

    %orig();
}

%new
- (void)pta_openDocumentController:(UIBarButtonItem *)sender
{
    _controller.URL = self.currentAsset.mainFileURL;
    [_controller presentOpenInMenuFromBarButtonItem:sender animated:YES];
}

%end

