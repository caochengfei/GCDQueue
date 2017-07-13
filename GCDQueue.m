//
//  GCDQueue.m
//  CCFDispatchOperation
//
//  Created by kidstone on 2017/6/7.
//  Copyright © 2017年 caochengfei. All rights reserved.
//

#import "GCDQueue.h"

@interface GCDQueue ()
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation GCDQueue


+ (void)dispatch_async_main_queue:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)dispatch_async_main_queue:(dispatch_block_t)block delay:(NSTimeInterval)delay {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}


+ (void)dispatch_async_global_queue:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(dispatch_get_global_queue(CCFPriorityDefault, 0), block);
}


+ (void)dispatch_async_global_queue:(dispatch_block_t)block delay:(NSTimeInterval)delay {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_global_queue(CCFPriorityDefault, 0),block);
}

+ (void)dispatch_async_global_queue:(dispatch_block_t)block queuePriority:(CCFQueuePriority)queuePriority {
    NSParameterAssert(block);
    dispatch_async(dispatch_get_global_queue(queuePriority, 0), block);
}


+ (void)dispatch_async_global_queue:(dispatch_block_t)block queuePriority:(CCFQueuePriority)queuePriority delay:(NSTimeInterval)delay {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_global_queue(queuePriority, 0),block);
}


#pragma mark - 创建线程
- (instancetype)initWithSerialThreadIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        self.queue = dispatch_queue_create(identifier.UTF8String, DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}


- (instancetype)initWithConcurrentThreadIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        self.queue = dispatch_queue_create(identifier.UTF8String, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


#pragma mark - 执行任务
- (void)asyncExecute:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(self.queue, block);
}

- (void)asyncExecute:(dispatch_block_t)block delay:(NSTimeInterval)delay {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),self.queue,block);
}

- (void)asyncExecute:(dispatch_block_t)block wait:(GCDSemaphore *)semaphore {
    NSParameterAssert(block);
    // 将执行过程封装在block中，用于信号同步
    dispatch_block_t semaphoreBlock = ^{
        [semaphore wait];
        block();
        [semaphore signal];
    };
    dispatch_async(self.queue, semaphoreBlock);
}

- (void)asyncExecute:(dispatch_block_t)block delay:(NSTimeInterval)delay wait:(GCDSemaphore *)semaphore {
    NSParameterAssert(block);
    dispatch_block_t semaphoreBlock = ^{
        [semaphore wait];
        block();
        [semaphore signal];
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.queue, semaphoreBlock);
}


- (void)resume {
    dispatch_resume(self.queue);
}

- (void)pause {
    dispatch_suspend(self.queue);
}

- (void)asyncExecuteBarrier:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_barrier_async(self.queue, block);
}


- (void)notify:(dispatch_block_t)block inGroup:(GCDGroup *)group {
    NSParameterAssert(block);
    dispatch_group_notify(group.group, self.queue, block);
}

- (void)asyncExecute:(dispatch_block_t)block inGroup:(GCDGroup *)group {
    NSParameterAssert(block);
    dispatch_group_async(group.group, self.queue, block);
}


@end



@interface GCDSemaphore ()
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation GCDSemaphore

- (instancetype)initWithNumber:(NSInteger)number {
    if (self = [super init]) {
        self.semaphore = dispatch_semaphore_create(number);
    }
    return self;
}

- (void)wait {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)waitWithTimeout:(NSTimeInterval)timeout {
    return dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)timeout * NSEC_PER_SEC)) == 0;
}

- (BOOL)signal {
    return dispatch_semaphore_signal(self.semaphore) != 0;
}

@end


@interface GCDGroup ()
@property (nonatomic, strong) dispatch_group_t group;
@end

@implementation GCDGroup

- (instancetype)init {
    if (self = [super init]) {
        self.group = dispatch_group_create();
    }
    return self;
}

- (void)wait {
    dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
}

- (void)enter {
    dispatch_group_enter(self.group);
}

- (void)leave {
    dispatch_group_leave(self.group);
}

- (BOOL)wait:(NSTimeInterval)delay {
    return dispatch_group_wait(self.group, dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC)) == 0;
}

@end
