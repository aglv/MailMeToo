//
//  GrowlSamplePrefs.m
//  Display Plugins
//
//  Copyright 2006-2009 The Growl Project. All rights reserved.
//

#import "SMTPClientGrowlPrefs.h"
#import "GrowlDefinesInternal.h"
#import "SMTPClient.h"


static const NSString* const DefaultsDomain = @"ch.alessandrovolz.growl.view.smtpclient";

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
	[options setObject:[NSNumber numberWithInteger:(self.serverTlsMode == SMTPClientTLSModeTLS)? 465 : 25] forKey:NSNullPlaceholderBindingOption];
	[_serverPortField unbind:@"value"];
	[_serverPortField bind:@"value" toObject:self withKeyPath:@"serverPort" options:options];
}

#pragma mark Accessors

-(NSString*)serverAddress {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPServerAddressKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setServerAddress:(NSString*)value {
	WRITE_GROWL_PREF_VALUE(SMTPServerAddressKey, value, DefaultsDomain);
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
	NSInteger value = NO;
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
	WRITE_GROWL_PREF_VALUE(SMTPServerAuthUsernameKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)serverAuthPassword {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPServerAuthPasswordKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setServerAuthPassword:(NSString*)value {
	WRITE_GROWL_PREF_VALUE(SMTPServerAuthPasswordKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)messageFrom {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPFromKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setMessageFrom:(NSString*)value {
	WRITE_GROWL_PREF_VALUE(SMTPFromKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)messageTo {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPToKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setMessageTo:(NSString*)value {
	WRITE_GROWL_PREF_VALUE(SMTPToKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

-(NSString*)messageSubject {
	NSString* value = nil;
	READ_GROWL_PREF_VALUE(SMTPSubjectKey, DefaultsDomain, CFStringRef, (CFStringRef*)&value);
	return value;
}
-(void)setMessageSubject:(NSString*)value {
	WRITE_GROWL_PREF_VALUE(SMTPSubjectKey, value, DefaultsDomain);
	UPDATE_GROWL_PREFS();
}

@end
