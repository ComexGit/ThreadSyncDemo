//
//  TSLockMgr.m
//  ThreadSyncDemo
//
//  Created by UncleDrew on 2018/9/16.
//  Copyright © 2018年 UncleDrew. All rights reserved.
//

#import "TSLockMgr.h"
#import <os/lock.h>
#import <pthread.h>
#import <libkern/OSAtomic.h>
#import <QuartzCore/QuartzCore.h>


NSTimeInterval TimeCosts[LockTypeCount] = {0};
int TimeCount = 0;

@implementation TSLockMgr


//加解锁速度不表示锁的效率，只表示加解锁操作在执行时的复杂程度，因为还需要考虑时间片切换耗时等因素

+ (void)test:(int)count {
    NSTimeInterval begin, end;
    TimeCount += count;
    NSTimeInterval timeCosts[LockTypeCount] = {0};
    
    {
        //优先级反转 不再使用 使用os_unfair_lock替代
        //自旋锁 busy-waiting 消耗cpu资源
        OSSpinLock lock = OS_SPINLOCK_INIT;
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            OSSpinLockLock(&lock);
            OSSpinLockUnlock(&lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeOSSpinLock] += end - begin;
        timeCosts[LockTypeOSSpinLock] = end - begin;
    }
    
    
    {
        dispatch_semaphore_t lock =  dispatch_semaphore_create(1);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypedispatch_semaphore] += end - begin;
        timeCosts[LockTypedispatch_semaphore] = end - begin;
    }
    
    
    {
        pthread_mutex_t lock;
        pthread_mutex_init(&lock, NULL);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            pthread_mutex_lock(&lock);
            pthread_mutex_unlock(&lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypepthread_mutex] += end - begin;
        timeCosts[LockTypepthread_mutex] = end - begin;
        pthread_mutex_destroy(&lock);
    }
    
    
    {
        NSCondition *lock = [NSCondition new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSCondition] += end - begin;
        timeCosts[LockTypeNSCondition] = end - begin;
    }
    
    
    {
        NSLock *lock = [NSLock new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSLock] += end - begin;
        timeCosts[LockTypeNSLock] = end - begin;
    }
    
    
    {
        pthread_mutex_t lock;
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&lock, &attr);
        pthread_mutexattr_destroy(&attr);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            pthread_mutex_lock(&lock);
            pthread_mutex_unlock(&lock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypepthread_mutex_recursive] += end - begin;
        timeCosts[LockTypepthread_mutex_recursive] = end - begin;
        pthread_mutex_destroy(&lock);
    }
    
    
    {
        NSRecursiveLock *lock = [NSRecursiveLock new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSRecursiveLock] += end - begin;
        timeCosts[LockTypeNSRecursiveLock] = end - begin;
    }
    
    {
        NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeNSConditionLock] += end - begin;
        timeCosts[LockTypeNSConditionLock] = end - begin;
    }
    
    {
        pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            pthread_rwlock_wrlock(&rwlock);
            pthread_rwlock_unlock(&rwlock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypepthread_rwlock] += end - begin;
        timeCosts[LockTypepthread_rwlock] = end - begin;
    }
    
    {
        os_unfair_lock_t unfairLock;
        unfairLock = &(OS_UNFAIR_LOCK_INIT);
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            os_unfair_lock_lock(unfairLock);
            os_unfair_lock_unlock(unfairLock);
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypeos_unfair_lock] += end - begin;
        timeCosts[LockTypeos_unfair_lock] = end - begin;
        
    }
    
    {
        NSObject *lock = [NSObject new];
        begin = CACurrentMediaTime();
        for (int i = 0; i < count; i++) {
            @synchronized(lock) {}
        }
        end = CACurrentMediaTime();
        TimeCosts[LockTypesynchronized] += end - begin;
        timeCosts[LockTypesynchronized] = end - begin;
    }
    
    [self printTimeConst:timeCosts];
    
    printf("---- fin (%d) ----\n\n",count);
}

+ (void)printTimeConst:(NSTimeInterval *)timeCosts {
    NSString *OSSpinLock = [NSString stringWithFormat:@"OSSpinLock:               %8.2f ms\n", timeCosts[LockTypeOSSpinLock] * 1000];
    NSString *dispatch_semaphore = [NSString stringWithFormat:@"dispatch_semaphore:       %8.2f ms\n", timeCosts[LockTypedispatch_semaphore] * 1000];
    NSString *pthread_mutex = [NSString stringWithFormat:@"pthread_mutex:            %8.2f ms\n", timeCosts[LockTypepthread_mutex] * 1000];
    NSString *NSCondition = [NSString stringWithFormat:@"NSCondition:              %8.2f ms\n", timeCosts[LockTypeNSCondition] * 1000];
    NSString *NSLock = [NSString stringWithFormat:@"NSLock:                   %8.2f ms\n", timeCosts[LockTypeNSLock] * 1000];
    NSString *pthread_mutex_recursive = [NSString stringWithFormat:@"pthread_mutex(recursive): %8.2f ms\n", timeCosts[LockTypepthread_mutex_recursive] * 1000];
    NSString *NSRecursiveLock = [NSString stringWithFormat:@"NSRecursiveLock:          %8.2f ms\n", timeCosts[LockTypeNSRecursiveLock] * 1000];
    NSString *NSConditionLock = [NSString stringWithFormat:@"NSConditionLock:          %8.2f ms\n", timeCosts[LockTypeNSConditionLock] * 1000];
    NSString *pthread_rwlock = [NSString stringWithFormat:@"pthread_rwlock:           %8.2f ms\n", timeCosts[LockTypepthread_rwlock] * 1000];
    NSString *os_unfair_lock = [NSString stringWithFormat:@"os_unfair_lock:           %8.2f ms\n", timeCosts[LockTypeos_unfair_lock] * 1000];
    NSString *synchronized = [NSString stringWithFormat:@"@synchronized:            %8.2f ms\n", timeCosts[LockTypesynchronized] * 1000];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeOSSpinLock] * 1000] forKey:OSSpinLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypedispatch_semaphore] * 1000] forKey:dispatch_semaphore];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypepthread_mutex] * 1000] forKey:pthread_mutex];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSCondition] * 1000] forKey:NSCondition];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSLock] * 1000] forKey:NSLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypepthread_mutex_recursive] * 1000] forKey:pthread_mutex_recursive];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSRecursiveLock] * 1000] forKey:NSRecursiveLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeNSConditionLock] * 1000] forKey:NSConditionLock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypepthread_rwlock] * 1000] forKey:pthread_rwlock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypeos_unfair_lock] * 1000] forKey:os_unfair_lock];
    [dict setObject:[NSString stringWithFormat:@"%8.2f", timeCosts[LockTypesynchronized] * 1000] forKey:synchronized];
    
    NSArray *relustArray =  [dict keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 doubleValue] > [obj2 doubleValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 doubleValue] < [obj2 doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    for (NSString *string in relustArray) {
        printf("%s", [string UTF8String]);
    }
}


@end
