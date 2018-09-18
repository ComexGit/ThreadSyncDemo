//
//  TSLockMgr.h
//  ThreadSyncDemo
//
//  Created by UncleDrew on 2018/9/16.
//  Copyright © 2018年 UncleDrew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LockType) {
    LockTypeOSSpinLock = 0,
    LockTypedispatch_semaphore,
    LockTypepthread_mutex,
    LockTypeNSCondition,
    LockTypeNSLock,
    LockTypepthread_mutex_recursive,
    LockTypeNSRecursiveLock,
    LockTypeNSConditionLock,
    LockTypesynchronized,
    LockTypepthread_rwlock,
    LockTypeos_unfair_lock,
    LockTypeCount,
};

extern NSTimeInterval TimeCosts[LockTypeCount];
extern int TimeCount;

@interface TSLockMgr : NSObject

+ (void)test:(int)count;
+ (void)printTimeConst:(NSTimeInterval *)timeCosts;

@end
