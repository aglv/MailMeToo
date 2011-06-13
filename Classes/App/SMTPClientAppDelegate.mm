//
//  smtpAppDelegate.m
//  smtp
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "SMTPClientAppDelegate.h"
#import "SMTPClientWindowController.h"
#import "SMTPClient.h"


@implementation SMTPClientAppDelegate

-(id)init {
	if ((self = [super init])) {
		NSDictionary* defaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								  @"mailhost", SMTPServerAddressKey,
								 // [NSNumber numberWithInt:25], SMTPServerPortKey,
								  [NSNumber numberWithInteger:0], SMTPServerTLSModeKey,
								 // nil, SMTPFromKey,
								  [NSNumber numberWithBool:NO], SMTPServerAuthFlagKey,
								 // nil, SMTPServerAuthUsernameKey,
								 // nil, SMTPServerAuthPasswordKey,
								 // nil, SMTPToKey,
								 // nil, SMTPMessageKey,
								  NULL];
		[NSUserDefaults.standardUserDefaults registerDefaults:defaults];
	}
	
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
	
	SMTPClientWindowController* ewc = [SMTPClientWindowController new];
	[ewc.window makeKeyAndOrderFront:self];
	
}

@end
