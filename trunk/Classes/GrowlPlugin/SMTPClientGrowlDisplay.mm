//
//  SMTPClientGrowlDisplay.mm
//
//  Created by Alessandro Volz on 08.06.11.
//  LGPL.
//

#import "SMTPClientGrowlDisplay.h"
#import "SMTPClientGrowlPrefs.h"
#import "GrowlApplicationNotification.h"
#import "SMTPClient.h"
#import "Nitrogen/N2Debug.h"


@implementation SMTPClientGrowlDisplay

-(void)dealloc {
	[preferencePane release];
	[super dealloc];
}

-(SMTPClientGrowlPrefs*)preferencePane {
	if (!preferencePane)
		preferencePane = [[SMTPClientGrowlPrefs alloc] initWithBundle:[NSBundle bundleForClass:[SMTPClientGrowlPrefs class]]];
	return (SMTPClientGrowlPrefs*)preferencePane;
}

-(void)displayNotification:(GrowlApplicationNotification*)notification {
	NSLog(@"[SMTPClientGrowlDisplay displayNotification:%@]", notification);
	
	@try {
		NSString* subject = [[[self preferencePane] messageSubject] length]? [[self preferencePane] messageSubject] : @"Growl";
		subject = [NSString stringWithFormat:@"[%@] %@: %@", subject, notification.applicationName, notification.title];
		
		NSString* message = [notification.notificationDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>\n"];
		
		NSString* serverAddress = [[self preferencePane] serverAddress];
		NSString* serverAuthUsername = [[self preferencePane] serverAuthUsername];
		NSString* serverAuthPassword = [[self preferencePane] serverAuthPassword];
		NSString* messageFrom = [[self preferencePane] messageFrom];
		NSString* messageTo = [[self preferencePane] messageTo];

		if (!serverAddress.length) [NSException raise:NSGenericException format:@"SMTP Server address is empty"];
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
								[NSNumber numberWithInteger:[[self preferencePane] serverPort]], SMTPServerPortKey,
								[NSNumber numberWithInteger:[[self preferencePane] serverTlsMode]], SMTPServerTLSModeKey,
								[NSNumber numberWithBool:[[self preferencePane] serverAuthFlag]], SMTPServerAuthFlagKey,
								serverAuthUsername, SMTPServerAuthUsernameKey,
								serverAuthPassword, SMTPServerAuthPasswordKey,
								messageFrom, SMTPFromKey,
								messageTo, SMTPToKey,
								subject, SMTPSubjectKey,
								message, SMTPMessageKey,
								NULL];
		
		NSLog(@"Go with %@", params);
		
		[self performSelectorInBackground:@selector(sendThread:) withObject:params];
	} @catch (NSException* e) {
		N2LogExceptionWithStackTrace(e);
	}
}

-(void)sendThread:(NSDictionary*)params {
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	@try {
		[SMTPClient send:params];
	} @catch (NSException* e) {
		N2LogExceptionWithStackTrace(e);
	} @finally {
		[pool release];
	}
}

-(BOOL)requiresPositioning {
	return NO;
}

@end
