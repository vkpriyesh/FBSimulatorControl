/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBFramebufferImage.h"

#import <AppKit/AppKit.h>

#import "FBSimulatorEventSink.h"

@interface FBFramebufferImage ()

@property (nonatomic, strong, readonly) id<FBSimulatorEventSink> eventSink;
@property (nonatomic, assign, readonly) NSTimeInterval timePeriod;
@property (nonatomic, copy, readwrite) NSDate *nextUpdate;

@end

@implementation FBFramebufferImage

+ (instancetype)withEventSink:(id<FBSimulatorEventSink>)eventSink notifyingPeriodically:(NSTimeInterval)timePeriod
{
  return [[self alloc] initWithEventSink:eventSink notifyingPeriodically:timePeriod];
}

- (instancetype)initWithEventSink:(id<FBSimulatorEventSink>)eventSink notifyingPeriodically:(NSTimeInterval)timePeriod
{

  self = [super init];
  if (!self) {
    return nil;
  }

  _eventSink = eventSink;
  _timePeriod = timePeriod;
  _nextUpdate = NSDate.distantPast;

  return self;
}

#pragma mark FBFramebufferDelegate Implementation

- (void)framebuffer:(FBSimulatorFramebuffer *)framebuffer didGetSize:(CGSize)size
{
}

- (void)framebufferDidUpdate:(FBSimulatorFramebuffer *)framebuffer withImage:(CGImageRef)imageRef size:(CGSize)size
{
  if ([NSDate.date isLessThanOrEqualTo:self.nextUpdate]) {
    return;
  }
  self.nextUpdate = [NSDate.date dateByAddingTimeInterval:self.timePeriod];
  NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:size];

  dispatch_async(dispatch_get_main_queue(), ^{
    [self.eventSink diagnosticInformationAvailable:@"image" process:nil value:image];
  });
}

- (void)framebufferDidBecomeInvalid:(FBSimulatorFramebuffer *)framebuffer error:(NSError *)error
{
}

@end
