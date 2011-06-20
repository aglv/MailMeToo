//
//  MailApp.m
//  MailMeToo
//
//  Created by Alessandro Volz on 6/18/11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import "MailApp.h"
#import "SMTPClient.h"


@implementation MailApp

+(NSDictionary*)SmtpAccounts {
	NSDictionary* md = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.Mail"];
	NSLog(@"Mail.app accounts: %@", [md objectForKey:@"DeliveryAccounts"]);
	
	NSMutableDictionary* rad = [NSMutableDictionary dictionary];
	
	for (NSDictionary* mad in [md objectForKey:@"DeliveryAccounts"])
		if ([[mad objectForKey:@"AccountType"] isEqual:@"SMTPAccount"]) {
			NSMutableDictionary* ad = [NSMutableDictionary dictionary];
			
			[ad setObject:[mad objectForKey:@"Hostname"] forKey:SMTPServerAddressKey];
			
			BOOL flagSSL = [[mad objectForKey:@"SSLEnabled"] isEqual:@"YES"];
			BOOL flagUseDefaultPorts = [[mad objectForKey:@"UseDefaultPorts"] isEqual:@"YES"];
			NSInteger portNumber = [[mad objectForKey:@"PortNumber"] integerValue];
			NSArray* portNumbers = [NSArray arrayWithObjects: portNumber? [NSNumber numberWithInteger:portNumber] : nil, nil];
			if (flagUseDefaultPorts)
				if (!flagSSL)
					portNumbers = [NSArray arrayWithObjects: [NSNumber numberWithInteger:25], [NSNumber numberWithInteger:587], nil];
				else portNumbers = [NSArray arrayWithObjects: [NSNumber numberWithInteger:25], [NSNumber numberWithInteger:465], [NSNumber numberWithInteger:587], nil];
			
		//	[ad setObject: forKey:SMTPServerTLSModeKey];
			
			[ad setObject:[mad objectForKey:@"Hostname"] forKey:SMTPServerAddressKey];
			[ad setObject:[mad objectForKey:@"Hostname"] forKey:SMTPServerAddressKey];
			[ad setObject:[mad objectForKey:@"Hostname"] forKey:SMTPServerAddressKey];
			
//SMTPServerPortKey = @"SMTPServerPort";
//SMTPServerTLSModeKey = @"SMTPServerTLSMode";
//SMTPFromKey = @"SMTPFrom";
//SMTPServerAuthFlagKey = @"SMTPServerAuthFlag";
//SMTPServerAuthUsernameKey = @"SMTPServerAuthUsername";
//SMTPServerAuthPasswordKey = @"SMTPServerAuthPassword";
			
			[rad setObject:ad forKey:[mad objectForKey:@"AccountName"]];
		}
	
	
	return rad;
}

@end
