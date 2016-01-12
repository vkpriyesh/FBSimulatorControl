/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBCompositeSimulatorEventSink.h"

@interface FBCompositeSimulatorEventSink ()

@property (nonatomic, copy, readwrite) NSArray *sinks;

@end

@implementation FBCompositeSimulatorEventSink

+ (id<FBSimulatorEventSink>)withSinks:(NSArray *)sinks
{
  return [[FBCompositeSimulatorEventSink alloc] initWithSinks:sinks];
}

- (instancetype)initWithSinks:(NSArray *)sinks
{
  self = [super init];
  if (!self) {
    return nil;
  }

  _sinks = sinks;

  return self;
}

- (void)containerApplicationDidLaunch:(FBProcessInfo *)applicationProcess
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink containerApplicationDidLaunch:applicationProcess];
  }
}

- (void)containerApplicationDidTerminate:(FBProcessInfo *)applicationProcess expected:(BOOL)expected
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink containerApplicationDidTerminate:applicationProcess expected:expected];
  }
}

- (void)framebufferDidStart:(FBSimulatorFramebuffer *)framebuffer
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink framebufferDidStart:framebuffer];
  }
}

- (void)framebufferDidTerminate:(FBSimulatorFramebuffer *)framebuffer expected:(BOOL)expected
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink framebufferDidTerminate:framebuffer expected:expected];
  }
}

- (void)simulatorDidLaunch:(FBProcessInfo *)launchdSimProcess
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink simulatorDidLaunch:launchdSimProcess];
  }
}

- (void)simulatorDidTerminate:(FBProcessInfo *)launchdSimProcess expected:(BOOL)expected
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink simulatorDidTerminate:launchdSimProcess expected:expected];
  }
}

- (void)agentDidLaunch:(FBAgentLaunchConfiguration *)launchConfig didStart:(FBProcessInfo *)agentProcess stdOut:(NSFileHandle *)stdOut stdErr:(NSFileHandle *)stdErr
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink agentDidLaunch:launchConfig didStart:agentProcess stdOut:stdOut stdErr:stdErr];
  }
}

- (void)agentDidTerminate:(FBProcessInfo *)processInfo expected:(BOOL)expected
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink agentDidTerminate:processInfo expected:expected];
  }
}

- (void)applicationDidLaunch:(FBApplicationLaunchConfiguration *)launchConfig didStart:(FBProcessInfo *)applicationProcess stdOut:(NSFileHandle *)stdOut stdErr:(NSFileHandle *)stdErr
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink applicationDidLaunch:launchConfig didStart:applicationProcess stdOut:stdOut stdErr:stdErr];
  }
}

- (void)applicationDidTerminate:(FBProcessInfo *)processInfo expected:(BOOL)expected
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink applicationDidTerminate:processInfo expected:expected];
  }
}

- (void)diagnosticInformationAvailable:(NSString *)name process:(FBProcessInfo *)process value:(id<NSCopying, NSCoding>)value
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink diagnosticInformationAvailable:name process:process value:value];
  }
}

- (void)didChangeState:(FBSimulatorState)state
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink didChangeState:state];
  }
}

- (void)terminationHandleAvailable:(id<FBTerminationHandle>)terminationHandle
{
  for (id<FBSimulatorEventSink> sink in self.sinks) {
    [sink terminationHandleAvailable:terminationHandle];
  }
}

@end
