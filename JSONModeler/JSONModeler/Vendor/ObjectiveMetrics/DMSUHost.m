//
//  DMSUHost.m
//  Sparkle
//
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "DMSUHost.h"

#import "DMSUSystemProfiler.h"
#import <sys/mount.h> // For statfs for isRunningOnReadOnlyVolume

#if TARGET_OS_IPHONE
# import <UIKit/UIKit.h>
#endif

@implementation DMSUHost

- (id)initWithBundle:(NSBundle *)aBundle
{
	if ((self = [super init]))
	{
		if (aBundle == nil) aBundle = [NSBundle mainBundle];
        bundle = [aBundle retain];
		if (![bundle bundleIdentifier])
			NSLog(@"Sparkle Error: the bundle being updated at %@ has no CFBundleIdentifier! This will cause preference read/write to not work properly.", bundle);
    }
    return self;
}

- (void)dealloc
{
	[bundle release];
	[super dealloc];
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], [self bundlePath]]; }

- (NSBundle *)bundle
{
    return bundle;
}

- (NSString *)bundlePath
{
    return [bundle bundlePath];
}

- (NSString *)name
{
	NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (name) return name;
	
	name = [self objectForInfoDictionaryKey:@"CFBundleName"];
	if (name) return name;
	
	return [[[NSFileManager defaultManager] displayNameAtPath:[bundle bundlePath]] stringByDeletingPathExtension];
}

- (NSString *)version
{
	NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (!version || [version isEqualToString:@""])
		[NSException raise:@"SUNoVersionException" format:@"This host (%@) has no CFBundleVersion! This attribute is required.", [self bundlePath]];
	return version;
}

- (NSString *)displayVersion
{
	NSString *shortVersionString = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (shortVersionString)
		return shortVersionString;
	else
		return [self version]; // Fall back on the normal version string.
}

- (BOOL)isRunningOnReadOnlyVolume
{	
	struct statfs statfs_info;
	statfs([[bundle bundlePath] fileSystemRepresentation], &statfs_info);
	return (statfs_info.f_flags & MNT_RDONLY);
}

- (NSArray *)systemProfile
{
	return [[DMSUSystemProfiler sharedSystemProfiler] systemProfileArrayForHost:self];
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
    return [bundle objectForInfoDictionaryKey:key];
}

- (BOOL)boolForInfoDictionaryKey:(NSString *)key
{
	return [[self objectForInfoDictionaryKey:key] boolValue];
}

- (id)objectForUserDefaultsKey:(NSString *)defaultName
{
	// Under Tiger, CFPreferencesCopyAppValue doesn't get values from NSRegistrationDomain, so anything
	// passed into -[NSUserDefaults registerDefaults:] is ignored.  The following line falls
	// back to using NSUserDefaults, but only if the host bundle is the main bundle.
	if (bundle == [NSBundle mainBundle])
		return [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
	
	CFPropertyListRef obj = CFPreferencesCopyAppValue((CFStringRef)defaultName, (CFStringRef)[bundle bundleIdentifier]);
	return [(id)CFMakeCollectable(obj) autorelease];
}

- (void)setObject:(id)value forUserDefaultsKey:(NSString *)defaultName;
{
	// If we're using a .app, we'll use the standard user defaults mechanism; otherwise, we have to get CF-y.
	if (bundle == [NSBundle mainBundle])
	{
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
	}
	else
	{
		CFPreferencesSetValue((CFStringRef)defaultName, value, (CFStringRef)[bundle bundleIdentifier],  kCFPreferencesCurrentUser,  kCFPreferencesAnyHost);
		CFPreferencesSynchronize((CFStringRef)[bundle bundleIdentifier], kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	}
}

- (BOOL)boolForUserDefaultsKey:(NSString *)defaultName
{
	if (bundle == [NSBundle mainBundle])
		return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
	
	BOOL value;
	CFPropertyListRef plr = CFPreferencesCopyAppValue((CFStringRef)defaultName, (CFStringRef)[bundle bundleIdentifier]);
	if (plr == NULL)
		value = NO;
	else
	{
		value = (BOOL)CFBooleanGetValue((CFBooleanRef)plr);
		CFRelease(plr);
	}
	return value;
}

- (void)setBool:(BOOL)value forUserDefaultsKey:(NSString *)defaultName
{
	// If we're using a .app, we'll use the standard user defaults mechanism; otherwise, we have to get CF-y.
	if (bundle == [NSBundle mainBundle])
	{
		[[NSUserDefaults standardUserDefaults] setBool:value forKey:defaultName];
	}
	else
	{
		CFPreferencesSetValue((CFStringRef)defaultName, (CFBooleanRef)[NSNumber numberWithBool:value], (CFStringRef)[bundle bundleIdentifier],  kCFPreferencesCurrentUser,  kCFPreferencesAnyHost);
		CFPreferencesSynchronize((CFStringRef)[bundle bundleIdentifier], kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	}
}

- (id)objectForKey:(NSString *)key {
    return [self objectForUserDefaultsKey:key] ? [self objectForUserDefaultsKey:key] : [self objectForInfoDictionaryKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
    return [self objectForUserDefaultsKey:key] ? [self boolForUserDefaultsKey:key] : [self boolForInfoDictionaryKey:key];
}

+ (NSString *)systemVersionString
{
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] systemVersion];
#else
	// This returns a version string of the form X.Y.Z
	// There may be a better way to deal with the problem that gestaltSystemVersionMajor
	//  et al. are not defined in 10.3, but this is probably good enough.
	NSString* verStr = nil;
# if MACOSX_DEPLOYMENT_TARGET >= MAC_OS_X_VERSION_10_4
	SInt32 major, minor, bugfix;
	OSErr err1 = Gestalt(gestaltSystemVersionMajor, &major);
	OSErr err2 = Gestalt(gestaltSystemVersionMinor, &minor);
	OSErr err3 = Gestalt(gestaltSystemVersionBugFix, &bugfix);
	if (!err1 && !err2 && !err3)
	{
		verStr = [NSString stringWithFormat:@"%d.%d.%d", major, minor, bugfix];
	}
	else
# endif
	{
	 	NSString *versionPlistPath = @"/System/Library/CoreServices/SystemVersion.plist";
		verStr = [[NSDictionary dictionaryWithContentsOfFile:versionPlistPath] objectForKey:@"ProductVersion"];
	}
    return verStr;
#endif
}

@end
