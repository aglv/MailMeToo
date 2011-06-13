//
//  EmailWindowComtroller.mm
//  smtp
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "SMTPClientWindowController.h"
#import "SMTPClientAppDelegate.h"
#import "SMTPClient.h"
#import <Nitrogen/N2Debug.h>


@implementation SMTPClientWindowController

-(id)init {
	return [super initWithWindowNibName:@"EmailWindow" owner:self];
}

-(void)awakeFromNib {
	[self setStatus:nil];
}

-(void)setStatus:(NSString*)str {
	[_statusField setStringValue: str? str : @"" ];
}

-(IBAction)sendAction:(id)sender {
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: 
							[_addressField stringValue], SMTPServerAddressKey,
							[NSNumber numberWithInteger:[_portField integerValue]], SMTPServerPortKey,
							[NSNumber numberWithInteger:[_tlsMatrix selectedTag]], SMTPServerTLSModeKey,
							[_fromField stringValue], SMTPFromKey,
							[NSNumber numberWithBool:[_authCheckbox intValue]], SMTPServerAuthFlagKey,
							[_usernameField stringValue], SMTPServerAuthUsernameKey,
							[_passwordField stringValue], SMTPServerAuthPasswordKey,
							[_toField stringValue], SMTPToKey,
							[_subjectField stringValue], SMTPSubjectKey,
							[_messageField stringValue], SMTPMessageKey,
							NULL];
	NSLog(@"Go with %@", params);
	@try {
		[self setStatus:@"Sending..."];
		[self performSelectorInBackground:@selector(sendThread:) withObject:params];
	} @catch (NSException* e) {
		N2LogExceptionWithStackTrace(e);
		[self setStatus:e.reason];
	}
}

-(void)sendThread:(NSDictionary*)params {
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	@try {
		[SMTPClient send:params];
		[self performSelectorOnMainThread:@selector(setStatus:) withObject:@"" waitUntilDone:NO];
	} @catch (NSException* e) {
		[self performSelectorOnMainThread:@selector(setStatus:) withObject:e.reason waitUntilDone:NO];
	} @finally {
		[pool release];
	}
}

@end
