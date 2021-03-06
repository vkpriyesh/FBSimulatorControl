/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <FBSimulatorControl/FBSimulatorPool.h>

@class FBSimulatorApplication;
@class FBSimulatorConfiguration;
@class FBSimulatorControlConfiguration;
@class FBSimulatorSession;
@protocol FBSimulatorLogger;

/**
 The Root Class for the FBSimulatorControl Framework.
 */
@interface FBSimulatorControl : NSObject

#pragma mark Initializers

/**
 Creates and returns a new `FBSimulatorControl` instance.

 @param configuration the Configuration to setup the instance with.
 @param logger the logger to use to verbosely describe what is going on. May be nil.
 @param error any error that occurred during instantiation.
 @returns a new FBSimulatorControl instance.
 */
+ (instancetype)withConfiguration:(FBSimulatorControlConfiguration *)configuration logger:(id<FBSimulatorLogger>)logger error:(NSError **)error;

/**
 Creates and returns a new `FBSimulatorControl` instance.

 @param configuration the Configuration to setup the instance with.
 @param error any error that occurred during instantiation.
 @returns a new FBSimulatorControl instance.
 */
+ (instancetype)withConfiguration:(FBSimulatorControlConfiguration *)configuration error:(NSError **)error;

#pragma mark Framework Loading

/**
 Loads all of the Frameworks upon which FBSimulatorControl depends.
 This method *must* be called before any class in FBSimulatorControl can be used.
 In order to do this automatically, set `FBSIMULATORCONTROL_AUTOMATICALLY_LOAD_FRAMEWORKS`.

 @param logger the Logger to log events to.
 @param error any error that occurred during performing the preconditions.
 @returns YES if FBSimulatorControl is usable, NO otherwise.
 */
+ (BOOL)loadPrivateFrameworks:(id<FBSimulatorLogger>)logger error:(NSError **)error;

/**
 Calls +[FBSimulatorControl loadPrivateFrameworks:error], aborting in the event the Frameworks could not be loaded
 */
+ (void)loadPrivateFrameworksOrAbort;

#pragma mark Session

/**
 Creates and returns a new FBSimulatorSession instance. Does not launch the Simulator or any Applications.

 @param simulatorConfiguration the Configuration of the Simulator to Launch.
 @param options the options to for the allocation/freeing of the Simulator.
 @param error an outparam for describing any error that occured during the creation of the Session.
 @returns A new `FBSimulatorSession` instance, or nil if an error occured.
 */
- (FBSimulatorSession *)createSessionForSimulatorConfiguration:(FBSimulatorConfiguration *)simulatorConfiguration options:(FBSimulatorAllocationOptions)options error:(NSError **)error;

#pragma mark Properties

/**
 The Pool that the FBSimulatorControl instance uses.
 */
@property (nonatomic, strong, readonly) FBSimulatorPool *simulatorPool;

/**
 The Configuration that FBSimulatorControl uses.
 */
@property (nonatomic, copy, readwrite) FBSimulatorControlConfiguration *configuration;

@end
