//
//  MailMeTooPreferences.mm
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import "MailMeTooPreferences.h"
#import "GrowlDefinesInternal.h"
#import "SMTPClient.h"
#import "MailApp.h"

#define REMOVE_GROWL_PREF_VALUE(key, domain) do {\
	CFDictionaryRef staticPrefs = (CFDictionaryRef)CFPreferencesCopyAppValue((CFStringRef)domain, \
	CFSTR("com.Growl.GrowlHelperApp")); \
	CFMutableDictionaryRef prefs; \
	if (staticPrefs == NULL) {\
		prefs = CFDictionaryCreateMutable(NULL, 0, NULL, NULL); \
	} else {\
		prefs = CFDictionaryCreateMutableCopy(NULL, 0, staticPrefs); \
		CFRelease(staticPrefs); \
	}\
	CFDictionaryRemoveValue(prefs, key); \
	CFPreferencesSetAppValue((CFStringRef)domain, prefs, CFSTR("com.Growl.GrowlHelperApp")); \
	CFRelease(prefs); } while(0)

static const NSString* const DefaultsDomain = @"ch.alessandrovolz.growl.view.mailmetoo";

@implementation MailMeTooPreferences

-(NSString*)mainNibName {
	return @"Preferences";
}

-(void)mainViewDidLoad {
}

-(void)didSelect {
	SYNCHRONIZE_GROWL_PREFS();
}

-(BOOL)mailAppHasAccounts {
    return [[MailApp SmtpAccounts] count] > 0;
}

#pragma mark NSMenuDelegate

-(void)menuWillOpen:(NSMenu*)menu {
    [menu removeAllItems];
    NSDictionary* accounts = [MailApp SmtpAccounts];
    //    NSLog(@"Accounts: %@", accounts);
    for (NSString* name in accounts) {
        NSDictionary* account = [accounts objectForKey:name];
        NSMenuItem* mi = [[[NSMenuItem alloc] initWithTitle:name action:@selector(selectMailAppAccount:) keyEquivalent:@""] autorelease];
        mi.target = self;
        mi.representedObject = account;
        [menu addItem:mi];
    }
}

-(void)selectMailAppAccount:(NSMenuItem*)mi {
    NSDictionary* account = mi.representedObject;
    id temp;
//  NSLog(@"Account: %@", account);
    
    temp = [account objectForKey:SMTPServerAddressKey];
    [_addressField setStringValue:temp];
    [self setServerAddress:temp];
    
    NSArray* ports = [account objectForKey:SMTPServerPortsKey];
    if (ports.count)
        temp = [ports componentsJoinedByString:@","];
    else temp = @"";
    [_portsField setStringValue:temp];
    [self setServerPorts:temp];
    
    temp = [account objectForKey:SMTPServerTLSModeKey];
    [_tlsMatrix selectCellWithTag:[temp integerValue]];
    [self setServerTlsMode:[temp integerValue]];
    
    BOOL authFlag = [[account objectForKey:SMTPServerAuthFlagKey] boolValue];
    [_authCheckbox setIntegerValue:authFlag];
    [self setServerAuthFlag:authFlag];
    if (authFlag) {
        NSString* username = [account objectForKey:SMTPServerAuthUsernameKey];
        [_usernameField setStringValue:username];
        [self setServerAuthUsername:username];
        
        if ([username rangeOfString:@"@"].length) {
            @try {
                NSString* desc;
                [SMTPClient splitAddress:_fromField.stringValue intoEmail:NULL description:&desc];
                desc = desc.length? [NSString stringWithFormat:@"%@ <%@>", desc, username] : username;
                [_fromField setStringValue:desc];
                [self setMessageFrom:desc];
            } @catch (...) {
                [_fromField setStringValue:username];
                [self setMessageFrom:username];
            }
        }
        
        NSString* password = [MailApp SmtpPasswordForAccount:account];
        [_passwordField setStringValue:(password? password : @"")];
        [self setServerAuthPassword:(password? password : @"")];
    } else {
        [_usernameField setStringValue:@""];
        [self setServerAuthUsername:@""];
        [_passwordField setStringValue:@""];
        [self setServerAuthPassword:@""];
    }
}

#pragma mark Accessors

/*-(void)setNilValueForKey:(NSString*)key {
	if ([key isEqualToString:@"serverPorts"]) {
		REMOVE_GROWL_PREF_VALUE(SMTPServerPortsKey, DefaultsDomain);
	} else {
		[super setNilValueForKey:key];
	}
}*/

-(NSString*)serverAddress {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPServerAddressKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setServerAddress:(NSString*)value {
	if (value.length) WRITE_GROWL_PREF_VALUE(SMTPServerAddressKey, value, DefaultsDomain);
	else REMOVE_GROWL_PREF_VALUE(SMTPServerAddressKey, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)serverPorts {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPServerPortsKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setServerPorts:(NSString*)value {
	if (value.length) WRITE_GROWL_PREF_VALUE(SMTPServerPortsKey, value, DefaultsDomain);
	else REMOVE_GROWL_PREF_VALUE(SMTPServerPortsKey, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSInteger)serverTlsMode {
	NSInteger value = SMTPClientTLSModeTLSIfPossible;
	READ_GROWL_PREF_INT(SMTPServerTLSModeKey, DefaultsDomain, &value);
	return value;
}
-(void)setServerTlsMode:(NSInteger)value {
	WRITE_GROWL_PREF_INT(SMTPServerTLSModeKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(BOOL)serverAuthFlag {
	BOOL value = NO;
	READ_GROWL_PREF_BOOL(SMTPServerAuthFlagKey, DefaultsDomain, &value);
	return value;
}
-(void)setServerAuthFlag:(BOOL)value {
	WRITE_GROWL_PREF_BOOL(SMTPServerAuthFlagKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)serverAuthUsername {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPServerAuthUsernameKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setServerAuthUsername:(NSString*)value {
	if (value.length) WRITE_GROWL_PREF_VALUE(SMTPServerAuthUsernameKey, value, DefaultsDomain);
	else REMOVE_GROWL_PREF_VALUE(SMTPServerAuthUsernameKey, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)serverAuthPassword {
    return [MailApp SmtpPasswordForAccount:[NSDictionary dictionaryWithObjectsAndKeys: 
                                            [_addressField stringValue], SMTPServerAddressKey,
                                            [_usernameField stringValue], SMTPServerAuthUsernameKey, NULL]];
}
-(void)setServerAuthPassword:(NSString*)value {
    [MailApp SmtpAccount:[NSDictionary dictionaryWithObjectsAndKeys: 
                          [_addressField stringValue], SMTPServerAddressKey,
                          [_usernameField stringValue], SMTPServerAuthUsernameKey, NULL]
             setPassword:[_passwordField stringValue]];
}

-(NSString*)messageFrom {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPFromKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setMessageFrom:(NSString*)value {
	if (value.length) WRITE_GROWL_PREF_VALUE(SMTPFromKey, value, DefaultsDomain);
	else REMOVE_GROWL_PREF_VALUE(SMTPFromKey, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)messageTo {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPToKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setMessageTo:(NSString*)value {
	if (value.length) WRITE_GROWL_PREF_VALUE(SMTPToKey, value, DefaultsDomain);
	else REMOVE_GROWL_PREF_VALUE(SMTPToKey, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)messageSubject {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPSubjectKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setMessageSubject:(NSString*)value {
	if (value.length) WRITE_GROWL_PREF_VALUE(SMTPSubjectKey, value, DefaultsDomain);
	else REMOVE_GROWL_PREF_VALUE(SMTPSubjectKey, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

@end
