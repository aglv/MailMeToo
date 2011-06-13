//
//  SMTPClient.h
//
//  Created by Alessandro Volz on 08.06.11.
//  LGPL.
//  

#import <Cocoa/Cocoa.h>


extern const NSString* const SMTPServerAddressKey;
extern const NSString* const SMTPServerPortKey;
extern const NSString* const SMTPServerTLSModeKey;
extern const NSString* const SMTPFromKey;
extern const NSString* const SMTPServerAuthFlagKey;
extern const NSString* const SMTPServerAuthUsernameKey;
extern const NSString* const SMTPServerAuthPasswordKey;
extern const NSString* const SMTPToKey;
extern const NSString* const SMTPSubjectKey;
extern const NSString* const SMTPMessageKey;

enum {
	SMTPClientTLSModeNoTLS = 0,
	SMTPClientTLSModeTLS = 1,
	SMTPClientTLSModeSTARTTLSIfPossible = 2,
	SMTPClientTLSModeSTARTTLSOrClose = 3
};
typedef NSInteger SMTPClientTLSMode;

@interface SMTPClient : NSObject {
	NSString* _address;
	NSInteger _port;
	SMTPClientTLSMode _tlsMode;
	NSString* _authUsername;
	NSString* _authPassword;
}

@property(readonly,retain) NSString* address;
@property(readonly,assign) NSInteger port;
@property(readonly,assign) SMTPClientTLSMode tlsMode;
@property(readonly,retain) NSString* username;
@property(readonly,retain) NSString* password;

+(NSString*)CramMD5:(NSString*)challengeString key:(NSString*)secretString;

+(void)send:(NSDictionary*)params;

+(SMTPClient*)clientWithServerAddress:(NSString*)address port:(NSInteger)port tlsMode:(SMTPClientTLSMode)tlsMode username:(NSString*)authUsername password:(NSString*)authPassword;

-(id)initWithServerAddress:(NSString*)address port:(NSInteger)port tlsMode:(SMTPClientTLSMode)tlsMode username:(NSString*)authUsername password:(NSString*)authPassword;

-(void)sendMessage:(NSString*)message withSubject:(NSString*)subject from:(NSString*)from to:(NSString*)to;

@end
