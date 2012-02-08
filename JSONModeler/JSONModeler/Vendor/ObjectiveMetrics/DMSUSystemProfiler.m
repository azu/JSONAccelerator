//
//  DMSUSystemProfiler.m
//  Sparkle
//
//  Created by Andy Matuschak on 12/22/07.
//  Copyright 2007 Andy Matuschak. All rights reserved.
//  Adapted from Sparkle+, by Tom Harrington.
//

#import "DMSUSystemProfiler.h"

#import "DMSUHost.h"
#import <sys/sysctl.h>

#if TARGET_OS_IPHONE
# import "UIDevice-Hardware.h"
#else
# import <AppKit/AppKit.h>
#endif

// For freeMemoryArray
#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>

@interface NSString (Size)
#if TARGET_OS_IPHONE
+ (id) stringWithSize:(CGSize)size;
#else
+ (id) stringWithSize:(NSSize)size;
#endif
@end

@implementation NSString (Size)
#if TARGET_OS_IPHONE
+ (id) stringWithSize:(CGSize)size;
#else
+ (id) stringWithSize:(NSSize)size;
#endif
{
    return [self stringWithFormat:@"%0.fx%0.f", size.width, size.height];
}
@end

@implementation DMSUSystemProfiler
+ (DMSUSystemProfiler *)sharedSystemProfiler
{
    static DMSUSystemProfiler *sharedSystemProfiler = nil;
    if (!sharedSystemProfiler)
        sharedSystemProfiler = [[self alloc] init];
    return sharedSystemProfiler;
}

- (NSDictionary *)modelTranslationTable
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SUModelTranslation" ofType:@"plist"];
    return [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
}

- (NSArray *)freeMemoryArray
{
    int mib[2] = { CTL_HW, HW_PAGESIZE };
    int pagesize;
    size_t length = sizeof (pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
        return nil;

    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS)
        return nil;

    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info(mach_task_self(), TASK_BASIC_INFO_64, (task_info_t)&info, &size);

    long long freeBytes = (vmstat.free_count + vmstat.inactive_count) * pagesize;
    const double bytesPerMB = 1024 * 1024;
    return [NSArray arrayWithObjects:@"ramFreeB", @"Free Memory (MB)", [NSNumber numberWithDouble:freeBytes], [NSNumber numberWithDouble:freeBytes / bytesPerMB], nil];
}

- (NSMutableArray *)systemProfileArrayForHost:(DMSUHost *)host
{
    NSDictionary *modelTranslation = [self modelTranslationTable];

    // Gather profile information and append it to the URL.
    NSMutableArray *profileArray = [NSMutableArray array];
    NSArray *profileDictKeys = [NSArray arrayWithObjects:@"key", @"displayKey", @"value", @"displayValue", nil];
    int error = 0;
    int value = 0;
    size_t length = sizeof(value);

    // OS version
    NSString *currentSystemVersion = [DMSUHost systemVersionString];
    if (currentSystemVersion != nil)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"osVersion",@"OS Version",currentSystemVersion,currentSystemVersion,nil] forKeys:profileDictKeys]];

    // CPU type (decoder info for values found here is in mach/machine.h)
    error = sysctlbyname("hw.cputype", &value, &length, NULL, 0);
    int cpuType = -1;
    if (error == 0) {
        cpuType = value;
        NSString *visibleCPUType;
        switch(value) {
            case 7:     visibleCPUType=@"Intel";      break;
            case 18:    visibleCPUType=@"PowerPC";    break;
            default:    visibleCPUType=@"Unknown";    break;
        }
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cputype",@"CPU Type", [NSNumber numberWithInt:value], visibleCPUType,nil] forKeys:profileDictKeys]];
    }
    error = sysctlbyname("hw.cpu64bit_capable", &value, &length, NULL, 0);
    if(error != 0)
        error = sysctlbyname("hw.optional.x86_64", &value, &length, NULL, 0); //x86 specific
    if(error != 0)
        error = sysctlbyname("hw.optional.64bitops", &value, &length, NULL, 0); //PPC specific

    BOOL is64bit = NO;

    if (error == 0) {
        is64bit = value == 1;
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cpu64bit", @"CPU is 64-Bit?", [NSNumber numberWithBool:is64bit], is64bit ? @"Yes" : @"No", nil] forKeys:profileDictKeys]];
    }
    error = sysctlbyname("hw.cpusubtype", &value, &length, NULL, 0);
    if (error == 0) {
        NSString *visibleCPUSubType;
        if (cpuType == 7) {
            // Intel
            visibleCPUSubType = is64bit ? @"Intel Core 2" : @"Intel Core";    // If anyone knows how to tell a Core Duo from a Core Solo, please email tph@atomicbird.com
        } else if (cpuType == 18) {
            // PowerPC
            switch(value) {
                case 9:               visibleCPUSubType=@"G3";    break;
                case 10:  case 11:    visibleCPUSubType=@"G4";    break;
                case 100:             visibleCPUSubType=@"G5";    break;
                default:              visibleCPUSubType=@"Other"; break;
            }
        } else {
            visibleCPUSubType = @"Other";
        }
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cpusubtype",@"CPU Subtype", [NSNumber numberWithInt:value], visibleCPUSubType,nil] forKeys:profileDictKeys]];
    }

    error = sysctlbyname("hw.model", NULL, &length, NULL, 0);
    if (error == 0) {
        char *cpuModel = (char *)malloc(sizeof(char) * length);
        if (cpuModel != NULL) {
            error = sysctlbyname("hw.model", cpuModel, &length, NULL, 0);
            if (error == 0) {
                NSString *rawModelName = [NSString stringWithUTF8String:cpuModel];
                NSString *visibleModelName = [modelTranslation objectForKey:rawModelName];
                if (visibleModelName == nil)
                    visibleModelName = rawModelName;
                [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"model",@"Mac Model", rawModelName, visibleModelName, nil] forKeys:profileDictKeys]];
            }
            free(cpuModel);
        }
    }

    // Number of CPUs
    error = sysctlbyname("hw.ncpu", &value, &length, NULL, 0);
    if (error == 0)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"ncpu",@"Number of CPUs", [NSNumber numberWithInt:value], [NSNumber numberWithInt:value],nil] forKeys:profileDictKeys]];

    // CPU vendor
    error = sysctlbyname("machdep.cpu.vendor", NULL, &length, NULL, 0);
    if (error == 0) {
        char *cpuVendor = (char *)malloc(sizeof(char) * length);
        if (cpuVendor != NULL) {
            error = sysctlbyname("machdep.cpu.vendor", cpuVendor, &length, NULL, 0);
            if (error == 0) {
                NSString *vendorName = [NSString stringWithUTF8String:cpuVendor];
                [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cpuVendor", @"CPU Vendor", vendorName, vendorName, nil] forKeys:profileDictKeys]];
            }
            free(cpuVendor);
        }
    }

    // CPU brand string (description)
    error = sysctlbyname("machdep.cpu.brand_string", NULL, &length, NULL, 0);
    if (error == 0) {
        char *cpuBrand = (char *)malloc(sizeof(char) * length);
        if (cpuBrand != NULL) {
            error = sysctlbyname("machdep.cpu.brand_string", cpuBrand, &length, NULL, 0);
            if (error == 0) {
                NSString *vendorName = [NSString stringWithUTF8String:cpuBrand];
                [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cpuBrand", @"CPU Model", vendorName, vendorName, nil] forKeys:profileDictKeys]];
            }
            free(cpuBrand);
        }
    }

    // User preferred language
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    if ([languages count] > 0)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"lang",@"Preferred Language", [languages objectAtIndex:0], [languages objectAtIndex:0],nil] forKeys:profileDictKeys]];

    // Application sending the request
    NSString *appName = [host name];
    if (appName)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"appName",@"Application Name", appName, appName,nil] forKeys:profileDictKeys]];
    NSString *appVersion = [host version];
    if (appVersion)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"appVersion",@"Application Version", appVersion, appVersion,nil] forKeys:profileDictKeys]];

    // Main screen (for OS X this means the one with the menubar)
    NSString *resolution = nil;

#if TARGET_OS_IPHONE
    UIScreenMode *currentMode = [[UIScreen mainScreen] currentMode];
    if (currentMode)
        resolution = [NSString stringWithSize:[currentMode size]];
#else
    /* Note that [NSScreen mainScreen] is just the current screen, whereas the first object
     * in the screens array is the the one that has the menubar.
     */
    NSArray *screenArray = [NSScreen screens];
    if ([screenArray count] > 0)
        resolution = [NSString stringWithSize:[[screenArray objectAtIndex:0] frame].size];
#endif

    if (resolution)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"mainScreenResolution", @"Main Screen Resolution", resolution, resolution, nil] forKeys:profileDictKeys]];

#if TARGET_OS_IPHONE
    // CPU speed
    NSUInteger result = [[UIDevice currentDevice] cpuFrequency];
    if (result != 0)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cpuFreqMHz",@"CPU Speed (GHz)", [NSNumber numberWithInteger:result], [NSNumber numberWithDouble:result/1000.0],nil] forKeys:profileDictKeys]];

    // Total amount of physical RAM
    long long result64 = [[UIDevice currentDevice] totalMemory];
    if (result64 > 0)
    {
        // Turn bytes into megabytes.
        result64 = result64 / (1024 * 1024);
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"ramMB", @"Memory (MB)", [NSNumber numberWithLongLong:result64], [NSNumber numberWithLongLong:result64], nil] forKeys:profileDictKeys]];
    }
#else
    // CPU speed
    SInt32 gestaltInfo;
    OSErr err = Gestalt(gestaltProcClkSpeedMHz,&gestaltInfo);
    if (err == noErr)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"cpuFreqMHz",@"CPU Speed (GHz)", [NSNumber numberWithInt:gestaltInfo], [NSNumber numberWithDouble:gestaltInfo/1000.0],nil] forKeys:profileDictKeys]];

    // Total amount of physical RAM
    err = Gestalt(gestaltPhysicalRAMSizeInMegabytes,&gestaltInfo);
    if (err == noErr)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"ramMB",@"Memory (MB)", [NSNumber numberWithInt:gestaltInfo], [NSNumber numberWithInt:gestaltInfo],nil] forKeys:profileDictKeys]];
#endif

    // Amount of free RAM
    NSArray *freeMemoryArray = [self freeMemoryArray];
    if (freeMemoryArray)
        [profileArray addObject:[NSDictionary dictionaryWithObjects:freeMemoryArray forKeys:profileDictKeys]];

    return profileArray;
}

@end
