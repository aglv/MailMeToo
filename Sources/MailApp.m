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
	NSMutableDictionary* rad = [NSMutableDictionary dictionary];

	NSDictionary* md = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.Mail"];
	for (NSDictionary* mad in [md objectForKey:@"DeliveryAccounts"])
		if ([[mad objectForKey:@"AccountType"] isEqualToString:@"SMTPAccount"]) {
			NSMutableDictionary* ad = [NSMutableDictionary dictionary];
            [rad setObject:ad forKey:[mad objectForKey:@"AccountName"]];
            
            NSString* hostname = [mad objectForKey:@"Hostname"];
			[ad setObject:hostname forKey:SMTPServerAddressKey];
			
            NSString* flagSSLStr = [mad objectForKey:@"SSLEnabled"];
			BOOL flagSSL = [flagSSLStr isEqualToString:@"YES"];
            // SecurityLayerType?
            [ad setObject:[NSNumber numberWithInteger:(flagSSL? SMTPClientTLSModeTLSOrClose : SMTPClientTLSModeNone)] forKey:SMTPServerTLSModeKey];
            
            NSString* flagUseDefaultPortsStr = [mad objectForKey:@"UseDefaultPorts"];
			BOOL flagUseDefaultPorts = [flagUseDefaultPortsStr isEqualToString:@"YES"];
			NSInteger portNumber = (!flagUseDefaultPorts)? [[mad objectForKey:@"PortNumber"] integerValue] : 0;
			NSArray* portNumbers = [NSArray arrayWithObjects: portNumber? [NSNumber numberWithInteger:portNumber] : nil, nil];
            if (portNumbers.count)
                [ad setObject:portNumbers forKey:SMTPServerPortsKey];
            
            BOOL flagAuth = [[mad objectForKey:@"ShouldUseAuthentication"] isEqualToString:@"YES"];
            [ad setObject:[NSNumber numberWithBool:flagAuth] forKey:SMTPServerAuthFlagKey];
            
            if (flagAuth)
                [ad setObject:[mad objectForKey:@"Username"] forKey:SMTPServerAuthUsernameKey];
		}
	
	return rad;
}

+(NSString*)PasswordFromSecKeychainItemRef:(SecKeychainItemRef)item {
    SecKeychainAttribute attributes[8];
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    SecKeychainAttributeList list;
    list.count = 4;
    list.attr = attributes;
    
    UInt32 length;
    char* password;
    
    OSStatus err = SecKeychainItemCopyContent(item, NULL, &list, &length, (void**)&password);
    if (err != noErr)
        return nil;
    
    if (password)
        @try {
            return [[[NSString alloc] initWithBytes:password length:length encoding:NSUTF8StringEncoding] autorelease];
        } @catch (NSException* e) {
            NSLog(@"Exception: %@", e.reason);
        } @finally {
            SecKeychainItemFreeContent(&list, password);
        }
    
    return nil;
}

+(NSString*)InternetPasswordFromKeychainItemName:(NSString*)name account:(NSString*)account {
    SecKeychainSearchRef search = nil;
    SecKeychainItemRef item = nil;
    @try {
        SecKeychainAttribute attributes[2];
        
        attributes[0].tag = kSecAccountItemAttr;
        attributes[0].data = (void *)[account UTF8String];
        attributes[0].length = [account length];
        
        attributes[1].tag = kSecLabelItemAttr;
        attributes[1].data = (void *)[name UTF8String];
        attributes[1].length = [name length];
        
        SecKeychainAttributeList list;
        list.count = 2;
        list.attr = attributes;
        
        OSStatus err;
        
        err = SecKeychainSearchCreateFromAttributes(NULL, kSecInternetPasswordItemClass, &list, &search);
        if (err != noErr)
            return nil;
        
        err = SecKeychainSearchCopyNext(search, &item);
        if (err != noErr)
            return nil;
        
        return [self PasswordFromSecKeychainItemRef:item];
    } @catch (NSException* e) {
        NSLog(@"Exception: %@", e.reason);
    } @finally {
        if (item) CFRelease(item);
        if (search) CFRelease(search);
    }
    
    return nil;
}

+(NSString*)SmtpPasswordForAccount:(NSDictionary*)account {
    NSString* hostname = [account objectForKey:SMTPServerAddressKey];
    NSString* username = [account objectForKey:SMTPServerAuthUsernameKey];
    
    if (!hostname.length || !username.length)
        return nil;
    
    NSString* password = [self InternetPasswordFromKeychainItemName:hostname account:username];
    if (password) return password;
    
    NSArray* h = [hostname componentsSeparatedByString:@"."];
    
    for (NSString* name in [NSArray arrayWithObjects:@"imap", @"pop", @"mail", nil])
        if (![[h objectAtIndex:0] isEqualToString:name]) {
            password = [self InternetPasswordFromKeychainItemName:[NSString stringWithFormat:@"%@.%@", name, [[h subarrayWithRange:NSMakeRange(1,h.count-1)] componentsJoinedByString:@"."]] account:username];
            if (password) return password;
        }
    
    return nil;
}

+(void)SetInternetPassword:(NSString*)password forKeychainItemName:(NSString*)name account:(NSString*)account {
    SecKeychainAttribute attributes[3];
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[account UTF8String];
    attributes[0].length = [account length];
	
	attributes[1].tag = kSecLabelItemAttr;
    attributes[1].data = (void*)[name UTF8String];
    attributes[1].length = [name length];
    
    SecKeychainAttributeList list;
    list.count = 2;
    list.attr = attributes;
    
    SecKeychainItemRef item;
    OSStatus status = SecKeychainItemCreateFromContent(kSecInternetPasswordItemClass, &list, password.length, password.UTF8String, NULL, NULL, &item);
    if (status != 0) {
        NSLog(@"Error creating new item: %d", (int)status);
    }
}

+(void)SmtpAccount:(NSDictionary*)account setPassword:(NSString*)password {
    NSString* hostname = [account objectForKey:SMTPServerAddressKey];
    NSString* username = [account objectForKey:SMTPServerAuthUsernameKey];
    
    if (!hostname.length || !username.length || !password.length)
        return;

    [self SetInternetPassword:password forKeychainItemName:hostname account:username];
}

@end
