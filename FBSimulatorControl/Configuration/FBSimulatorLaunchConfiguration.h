/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

/**
 A Set of options for framebuffer-based launching.
 */
typedef NS_OPTIONS(NSUInteger, FBSimulatorDirectLaunchLaunch) {
  FBSimulatorDirectLaunchLaunchEnable = 1 << 0, /** Launches Simulators directly with a Framebuffer instead of with Simulator.app */
  FBSimulatorDirectLaunchCreateDebugWindow = 1 << 1, /** Relays the Simulator Framebuffer to a window */
};

/**
 A Value Object for defining how to launch a Simulator.
 */
@interface FBSimulatorLaunchConfiguration : NSObject <NSCoding, NSCopying>

/**
 The Locale in which to Simulate, may be nil.
 */
@property (nonatomic, strong, readonly) NSLocale *locale;

/**
 A String representing the Scale at which to launch the Simulator.
 */
@property (nonatomic, copy, readonly) NSString *scaleString;

/**
 Options for using a useFramebuffer App instead of Xcode's Simulator.app
 */
@property (nonatomic, assign, readonly) FBSimulatorDirectLaunchLaunch framebufferOptions;

/**
 A path to where video should be recorded.
 */
@property (nonatomic, copy, readonly) NSString *videoPath;

#pragma mark Default Instance

+ (instancetype)defaultConfiguration;

#pragma mark Device Scale

/**
 Launch at 25% Scale.
 */
+ (instancetype)scale25Percent;
- (instancetype)scale25Percent;

/**
 Launch at 50% Scale.
 */
+ (instancetype)scale50Percent;
- (instancetype)scale50Percent;

/**
 Launch at 75% Scale.
 */
+ (instancetype)scale75Percent;
- (instancetype)scale75Percent;

/**
 Launch at 100% Scale.
 */
+ (instancetype)scale100Percent;
- (instancetype)scale100Percent;

#pragma mark Locale

/**
 Set the Locale
 */
+ (instancetype)withLocaleNamed:(NSString *)localeName;
- (instancetype)withLocaleNamed:(NSString *)localeName;
+ (instancetype)withLocale:(NSLocale *)locale;
- (instancetype)withLocale:(NSLocale *)locale;

#pragma mark Framebuffer Specific

/**
 Set useFramebuffer Options
 */
+ (instancetype)withDirectLaunchOptions:(FBSimulatorDirectLaunchLaunch)framebufferOptions;
- (instancetype)withDirectLaunchOptions:(FBSimulatorDirectLaunchLaunch)framebufferOptions;

/**
 Set Video output Path.
 */
+ (instancetype)withVideoPath:(NSString *)videoPath;
- (instancetype)withVideoPath:(NSString *)videoPath;

@end
