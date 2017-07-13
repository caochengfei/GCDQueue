//
//  GCDQueue.h
//  CCFDispatchOperation
//
//  Created by kidstone on 2017/6/7.
//  Copyright © 2017年 caochengfei. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDSemaphore;
@class GCDGroup;

/**
 CCFPriorityHigh  最高优先级
 CCFPriorityLow   最低优先级
 CCFPriorityDefault  默认优先级
 CCFBPriorityackground 后台优先级
 */
typedef NS_ENUM(NSInteger, CCFQueuePriority) {
    CCFPriorityHigh         = DISPATCH_QUEUE_PRIORITY_HIGH,
    CCFPriorityDefault      = DISPATCH_QUEUE_PRIORITY_DEFAULT,
    CCFPriorityLow          = DISPATCH_QUEUE_PRIORITY_LOW,
    CCFBPriorityackground   = DISPATCH_QUEUE_PRIORITY_BACKGROUND
};

@interface GCDQueue : NSObject

@property (nonatomic, readonly, strong) dispatch_queue_t queue;


/**
 调度主队列
 */

+ (void)dispatch_async_main_queue:(dispatch_block_t)block;

/**
 调度全局队列
 */
+ (void)dispatch_async_global_queue:(dispatch_block_t)block;

/**
 调度全局队列
 @param queuePriority 优先级
 */
+ (void)dispatch_async_global_queue:(dispatch_block_t)block
                      queuePriority:(CCFQueuePriority)queuePriority;

/**
 延迟调度主队列
 */
+ (void)dispatch_async_main_queue:(dispatch_block_t)block
                                delay:(NSTimeInterval)delay;
/**
 延迟调度全局队列
 */
+ (void)dispatch_async_global_queue:(dispatch_block_t)block
                              delay:(NSTimeInterval)delay;
/**
 延迟调度全局队列
 @param queuePriority 优先级
 */
+ (void)dispatch_async_global_queue:(dispatch_block_t)block
                      queuePriority:(CCFQueuePriority)queuePriority
                              delay:(NSTimeInterval)delay;


#pragma mark - 创建线程

/**
 创建带标识符的串行线程
 */
- (instancetype)initWithSerialThreadIdentifier:(NSString *)identifier;

/**
 创建带标识符的并发线程
 */
- (instancetype)initWithConcurrentThreadIdentifier:(NSString *)identifier;


#pragma mark - 执行任务
/**
 执行任务
 */
- (void)asyncExecute:(dispatch_block_t)block;

/**
 延迟执行任务
 @param delay 延迟时间
 */
- (void)asyncExecute:(dispatch_block_t)block delay:(NSTimeInterval)delay;

/**
 同步并发执行任务
 @param semaphore 信号量
 */
- (void)asyncExecute:(dispatch_block_t)block wait:(GCDSemaphore *)semaphore;
/**
 同步并发执行任务
 @param delay 延迟时间
 @param semaphore 信号量
 */
- (void)asyncExecute:(dispatch_block_t)block delay:(NSTimeInterval)delay wait:(GCDSemaphore *)semaphore;

/**
 开始，恢复任务
 */
- (void)resume;

/**
 暂停
 */
- (void)pause;

/**
 等待前面的任务执行结束后再执行，并且后面的任务等待该任务执行完成之后才会执行.
 */
- (void)asyncExecuteBarrier:(dispatch_block_t)block;

#pragma mark - 其他操作
- (void)notify:(dispatch_block_t)block inGroup:(GCDGroup *)group;
- (void)asyncExecute:(dispatch_block_t)block inGroup:(GCDGroup *)group;

@end

#pragma mark - DispatchSemaphore
@interface GCDSemaphore : NSObject
@property (nonatomic, readonly, strong) dispatch_semaphore_t semaphore;

- (instancetype)initWithNumber:(NSInteger)number;

- (void)wait;
- (BOOL)waitWithTimeout: (NSTimeInterval)timeout;
- (BOOL)signal;

@end

#pragma mark - DispatchGroup
@interface GCDGroup : NSObject

@property (nonatomic, readonly, strong) dispatch_group_t group;

- (void)wait;
- (void)enter;
- (void)leave;
- (BOOL)wait:(NSTimeInterval)delay;


@end
