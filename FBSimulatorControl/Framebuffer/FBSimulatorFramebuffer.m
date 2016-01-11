/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBSimulatorFramebuffer.h"

#import <AppKit/AppKit.h>

#import <SimulatorKit/SimDeviceFramebufferBackingStore.h>
#import <SimulatorKit/SimDeviceFramebufferService.h>

#import "FBFramebufferCompositeDelegate.h"
#import "FBFramebufferDebugWindow.h"
#import "FBFramebufferDelegate.h"
#import "FBFramebufferImage.h"
#import "FBFramebufferVideo.h"
#import "FBSimulator.h"
#import "FBSimulatorEventSink.h"
#import "FBSimulatorLaunchConfiguration.h"
#import "FBSimulatorLogger.h"

/**
 Enumeration to keep track of internal state.
 */
typedef NS_ENUM(NSInteger, FBSimulatorFramebufferState) {
  FBSimulatorFramebufferStateNotStarted = 0, /** Before the framebuffer is 'listening'. */
  FBSimulatorFramebufferStateStarting = 1, /** After the framebuffer has started, but before the first frame. */
  FBSimulatorFramebufferStateRunning = 3, /** After the framebuffer has started, but before the first frame. */
  FBSimulatorFramebufferStateTerminated = 4, /** After the framebuffer has terminated. */
};

@interface FBSimulatorFramebuffer () <FBFramebufferDelegate>

@property (nonatomic, strong, readonly) SimDeviceFramebufferService *framebufferService;
@property (nonatomic, strong, readonly) id<FBSimulatorEventSink> eventSink;
@property (nonatomic, strong, readonly) id<FBSimulatorLogger> logger;

@property (nonatomic, strong, readonly) id<FBFramebufferDelegate> delegate;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@property (nonatomic, assign, readwrite) FBSimulatorFramebufferState state;
@property (nonatomic, assign, readwrite) NSUInteger counter;
@property (nonatomic, assign, readwrite) CGSize size;

@end

@implementation FBSimulatorFramebuffer

#pragma mark Initializers

+ (instancetype)withFramebufferService:(SimDeviceFramebufferService *)framebufferService configuration:(FBSimulatorLaunchConfiguration *)launchConfiguration simulator:(FBSimulator *)simulator {
  NSMutableArray *sinks = [NSMutableArray array];
  BOOL useWindow = (launchConfiguration.framebufferOptions & FBSimulatorDirectLaunchCreateDebugWindow) == FBSimulatorDirectLaunchCreateDebugWindow;
  if (useWindow) {
    [sinks addObject:[FBFramebufferDebugWindow withName:@"Simulator"]];
  }
  if (launchConfiguration.videoPath) {
    [sinks addObject:[FBFramebufferVideo withPath:launchConfiguration.videoPath logger:simulator.logger eventSink:simulator.eventSink]];
  }
  [sinks addObject:[FBFramebufferImage withEventSink:simulator.eventSink notifyingPeriodically:10]];

  id<FBFramebufferDelegate> delegate = [FBFramebufferCompositeDelegate withDelegates:[sinks copy]];
  return [[self alloc] initWithFramebufferService:framebufferService eventSink:simulator.eventSink logger:simulator.logger delegate:delegate];
}

- (instancetype)initWithFramebufferService:(SimDeviceFramebufferService *)framebufferService eventSink:(id<FBSimulatorEventSink>)eventSink logger:(id<FBSimulatorLogger>)logger delegate:(id<FBFramebufferDelegate>)delegate
{
  NSParameterAssert(framebufferService);

  self = [super init];
  if (!self) {
    return nil;
  }

  _framebufferService = framebufferService;
  _eventSink = eventSink;
  _delegate = delegate;
  _logger = logger;

  _queue = dispatch_queue_create("com.facebook.FBSimulatorControl.simulatorframebuffer", DISPATCH_QUEUE_SERIAL);
  _state = FBSimulatorFramebufferStateNotStarted;
  _size = CGSizeZero;
  _counter = 0;

  return self;
}

#pragma mark NSObject

- (NSString *)description
{
  return [NSString stringWithFormat:
    @"%@ | Size %@ | Frame Counter %lu",
    [FBSimulatorFramebuffer stringFromFramebufferState:self.state],
    NSStringFromSize(self.size),
    (unsigned long)self.counter
  ];
}

#pragma mark Public

- (void)startListeningInBackground;
{
  NSParameterAssert(self.state == FBSimulatorFramebufferStateNotStarted);

  self.state = FBSimulatorFramebufferStateStarting;
  [self.framebufferService registerClient:self onQueue:self.queue];
  [self.framebufferService resume];
}

- (void)stopListening
{
  NSParameterAssert(self.state != FBSimulatorFramebufferStateNotStarted);
  NSParameterAssert(self.state != FBSimulatorFramebufferStateTerminated);

  [self framebufferDidBecomeInvalid:self error:nil];
}

#pragma mark Client Callbacks from SimDeviceFramebufferService

- (void)framebufferService:(SimDeviceFramebufferService *)service didFailWithError:(NSError *)error
{
  [self.delegate framebufferDidBecomeInvalid:self error:error];
}

- (void)framebufferService:(SimDeviceFramebufferService *)service didRotateToAngle:(double)angle
{
  [self.logger.info logFormat:@"Framebuffer %@ did rotate to angle %f", service, angle];
}

- (void)framebufferService:(SimDeviceFramebufferService *)service didUpdateRegion:(CGRect)region ofBackingStore:(SimDeviceFramebufferBackingStore *)backingStore
{
  self.counter++;
  [self framebuffer:self didGetSize:CGSizeMake(backingStore.pixelsWide, backingStore.pixelsHigh)];
  [self.delegate framebufferDidUpdate:self withImage:backingStore.image size:NSMakeSize(backingStore.pixelsWide, backingStore.pixelsHigh)];
}

#pragma mark Internal Delegate Forwarding

- (void)framebuffer:(FBSimulatorFramebuffer *)framebuffer didGetSize:(CGSize)size
{
  if (self.state != FBSimulatorFramebufferStateStarting) {
    return;
  }

  self.state = FBSimulatorFramebufferStateRunning;
  [self.delegate framebuffer:framebuffer didGetSize:size];
}

- (void)framebufferDidUpdate:(FBSimulatorFramebuffer *)framebuffer withImage:(CGImageRef)image size:(CGSize)size
{
  if (self.state != FBSimulatorFramebufferStateRunning) {
    return;
  }

  [self.delegate framebufferDidUpdate:framebuffer withImage:image size:size];
}

- (void)framebufferDidBecomeInvalid:(FBSimulatorFramebuffer *)framebuffer error:(NSError *)error
{
  if (self.state != FBSimulatorFramebufferStateStarting && self.state != FBSimulatorFramebufferStateRunning) {
    return;
  }

  [self.framebufferService unregisterClient:self];
  [self.framebufferService suspend];
  [self.delegate framebufferDidBecomeInvalid:self error:error];
  [self.eventSink framebufferDidTerminate:self expected:(error != nil)];
}

#pragma mark Private

+ (NSString *)stringFromFramebufferState:(FBSimulatorFramebufferState)state
{
  switch (state) {
    case FBSimulatorFramebufferStateNotStarted:
      return @"Not Started";
    case FBSimulatorFramebufferStateStarting:
      return @"Starting";
    case FBSimulatorFramebufferStateRunning:
      return @"Running";
    case FBSimulatorFramebufferStateTerminated:
      return @"Terminated";
    default:
      return @"Unknown";
  }
}

@end
