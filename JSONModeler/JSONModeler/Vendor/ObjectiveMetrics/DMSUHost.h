//
//  DMSUHost.h
//  Sparkle
//
//  Copyright 2008 Andy Matuschak. All rights reserved.
//
// Renamed SUHost -> DMSUHost to prevent symbol conflicts with people who use this library.

#include <Foundation/Foundation.h>

@interface DMSUHost : NSObject
{
@private
	NSBundle *bundle;
}

+ (NSString *)systemVersionString;

- (id)initWithBundle:(NSBundle *)aBundle;
- (NSBundle *)bundle;
- (NSString *)bundlePath;
- (NSString *)name;
- (NSString *)version;
- (NSString *)displayVersion;
- (BOOL)isRunningOnReadOnlyVolume;
- (NSArray *)systemProfile;

- (id)objectForInfoDictionaryKey:(NSString *)key;
- (BOOL)boolForInfoDictionaryKey:(NSString *)key;
- (id)objectForUserDefaultsKey:(NSString *)defaultName;
- (void)setObject:(id)value forUserDefaultsKey:(NSString *)defaultName;
- (BOOL)boolForUserDefaultsKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forUserDefaultsKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
@end
