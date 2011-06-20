//
//  MailMeTooPreferences.h
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface MailMeTooPreferences : NSPreferencePane {
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
