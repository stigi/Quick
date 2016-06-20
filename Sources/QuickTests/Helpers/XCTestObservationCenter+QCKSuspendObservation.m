@import XCTest;
#import <objc/runtime.h>

@interface XCTestObservationCenter (Redeclaration)
- (NSMutableArray *)observers;
@end

@implementation XCTestObservationCenter (QCKSuspendObservation)

/// This allows us to only suspend observation for observers by provided by Apple
/// as a part of the XCTest framework. In particular it is important that we not
/// suspend the observer added by Nimble, otherwise it is unable to properly
/// report assertion failures.
static BOOL (^isFromApple)(id, NSUInteger, BOOL *) = ^BOOL(id observer, NSUInteger idx, BOOL *stop){
    return [[NSBundle bundleForClass:[observer class]].bundleIdentifier containsString:@"com.apple.dt.XCTest"];
};

- (void)qck_suspendObservationForBlock:(void (^)(void))block {
    NSMutableArray *mutableObservers = [self observers];
    NSIndexSet *indexesOfObserversToSuspend = [mutableObservers indexesOfObjectsPassingTest:isFromApple];
    NSArray *observersToSuspend = [mutableObservers objectsAtIndexes:indexesOfObserversToSuspend];
    [mutableObservers removeObjectsAtIndexes:indexesOfObserversToSuspend];

    @try {
        block();
    }
    @finally {
        [mutableObservers insertObjects:observersToSuspend atIndexes:indexesOfObserversToSuspend];
    }
}

@end
