#import "MPNativeCache+Specs.h"
#import "MPDiskLRUCache.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static NSString *const kMPCacheTestImageKey = @"kMPCacheTestImageKey";

SPEC_BEGIN(MPNativeCacheSpec)

describe(@"MPNativeCache", ^{
    __block MPNativeCache *cache;
    __block NSData *data;

    beforeEach(^{
        cache = [[MPNativeCache alloc] init];
        data = [kMPCacheTestImageKey dataUsingEncoding:NSUTF8StringEncoding];
    });

    afterEach(^{
        [cache removeAllDataFromCache];
    });

    describe(@"Object storage in MPNativeCache", ^{

        beforeEach(^{
            [cache storeData:data forKey:kMPCacheTestImageKey];
        });

        it(@"should store data successfully", ^{
            BOOL cacheWorks = [cache cachedDataExistsForKey:kMPCacheTestImageKey];
            cacheWorks should equal(YES);
        });

        it(@"should retrieve data successfully", ^{
            NSData *testData = [cache retrieveDataForKey:kMPCacheTestImageKey];
            NSString *retrievedString = [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];
            retrievedString should equal(kMPCacheTestImageKey);
        });

        it(@"should store data correctly in the memory cache", ^{
            BOOL memoryCacheWorks = [[cache memoryCache] objectForKey:kMPCacheTestImageKey] != nil;
            memoryCacheWorks should equal(YES);

            NSData *testData = [[cache memoryCache] objectForKey:kMPCacheTestImageKey];
            NSString *retrievedString = [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];
            retrievedString should equal(kMPCacheTestImageKey);
        });

        it(@"should store data correctly in the disk cache", ^{
            BOOL diskCacheWorks = [[cache diskCache] retrieveDataForKey:kMPCacheTestImageKey] != nil;
            diskCacheWorks should equal(YES);

            NSData *testData = [[cache diskCache] retrieveDataForKey:kMPCacheTestImageKey];
            NSString *retrievedString = [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];
            retrievedString should equal(kMPCacheTestImageKey);
        });

        it(@"should ignore a nil object insertion", ^{
            NSData *testData = nil;
            NSString *nilKey = @"nilKey";

            [cache storeData:testData forKey:nilKey];
            BOOL itemInCache = [cache cachedDataExistsForKey:nilKey];
            itemInCache should equal(NO);
        });
    });

    describe(@"cache's behavior after a memory warning", ^{

        beforeEach(^{
            [cache storeData:data forKey:kMPCacheTestImageKey];
            [cache didReceiveMemoryWarning:nil];
        });

        it(@"should remove objects from memory cache when there's a memory warning", ^{
            BOOL objectInMemory = [[cache memoryCache] objectForKey:kMPCacheTestImageKey] != nil;
            BOOL objectOnDisk = [[cache diskCache] cachedDataExistsForKey:kMPCacheTestImageKey];

            objectInMemory should equal(NO);
            objectOnDisk should equal(YES);
        });

        it(@"should still return that it has the object in the cache", ^{
            BOOL objectInCache = [cache cachedDataExistsForKey:kMPCacheTestImageKey];

            objectInCache should equal(YES);
        });

        it(@"should re-insert object in memory cache during retrieval from disk cache", ^{
            [[cache memoryCache] removeObjectForKey:kMPCacheTestImageKey];
            BOOL objectInMemory = [[cache memoryCache] objectForKey:kMPCacheTestImageKey] != nil;
            objectInMemory should equal(NO);

            NSData *testData = [cache retrieveDataForKey:kMPCacheTestImageKey];
            NSString *retrievedString = [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];
            retrievedString should equal(kMPCacheTestImageKey);

            objectInMemory = [[cache memoryCache] objectForKey:kMPCacheTestImageKey] != nil;
            objectInMemory should equal(YES);
        });
    });

    describe(@"removing objects from the cache", ^{
        beforeEach(^{
            [cache storeData:data forKey:kMPCacheTestImageKey];

            BOOL objectInMemory = [[cache memoryCache] objectForKey:kMPCacheTestImageKey] != nil;
            BOOL objectOnDisk = [[cache diskCache] cachedDataExistsForKey:kMPCacheTestImageKey];

            objectInMemory should equal(YES);
            objectOnDisk should equal(YES);

            [cache removeAllDataFromCache];
        });

        it(@"should successfully remove items from both levels of cache", ^{
            BOOL objectInMemory = [[cache memoryCache] objectForKey:kMPCacheTestImageKey] != nil;
            BOOL objectOnDisk = [[cache diskCache] cachedDataExistsForKey:kMPCacheTestImageKey];

            objectInMemory should equal(NO);
            objectOnDisk should equal(NO);
        });

        it(@"should return that it no longer has the object in the cache", ^{
            BOOL objectInCache = [cache cachedDataExistsForKey:kMPCacheTestImageKey];

            objectInCache should equal(NO);
        });
    });

    describe(@"cache's behavior interacting with disk cache", ^{

        __block MPDiskLRUCache *fakeDiskCache;

        beforeEach(^{
            fakeDiskCache = nice_fake_for([MPDiskLRUCache class]);
            [cache setDiskCache:fakeDiskCache];
        });

        it(@"should safely return on cache miss", ^{
            NSData *data = [cache retrieveDataForKey:@"fake key"];
            data should be_nil;
        });
    });

    describe(@"cache's behavior after turning off memory cache", ^{
        beforeEach(^{
            [cache storeData:data forKey:kMPCacheTestImageKey];
            [cache setInMemoryCacheEnabled:NO];
        });

        afterEach(^{
            [cache setInMemoryCacheEnabled:YES];
        });

        it(@"should store data successfully", ^{
            BOOL cacheWorks = [cache cachedDataExistsForKey:kMPCacheTestImageKey];
            cacheWorks should equal(YES);
        });

        it(@"should retrieve data successfully", ^{
            NSData *testData = [cache retrieveDataForKey:kMPCacheTestImageKey];
            NSString *retrievedString = [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];
            retrievedString should equal(kMPCacheTestImageKey);
        });

        it(@"should store data correctly in the disk cache", ^{
            BOOL diskCacheWorks = [[cache diskCache] retrieveDataForKey:kMPCacheTestImageKey] != nil;
            diskCacheWorks should equal(YES);

            NSData *testData = [[cache diskCache] retrieveDataForKey:kMPCacheTestImageKey];
            NSString *retrievedString = [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];
            retrievedString should equal(kMPCacheTestImageKey);
        });

        it(@"should successfully remove items from memory cache after setting flag", ^{

            BOOL objectOnDisk = [[cache diskCache] cachedDataExistsForKey:kMPCacheTestImageKey];
            BOOL objectInMemory = [[cache memoryCache] objectForKey:kMPCacheTestImageKey] != nil;

            objectOnDisk should equal(YES);
            objectInMemory should equal(NO);
        });
    });
});

SPEC_END
