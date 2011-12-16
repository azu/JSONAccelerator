//
//  GeneralPreferencesViewController.m
//  JSONModeler
//
//  Created by Sean Hickey on 12/16/11.
//  Copyright (c) 2011 Nerdery Interactive Labs. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

@implementation GeneralPreferencesViewController

-(id)init {
    return [super initWithNibName:@"GeneralPreferencesViewController" bundle:nil];
}

-(NSString *)identifier {
    return @"GeneralPreferences";
}

-(NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel {
    return NSLocalizedString(@"General", @"Toolbar item name for General Preferences");
}

@end
