//
//  MailMeTooDisplay.h
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GrowlDisplayPlugin.h"
#import "MailMeTooPreferences.h"

@class GrowlApplicationNotification;

@interface MailMeTooDisplay : GrowlDisplayPlugin {
}

-(MailMeTooPreferences*)preferencePane;

@end
