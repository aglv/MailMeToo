//
//  GrowlSampleDisplay.h
//  Growl Display Plugins
//
//  Copyright 2006-2009 The Growl Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GrowlDisplayPlugin.h"
#import "SMTPClientGrowlPrefs.h"

@class GrowlApplicationNotification;

@interface SMTPClientGrowlDisplay : GrowlDisplayPlugin {
}

-(SMTPClientGrowlPrefs*)preferencePane;

@end
