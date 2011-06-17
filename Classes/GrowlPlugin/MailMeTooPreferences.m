//
//  SMTPClientGrowlPrefs.mm
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import "SMTPClientGrowlPrefs.h"
#import "GrowlDefinesInternal.h"
#import "SMTPClient.h"

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

static const NSString* const DefaultsDomain = @"ch.alessandrovolz.growl.view.smtpmail";

@interface SMTPClientGrowlPrefs ()

-(void)_updateDefaultServerPort;

@end

@implementation SMTPClientGrowlPrefs

-(NSString*)mainNibName {
	return @"SMTPClientGrowlPrefs";
}

-(void)mainViewDidLoad {
}

-(void)didSelect {
	SYNCHRONIZE_GROWL_PREFS();
	[self _updateDefaultServerPort];
}

-(void)_updateDefaultServerPort {
	NSMutableDictionary* options = [NSMutableDictionary dictionary];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSAllowsEditingMultipleValuesSelectionBindingOption];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSRaisesForNotApplicableKeysBindingOption];
	[options setObject:(self.serverTlsMode == SMTPClientTLSModeTLS ? @"465" : @"25") forKey:NSNullPlaceholderBindingOption];
	[_serverPortField unbind:@"value"];
	[_serverPortField bind:@"value" toObject:self withKeyPath:@"serverPort" options:options];
}

#pragma mark Accessors

-(void)setNilValueForKey:(NSString*)key {
	if ([key isEqualToString:@"serverPort"]) {
		REMOVE_GROWL_PREF_VALUE(SMTPServerPortKey, DefaultsDomain);
	} else {
		[super setNilValueForKey:key];
	}

}

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

-(NSInteger)serverPort {
	NSInteger value = 0;
	READ_GROWL_PREF_INT(SMTPServerPortKey, DefaultsDomain, &value);
	return value? value : ((self.serverTlsMode == SMTPClientTLSModeTLS)? 465 : 25);
}
-(void)setServerPort:(NSInteger)value {
	WRITE_GROWL_PREF_INT(SMTPServerPortKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSInteger)serverTlsMode {
	NSInteger value = SMTPClientTLSModeSTARTTLSIfPossible;
	READ_GROWL_PREF_INT(SMTPServerTLSModeKey, DefaultsDomain, &value);
	return value;
}
-(void)setServerTlsMode:(NSInteger)value {
	WRITE_GROWL_PREF_INT(SMTPServerTLSModeKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
	[self _updateDefaultServerPort];
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
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPServerAuthPasswordKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setServerAuthPassword:(NSString*)value {
	if (value.length) WRITE_GROWL_PREF_VALUE(SMTPServerAuthPasswordKey, value, DefaultsDomain);
	else REMOVE_GROWL_PREF_VALUE(SMTPServerAuthPasswordKey, DefaultsDomain);
	UPDATE_GROWL_PREFS();
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
