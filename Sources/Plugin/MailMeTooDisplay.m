//
//  MailMeTooDisplay.mm
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import "MailMeTooDisplay.h"
#import "MailMeTooPreferences.h"
#import "GrowlApplicationNotification.h"
#import "SMTPClient.h"


@implementation MailMeTooDisplay

-(void)dealloc {
	[preferencePane release];
	[super dealloc];
}

-(MailMeTooPreferences*)preferencePane {
	if (!preferencePane)
		preferencePane = [[MailMeTooPreferences alloc] initWithBundle:[NSBundle bundleForClass:[MailMeTooPreferences class]]];
	return (MailMeTooPreferences*)preferencePane;
}

-(void)displayNotification:(GrowlApplicationNotification*)notification {
//	NSLog(@"[MailMeTooDisplay displayNotification:%@]", notification);
	
	@try {
		NSString* subject = [[[self preferencePane] messageSubject] length]? [[self preferencePane] messageSubject] : @"Growl";
		subject = [NSString stringWithFormat:@"[%@] %@: %@", subject, notification.applicationName, notification.title];
		
		NSString* message = [notification.notificationDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>\n"];
		
		NSString* serverAddress = [[self preferencePane] serverAddress];
		NSString* serverPorts = [[self preferencePane] serverPorts];
		NSString* serverAuthUsername = [[self preferencePane] serverAuthUsername];
		NSString* serverAuthPassword = [[self preferencePane] serverAuthPassword];
		NSString* messageFrom = [[self preferencePane] messageFrom];
		NSString* messageTo = [[self preferencePane] messageTo];

		if (!serverAddress.length) [NSException raise:NSGenericException format:@"SMTP Server address is empty"];
		if (!serverPorts.length) serverPorts = @"";
		if (!messageFrom.length) [NSException raise:NSGenericException format:@"From: field is empty"];
		if (!messageTo.length) [NSException raise:NSGenericException format:@"To: field is empty"];
		if ([[self preferencePane] serverAuthFlag]) {
			if (!serverAuthUsername.length) [NSException raise:NSGenericException format:@"SMTP Server username is empty"];
			if (!serverAuthPassword.length) [NSException raise:NSGenericException format:@"SMTP Server password is empty"];
		} else {
			serverAuthUsername = @"";
			serverAuthPassword = @"";
		}

		NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: 
								serverAddress, SMTPServerAddressKey,
								serverPorts, SMTPServerPortsKey,
								[NSNumber numberWithInteger:[[self preferencePane] serverTlsMode]], SMTPServerTLSModeKey,
								[NSNumber numberWithBool:[[self preferencePane] serverAuthFlag]], SMTPServerAuthFlagKey,
								serverAuthUsername, SMTPServerAuthUsernameKey,
								serverAuthPassword, SMTPServerAuthPasswordKey,
								messageFrom, SMTPFromKey,
								messageTo, SMTPToKey,
								subject, SMTPSubjectKey,
								message, SMTPMessageKey,
								NULL];
		
//		NSLog(@"Go with %@", params);
		
		[self performSelectorInBackground:@selector(sendThread:) withObject:params];
	} @catch (NSException* e) {
		NSLog(@"Send exception: %@", e.reason);
	}
}

-(void)sendThread:(NSDictionary*)params {
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	@try {
		[SMTPClient send:params];
	} @catch (NSException* e) {
		NSLog(@"Send exception: %@", e.reason);
	} @finally {
		[pool release];
	}
}

-(BOOL)requiresPositioning {
	return NO;
}

@end
