//
//  MailMeTooAppDelegate.m
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import "MailMeTooAppDelegate.h"
#import "MailMeTooWindowController.h"
#import "SMTPClient.h"
#import "MailApp.h"


@implementation MailMeTooAppDelegate

-(id)init {
	if ((self = [super init])) {
		NSDictionary* defaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 // @"mailhost", SMTPServerAddressKey,
								 // [NSNumber numberWithInt:25], SMTPServerPortKey,
								  [NSNumber numberWithInteger:SMTPClientTLSModeTLSIfPossible], SMTPServerTLSModeKey,
								 // nil, SMTPFromKey,
								  [NSNumber numberWithBool:NO], SMTPServerAuthFlagKey,
								 // nil, SMTPServerAuthUsernameKey,
								 // nil, SMTPServerAuthPasswordKey,
								 // nil, SMTPToKey,
								 // nil, SMTPMessageKey,
								  NULL];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
		
		NSLog(@"Accounts: %@", [MailApp SmtpAccounts]);
	}
	
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
	
	MailMeTooWindowController* ewc = [MailMeTooWindowController new];
	[ewc.window makeKeyAndOrderFront:self];
	
}

@end
