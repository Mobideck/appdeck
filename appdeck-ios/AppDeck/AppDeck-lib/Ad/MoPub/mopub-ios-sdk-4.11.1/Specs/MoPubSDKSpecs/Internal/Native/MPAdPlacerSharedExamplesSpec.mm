//
//  MPAdPlacerSharedExamplesSpec.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPAdPlacerSharedExamplesSpec.h"
#import "MPStreamAdPlacer.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

NSString *aUICollectionAdPlacerThatWrapsItsDelegateAndDataSource = @"a UI collection ad placer that wraps its delegate and data source";
NSString *aTwoArgumentDelegateOrDataSourceMethod = @"a 2-argument delegate / data source method";
NSString *aThreeArgumentDelegateOrDataSourceMethod = @"a 3-argument delegate / data source method";
NSString *aDelegateOrDataSourceMethod = @"a delegate / data source method";
NSString *aDelegateOrDataSourceMethodThatReturnsAnObject = @"a delegate/data source method that returns an object";
NSString *aDelegateOrDataSourceMethodThatReturnsABOOL = @"a delegate/data source method that returns a BOOL";
NSString *aDelegateOrDataSourceMethodThatReturnsAnNSInteger = @"a delegate/data source method that returns an NSInteger";
NSString *aSelectOrDeselectRowAtIndexPathMethod = @"a select / deselect rowAtIndexPath method";
NSString *aDelegateOrDataSourceMethodThatContainsASelector = @"a delegate / data source method that contains a selector";

@interface MPAdPlacerExamplesHelper : NSObject

+ (void)constructExampleVariablesWithContext:(NSDictionary *)sharedContext
                        uiCollectionAdPlacer:(id *)uiCollectionAdPlacer
                          fakeStreamAdPlacer:(MPStreamAdPlacer **)fakeStreamAdPlacer
                                  methodName:(NSString **)methodName
                              methodSelector:(SEL *)methodSelector
                            methodInvocation:(NSInvocation **)methodInvocation
                          fakeOriginalObject:(id<CedarDouble> *)fakeOriginalObject;
@end

@implementation MPAdPlacerExamplesHelper

+ (void)constructExampleVariablesWithContext:(NSDictionary *)sharedContext
                        uiCollectionAdPlacer:(id *)uiCollectionAdPlacer
                          fakeStreamAdPlacer:(MPStreamAdPlacer **)fakeStreamAdPlacer
                                  methodName:(NSString **)methodName
                              methodSelector:(SEL *)methodSelector
                            methodInvocation:(NSInvocation **)methodInvocation
                          fakeOriginalObject:(id<CedarDouble> *)fakeOriginalObject
{
    id localUICollectionAdPlacer = sharedContext[@"uiCollectionAdPlacer"];
    MPStreamAdPlacer *localFakeStreamAdPlacer = sharedContext[@"fakeStreamAdPlacer"];

    NSString *localMethodName = sharedContext[@"methodName"];
    SEL localMethodSelector = NSSelectorFromString(localMethodName);
    NSMethodSignature *methodSignature = [[localUICollectionAdPlacer class] instanceMethodSignatureForSelector:localMethodSelector];
    NSInvocation *localMethodInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];

    [localMethodInvocation setTarget:localUICollectionAdPlacer];
    [localMethodInvocation setSelector:localMethodSelector];

    NSInteger argIndex = 2;
    NSArray *arguments = sharedContext[@"arguments"];
    for (id arg in arguments) {
        if ([arg isKindOfClass:[NSNumber class]]) {
            // Assuming anything that comes in as NSNumber is of NSInteger type.
            NSInteger intValue = [arg integerValue];
            [localMethodInvocation setArgument:&intValue atIndex:argIndex];
        } else {
            [localMethodInvocation setArgument:(void *)&(arg) atIndex:argIndex];
        }

        ++argIndex;
    }

    // Just assign everything now.
    *uiCollectionAdPlacer = localUICollectionAdPlacer;
    *fakeStreamAdPlacer = localFakeStreamAdPlacer;

    *methodName = localMethodName;
    *methodSelector = localMethodSelector;
    *methodInvocation = localMethodInvocation;

    if (fakeOriginalObject) {
        *fakeOriginalObject = sharedContext[@"fakeOriginalObject"];
    }
}

@end

SHARED_EXAMPLE_GROUPS_BEGIN(MPAdPlacerSharedExamples)

// uiCollectionAdPlacer is something like a UITableViewAdPlacer or UICollectionViewAdPlacer
sharedExamplesFor(aTwoArgumentDelegateOrDataSourceMethod, ^(NSDictionary *sharedContext) {
    __block NSString *methodName;
    __block NSInvocation *methodInvocation;
    __block SEL methodSelector;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;

    beforeEach(^{
        [MPAdPlacerExamplesHelper constructExampleVariablesWithContext:sharedContext
                                                  uiCollectionAdPlacer:&uiCollectionAdPlacer
                                                    fakeStreamAdPlacer:&fakeStreamAdPlacer
                                                            methodName:&methodName
                                                        methodSelector:&methodSelector
                                                      methodInvocation:&methodInvocation
                                                    fakeOriginalObject:&fakeOriginalObject];
    });

    context(@"when invoking the delegate / data source method on the original object", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
            fakeOriginalObject stub_method(methodSelector);
        });

        it(@"should convert the given index path to its original version to give to the original object's delegate / data source method", ^{
            NSIndexPath *testPath = [NSIndexPath indexPathForRow:43 inSection:1];
            fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(testPath);

            [methodInvocation invoke];

            __unsafe_unretained id arg1;
            [methodInvocation getArgument:&arg1 atIndex:2];

            fakeOriginalObject should have_received(methodSelector).with(arg1).and_with(testPath);
        });
    });
});

sharedExamplesFor(aThreeArgumentDelegateOrDataSourceMethod, ^(NSDictionary *sharedContext) {
    __block NSString *methodName;
    __block NSInvocation *methodInvocation;
    __block SEL methodSelector;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;

    beforeEach(^{
        [MPAdPlacerExamplesHelper constructExampleVariablesWithContext:sharedContext
                                                  uiCollectionAdPlacer:&uiCollectionAdPlacer
                                                    fakeStreamAdPlacer:&fakeStreamAdPlacer
                                                            methodName:&methodName
                                                        methodSelector:&methodSelector
                                                      methodInvocation:&methodInvocation
                                                    fakeOriginalObject:&fakeOriginalObject];
    });

    // Right now this only supports testing as of iOS 8.  Later methods may pass something that is not an integer or object to the 2nd arg of a method.
    context(@"when invoking the delegate / data source method on the original object", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
            fakeOriginalObject stub_method(methodSelector);
        });

        it(@"should convert the given index path to its original version to give to the original object's delegate / data source method", ^{
            NSIndexPath *testPath = [NSIndexPath indexPathForRow:43 inSection:1];
            fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(testPath);

            [methodInvocation invoke];

            __unsafe_unretained id arg1;
            [methodInvocation getArgument:&arg1 atIndex:2];

            const char *actualArgumentEncoding = [methodInvocation.methodSignature getArgumentTypeAtIndex:3];

            if (strcmp(actualArgumentEncoding, "i") == 0 || strcmp(actualArgumentEncoding, "q") == 0) {
                // integer case.
                NSInteger i;
                [methodInvocation getArgument:&i atIndex:3];
                fakeOriginalObject should have_received(methodSelector).with(arg1).and_with(i).and_with(testPath);
            } else if (strcmp(actualArgumentEncoding, "@") == 0) {
                __unsafe_unretained id arg2;
                [methodInvocation getArgument:&arg2 atIndex:3];

                // Check if it's an index path.  Translate it to the original path if it is.
                // Since we stubbed originalIndexPathForAdjustedIndexPath: to return testPath, we can just pass testPath in for arg2.
                if ([arg2 isKindOfClass:[NSIndexPath class]]) {
                    fakeOriginalObject should have_received(methodSelector).with(arg1).and_with(testPath).and_with(testPath);
                } else {
                    // Otherwise if it's an object there is (probably) no translation to do so we'll just pass arg2 through as-is.
                    fakeOriginalObject should have_received(methodSelector).with(arg1).and_with(arg2).and_with(testPath);
                }
            } else {
                [NSException raise:@"Unsupported type" format:@"Unsupported type for shared example for %@ with type: %s", aThreeArgumentDelegateOrDataSourceMethod, actualArgumentEncoding];
            }
        });
    });
});

sharedExamplesFor(aDelegateOrDataSourceMethod, ^(NSDictionary *sharedContext) {
    __block NSString *methodName;
    __block NSInvocation *methodInvocation;
    __block SEL methodSelector;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;

    beforeEach(^{
        [MPAdPlacerExamplesHelper constructExampleVariablesWithContext:sharedContext
                                                  uiCollectionAdPlacer:&uiCollectionAdPlacer
                                                    fakeStreamAdPlacer:&fakeStreamAdPlacer
                                                            methodName:&methodName
                                                        methodSelector:&methodSelector
                                                      methodInvocation:&methodInvocation
                                                    fakeOriginalObject:&fakeOriginalObject];
    });

    context(@"when there is not an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should not call the method on the original object", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });
        });

        context(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should call the method on the original object", ^{
                fakeOriginalObject should have_received(methodSelector);
            });
        });
    });

    context(@"when there is an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should not call the method on the original object", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });
        });

        context(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should not call the method on the original object", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });
        });
    });
});

sharedExamplesFor(aDelegateOrDataSourceMethodThatReturnsAnObject, ^(NSDictionary *sharedContext) {
    __block NSString *methodName;
    __block NSInvocation *methodInvocation;
    __block SEL methodSelector;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __block id defaultReturnValue;
    __block id selectorStubReturnValue;
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;

    beforeEach(^{
        [MPAdPlacerExamplesHelper constructExampleVariablesWithContext:sharedContext
                                                  uiCollectionAdPlacer:&uiCollectionAdPlacer
                                                    fakeStreamAdPlacer:&fakeStreamAdPlacer
                                                            methodName:&methodName
                                                        methodSelector:&methodSelector
                                                      methodInvocation:&methodInvocation
                                                    fakeOriginalObject:&fakeOriginalObject];
        defaultReturnValue = sharedContext[@"defaultReturnValue"];
        selectorStubReturnValue = sharedContext[@"defaultTestValue"];
    });

    context(@"when there is not an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
            });

            it(@"should return default return value", ^{
                __unsafe_unretained id returnValue;
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });

        context(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector).and_return(selectorStubReturnValue);
            });

            it(@"should return whatever the original object is set up to return", ^{
                __unsafe_unretained id returnValue;
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(selectorStubReturnValue);
            });
        });
    });

    context(@"when there is an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                [methodInvocation invoke];
            });

            it(@"should return default return value", ^{
                __unsafe_unretained id returnValue;
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });

        describe(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector).and_return(selectorStubReturnValue);
                [methodInvocation invoke];
            });

            it(@"should not call the original object's method", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });

            it(@"should return default return value", ^{
                __unsafe_unretained id returnValue;
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });
    });
});

sharedExamplesFor(aDelegateOrDataSourceMethodThatReturnsABOOL, ^(NSDictionary *sharedContext) {
    __block NSString *methodName;
    __block NSInvocation *methodInvocation;
    __block SEL methodSelector;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __block BOOL defaultReturnValue;
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;

    beforeEach(^{
        [MPAdPlacerExamplesHelper constructExampleVariablesWithContext:sharedContext
                                                  uiCollectionAdPlacer:&uiCollectionAdPlacer
                                                    fakeStreamAdPlacer:&fakeStreamAdPlacer
                                                            methodName:&methodName
                                                        methodSelector:&methodSelector
                                                      methodInvocation:&methodInvocation
                                                    fakeOriginalObject:&fakeOriginalObject];
        defaultReturnValue = [sharedContext[@"defaultReturnValue"] boolValue];
    });

    context(@"when there is not an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
            });

            it(@"should return default return value", ^{
                BOOL returnValue = !defaultReturnValue;
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });

        context(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector).and_return(YES);
            });

            it(@"should return whatever the original object is set up to return", ^{
                BOOL returnValue = NO;
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(YES);
            });
        });
    });

    describe(@"when there is an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should return default return value", ^{
                BOOL returnValue = !defaultReturnValue;
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });

        describe(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector).and_return(YES);
                [methodInvocation invoke];
            });

            it(@"should not call the original object's method", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });

            it(@"should return default return value", ^{
                BOOL returnValue = !defaultReturnValue;
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });
    });
});

sharedExamplesFor(aDelegateOrDataSourceMethodThatReturnsAnNSInteger, ^(NSDictionary *sharedContext) {
    __block NSString *methodName;
    __block NSInvocation *methodInvocation;
    __block SEL methodSelector;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __block NSInteger defaultReturnValue;
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;

    beforeEach(^{
        [MPAdPlacerExamplesHelper constructExampleVariablesWithContext:sharedContext
                                                  uiCollectionAdPlacer:&uiCollectionAdPlacer
                                                    fakeStreamAdPlacer:&fakeStreamAdPlacer
                                                            methodName:&methodName
                                                        methodSelector:&methodSelector
                                                      methodInvocation:&methodInvocation
                                                    fakeOriginalObject:&fakeOriginalObject];

        defaultReturnValue = [sharedContext[@"defaultReturnValue"] intValue];
    });

    context(@"when there is not an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
            });

            it(@"should return default return value", ^{
                NSInteger returnValue = defaultReturnValue+1;
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });

        describe(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector).and_return(defaultReturnValue+9);
            });

            it(@"should return whatever the original object is set up to return", ^{
                NSInteger returnValue = defaultReturnValue+1;
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue+9);
            });
        });
    });

    describe(@"when there is an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should return default return value", ^{
                NSInteger returnValue = defaultReturnValue+1;
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });

        context(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector).and_return(defaultReturnValue+10);
                [methodInvocation invoke];
            });

            it(@"should not call the original object's method", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });

            it(@"should return default return value", ^{
                NSInteger returnValue = defaultReturnValue+11;
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(defaultReturnValue);
            });
        });
    });
});

sharedExamplesFor(aSelectOrDeselectRowAtIndexPathMethod, ^ (NSDictionary *sharedContext) {
    __block NSString *methodName;
    __block SEL methodSelector;
    __block NSInvocation *methodInvocation;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __unsafe_unretained __block NSIndexPath *returnValue;
    __block NSIndexPath *indexPath;
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;

    beforeEach(^{
        [MPAdPlacerExamplesHelper constructExampleVariablesWithContext:sharedContext
                                                  uiCollectionAdPlacer:&uiCollectionAdPlacer
                                                    fakeStreamAdPlacer:&fakeStreamAdPlacer
                                                            methodName:&methodName
                                                        methodSelector:&methodSelector
                                                      methodInvocation:&methodInvocation
                                                    fakeOriginalObject:&fakeOriginalObject];

        indexPath = sharedContext[@"arguments"][1];
    });

    context(@"when there is an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
        });

        it(@"should return the index path given to it", ^{
            [methodInvocation invoke];
            [methodInvocation getReturnValue:&returnValue];
            NSArray *arguments = [sharedContext objectForKey:@"arguments"];
            NSIndexPath *path = [arguments objectAtIndex:1];
            returnValue should equal(path);
        });
    });

    context(@"when there is no ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
        });

        context(@"when the original object doesn't respond to the selector", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
            });

            it(@"should return the same indexPath", ^{
                returnValue = [NSIndexPath indexPathForItem:200 inSection:1];
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(indexPath);
            });
        });

        context(@"when the original object does respond to the selector", ^{
            __block NSIndexPath *delegateStubPath;
            __block NSIndexPath *placerStubPath;
            __block NSIndexPath *adjustedPlacerPath;

            beforeEach(^{
                delegateStubPath = [NSIndexPath indexPathForRow:2 inSection:1];
                placerStubPath = [NSIndexPath indexPathForRow:1 inSection:1];
                adjustedPlacerPath = [NSIndexPath indexPathForRow:39 inSection:1];

                fakeOriginalObject stub_method(methodSelector).and_return(delegateStubPath);
                fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(placerStubPath);
                fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do(^(NSInvocation *invocation) {
                    __unsafe_unretained NSIndexPath *path;
                    [invocation getArgument:&path atIndex:2];

                    if (path == delegateStubPath) {
                        [invocation setReturnValue:&adjustedPlacerPath]; // Return something that signifies the correct thing was passed in.
                    } else {
                        return [invocation setReturnValue:&delegateStubPath]; // Return something incorrect.
                    }
                });
            });

            it(@"should return the adjusted path for the original object's original path", ^{
                [methodInvocation invoke];
                [methodInvocation getReturnValue:&returnValue];
                returnValue should equal(adjustedPlacerPath);
            });
        });
    });
});


sharedExamplesFor(aDelegateOrDataSourceMethodThatContainsASelector, ^(NSDictionary *sharedContext) {
    __block NSIndexPath *indexPath;
    __block NSString *methodName;
    __block NSInvocation *methodInvocation;
    __block SEL methodSelector;
    __block SEL argumentSelector;
    __block id<CedarDouble> fakeOriginalObject; // delegate or data source
    __block NSObject *sender;
    __block id uiCollectionAdPlacer;
    __block MPStreamAdPlacer *fakeStreamAdPlacer;
    __block UITableView *tableView;

    beforeEach(^{
        uiCollectionAdPlacer = sharedContext[@"uiCollectionAdPlacer"];
        fakeStreamAdPlacer = sharedContext[@"fakeStreamAdPlacer"];
        tableView = sharedContext[@"view"];
        sender = [[NSObject alloc] init];
        indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
        methodName = sharedContext[@"methodName"];
        methodSelector = NSSelectorFromString(methodName);
        argumentSelector = NSSelectorFromString(sharedContext[@"argumentSelector"]);

        NSMethodSignature *methodSignature = [[uiCollectionAdPlacer class] instanceMethodSignatureForSelector:methodSelector];
        methodInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];

        [methodInvocation setTarget:uiCollectionAdPlacer];
        [methodInvocation setSelector:methodSelector];

        [methodInvocation setArgument:&tableView atIndex:2];
        [methodInvocation setArgument:&argumentSelector atIndex:3];
        [methodInvocation setArgument:&indexPath atIndex:4];
        [methodInvocation setArgument:&sender atIndex:5];

        fakeOriginalObject = sharedContext[@"fakeOriginalObject"];
    });

    context(@"when there is not an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should not call the method on the original object", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });
        });

        describe(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should call the method on the original object", ^{
                fakeOriginalObject should have_received(methodSelector);
            });

            it(@"should pass the original index path to the original object's method", ^{
                NSIndexPath *testPath = [NSIndexPath indexPathForRow:43 inSection:1];
                fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(testPath);

                [methodInvocation invoke];
                fakeOriginalObject should have_received(methodSelector).with(tableView).and_with(argumentSelector).and_with(testPath).and_with(sender);
            });
        });
    });

    context(@"when there is an ad at the index path", ^{
        beforeEach(^{
            fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
        });

        context(@"when the original object doesn't respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject reject_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should not call the method on the original object", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });
        });

        context(@"when the original object does respond to the method", ^{
            beforeEach(^{
                fakeOriginalObject stub_method(methodSelector);
                [methodInvocation invoke];
            });

            it(@"should not call the method on the original object", ^{
                fakeOriginalObject should_not have_received(methodSelector);
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
