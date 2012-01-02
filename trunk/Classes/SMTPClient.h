//
//  SMTPClient.h
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//  

#import <Cocoa/Cocoa.h>


extern const NSString* const SMTPServerAddressKey;
extern const NSString* const SMTPServerPortsKey;
extern const NSString* const SMTPServerTLSModeKey;
extern const NSString* const SMTPFromKey;
extern const NSString* const SMTPServerAuthFlagKey;
extern const NSString* const SMTPServerAuthUsernameKey;
extern const NSString* const SMTPServerAuthPasswordKey;
extern const NSString* const SMTPToKey;
extern const NSString* const SMTPSubjectKey;
extern const NSString* const SMTPMessageKey;

enum {
	SMTPClientTLSModeNone = 0,
	SMTPClientTLSModeTLSIfPossible = 1,
	SMTPClientTLSModeTLSOrClose = 2
};
typedef NSInteger SMTPClientTLSMode;

@interface SMTPClient : NSObject {
	NSString* _address;
	NSArray* _ports;
	SMTPClientTLSMode _tlsMode;
	NSString* _authUsername;
	NSString* _authPassword;
}

@property(readonly,retain) NSString* address;
@property(readonly,retain) NSArray* ports;
@property(readonly,assign) SMTPClientTLSMode tlsMode;
@property(readonly,retain) NSString* username;
@property(readonly,retain) NSString* password;

+(void)send:(NSDictionary*)params;

+(SMTPClient*)clientWithServerAddress:(NSString*)address ports:(NSArray*)ports tlsMode:(SMTPClientTLSMode)tlsMode username:(NSString*)authUsername password:(NSString*)authPassword;

-(id)initWithServerAddress:(NSString*)address ports:(NSArray*)ports tlsMode:(SMTPClientTLSMode)tlsMode username:(NSString*)authUsername password:(NSString*)authPassword;

-(void)sendMessage:(NSString*)message withSubject:(NSString*)subject from:(NSString*)from to:(NSString*)to;

@end
