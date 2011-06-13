//
//  SMTPClientGrowlDisplay.h
//
//  Created by Alessandro Volz on 08.06.11.
//  LGPL.
//

#import <Cocoa/Cocoa.h>
#import "GrowlDisplayPlugin.h"
#import "SMTPClientGrowlPrefs.h"

@class GrowlApplicationNotification;

@interface SMTPClientGrowlDisplay : GrowlDisplayPlugin {
}

-(SMTPClientGrowlPrefs*)preferencePane;

@end
