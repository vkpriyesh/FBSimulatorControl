/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <FBSimulatorControl/FBFramebufferDelegate.h>

@protocol FBSimulatorEventSink;

/**
 A class that creates NSImages from the Framebuffer Delegate events.
 */
@interface FBFramebufferImage : NSObject <FBFramebufferDelegate>

/**
 Creates and returns a framebuffer delegate with periodic images.

 @param eventSink the event sink to notify.
 */
+ (instancetype)withEventSink:(id<FBSimulatorEventSink>)eventSink notifyingPeriodically:(NSTimeInterval)timePeriod;

@property (nonatomic, copy, readonly) NSImage *lastImage;

@end
