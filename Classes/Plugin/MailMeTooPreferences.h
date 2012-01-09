//
//  MailMeTooPreferences.h
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface MailMeTooPreferences : NSPreferencePane {
	IBOutlet NSTextField* _addressField;
	IBOutlet NSTextField* _portsField;
	IBOutlet NSMatrix* _tlsMatrix;
	IBOutlet NSTextField* _fromField;
	IBOutlet NSButton* _authCheckbox;
	IBOutlet NSTextField* _usernameField;
	IBOutlet NSTextField* _passwordField;
	IBOutlet NSTextField* _toField;
	IBOutlet NSTextField* _subjectPrefixField;
}

@property(retain) NSString* serverAddress;
@property(retain) NSString* serverPorts;
@property NSInteger serverTlsMode;
@property BOOL serverAuthFlag;
@property(retain) NSString* serverAuthUsername;
@property(retain) NSString* serverAuthPassword;
@property(retain) NSString* messageFrom;
@property(retain) NSString* messageTo;
@property(retain) NSString* messageSubject;

@end
