//
//  GrowlSamplePrefs.h
//  Display Plugins
//
//  Copyright 2006-2009 The Growl Project. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface SMTPClientGrowlPrefs : NSPreferencePane {
	IBOutlet NSTextField* _serverPortField;
}

@property(retain) NSString* serverAddress;
@property NSInteger serverPort;
@property NSInteger serverTlsMode;
@property BOOL serverAuthFlag;
@property(retain) NSString* serverAuthUsername;
@property(retain) NSString* serverAuthPassword;
@property(retain) NSString* messageFrom;
@property(retain) NSString* messageTo;
@property(retain) NSString* messageSubject;

@end
