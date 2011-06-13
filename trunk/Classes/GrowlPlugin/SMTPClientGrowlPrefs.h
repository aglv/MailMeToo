//
//  SMTPClientGrowlPrefs.h
//
//  Created by Alessandro Volz on 08.06.11.
//  LGPL.
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
