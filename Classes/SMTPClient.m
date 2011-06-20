//
//  SMTPClient.mm
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import "SMTPClient.h"
#import "Nitrogen/NSDictionary+N2.h"
#import "Nitrogen/N2Connection.h"
#import "Nitrogen/N2Shell.h"
#import "Nitrogen/N2Debug.h"
#import "Nitrogen/NSString+N2.h"
#import "Nitrogen/NSData+N2.h"
#import <iconv.h>


const NSString* const SMTPServerAddressKey = @"SMTPServerAddress";
const NSString* const SMTPServerPortsKey = @"SMTPServerPorts";
const NSString* const SMTPServerTLSModeKey = @"SMTPServerTLSMode";
const NSString* const SMTPFromKey = @"SMTPFrom";
const NSString* const SMTPServerAuthFlagKey = @"SMTPServerAuthFlag";
const NSString* const SMTPServerAuthUsernameKey = @"SMTPServerAuthUsername";
const NSString* const SMTPServerAuthPasswordKey = @"SMTPServerAuthPassword";
const NSString* const SMTPToKey = @"SMTPTo";
const NSString* const SMTPSubjectKey = @"SMTPSubject";
const NSString* const SMTPMessageKey = @"SMTPMessage";

@interface SMTPClient ()

@property(readwrite,retain) NSString* address;
@property(readwrite,retain) NSArray* ports;
@property(readwrite,assign) SMTPClientTLSMode tlsMode;
@property(readwrite,retain) NSString* username;
@property(readwrite,retain) NSString* password;

@end


@interface _SMTPSendMessageContext : NSObject {
	NSString* _message;
	NSString* _subject;
	NSString* _from;
	NSString* _fromDescription;
	NSArray* _to;
	NSInteger _status;
	NSInteger _substatus;
	NSArray* _authModes;
	BOOL _canStartTLS;
	NSInteger _rcptToCount;
	NSTimer* _dataTimeoutTimer;
}

@property(retain) NSString* message;
@property(retain) NSString* subject;
@property(retain) NSString* from;
@property(retain) NSString* fromDescription;
@property(retain) NSArray* to;
@property NSInteger status;
@property NSInteger substatus;
@property(retain) NSArray* authModes;
@property BOOL canStartTLS;
@property NSInteger rcptToCount;
@property(retain) NSTimer* dataTimeoutTimer;

-(void)reset;

@end

@interface NSString (UTF7)

-(NSData*)UTF7Data;

@end

@implementation SMTPClient

@synthesize address = _address;
@synthesize ports = _ports;
@synthesize tlsMode = _tlsMode;
@synthesize username = _authUsername;
@synthesize password = _authPassword;

+(void)send:(NSDictionary*)params {
	NSString* serverAddress = [params objectForKey:SMTPServerAddressKey ofClass:NSString.class];
	NSArray* serverPorts = [params objectForKey:SMTPServerPortsKey ofClass:NSArray.class];
	NSNumber* serverTlsMode = [params objectForKey:SMTPServerTLSModeKey ofClass:NSNumber.class];
	NSNumber* serverAuthFlag = [params objectForKey:SMTPServerAuthFlagKey ofClass:NSNumber.class];
	NSString* serverUsername = [params objectForKey:SMTPServerAuthUsernameKey ofClass:NSString.class];
	NSString* serverPassword = [params objectForKey:SMTPServerAuthPasswordKey ofClass:NSString.class];
	NSString* from = [params objectForKey:SMTPFromKey ofClass:NSString.class];
	NSString* to = [params objectForKey:SMTPToKey ofClass:NSString.class];
	NSString* subject = [params objectForKey:SMTPSubjectKey ofClass:NSString.class];
	NSString* message = [params objectForKey:SMTPMessageKey ofClass:NSString.class];
	
	BOOL auth = [serverAuthFlag boolValue];
	
	[[[self class] clientWithServerAddress:serverAddress ports:serverPorts tlsMode:[serverTlsMode integerValue] username: auth? serverUsername : nil password: auth? serverPassword : nil ] sendMessage:message withSubject:subject from:from to:to];
}

+(SMTPClient*)clientWithServerAddress:(NSString*)address ports:(NSArray*)ports tlsMode:(SMTPClientTLSMode)tlsMode username:(NSString*)authUsername password:(NSString*)authPassword {
	return [[[[self class] alloc] initWithServerAddress:address ports:ports tlsMode:tlsMode username:authUsername password:authPassword] autorelease];
}

-(id)initWithServerAddress:(NSString*)address ports:(NSArray*)ports tlsMode:(SMTPClientTLSMode)tlsMode username:(NSString*)authUsername password:(NSString*)authPassword {
	if ((self = [super init])) {
		if (!address.length) [NSException raise:NSInvalidArgumentException format:@"Invalid server address"];
		self.address = address;
		if (ports.count) self.ports = ports;
		else self.ports = [NSArray arrayWithObjects: [NSNumber numberWithInteger:25], [NSNumber numberWithInteger:465], [NSNumber numberWithInteger:587], NULL];
		self.tlsMode = tlsMode;
		self.username = authUsername;
		self.password = authPassword;
	}
	
	return self;
}

-(void)dealloc {
	self.address = nil;
	self.ports = nil;
	self.username = nil;
	self.password = nil;
	[super dealloc];
}

+(void)_splitAddress:(NSString*)address intoEmail:(NSString**)email description:(NSString**)desc {
	NSInteger lti = [address rangeOfString:@"<" options:0].location;
	NSInteger gti = [address rangeOfString:@">" options:NSBackwardsSearch].location;
	if (lti != NSNotFound) {
		if (gti != NSNotFound) {
			if (lti < gti) {
				*email = [[address substringWithRange:NSMakeRange(lti+1, gti-lti-1)] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
				*desc = [[address substringToIndex:MAX(0,lti-1)] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
			} else [NSException raise:NSInvalidArgumentException format:@"Invalid sender email address"];
		} else [NSException raise:NSInvalidArgumentException format:@"Invalid sender email address"];
	} else {
		if (gti != NSNotFound)
			[NSException raise:NSInvalidArgumentException format:@"Invalid sender email address"];
		else {
			*email = address;
			*desc = nil;
		}
	}
}

-(void)sendMessage:(NSString*)message withSubject:(NSString*)subject from:(NSString*)from to:(NSString*)toAddresses {
	if (!from.length) [NSException raise:NSInvalidArgumentException format:@"Empty sender email address"];
	if (!toAddresses.length) [NSException raise:NSInvalidArgumentException format:@"Empty destination email address"];
	
	NSHost* host = [NSHost hostWithName:self.address];
	if (!host) [NSException raise:NSInvalidArgumentException format:@"Invalid server address"];
		
	_SMTPSendMessageContext* context = [[_SMTPSendMessageContext new] autorelease];
	context.message = message;
	context.subject = subject;
	
	NSString* tempAddress;
	NSString* tempLabel;
	
	[[self class] _splitAddress:from intoEmail:&tempAddress description:&tempLabel];
	context.from = tempAddress;
	context.fromDescription = tempLabel;
	
	NSMutableArray* to = [NSMutableArray array];
	for (NSString* ito in [toAddresses componentsSeparatedByString:@","]) {
		ito = [ito stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
		[[self class] _splitAddress:ito intoEmail:&tempAddress description:&tempLabel];
		[to addObject:[NSArray arrayWithObjects: tempAddress, tempLabel, nil]];
	}
	
	context.to = to;
	
	NSException* exception = nil;
	for (NSNumber* port in self.ports) {
		NSInteger portNumber = [port integerValue];
		NSLog(@"Trying with port %d...", portNumber);
		@try {
			[context reset];
			[N2Connection sendSynchronousRequest:nil toAddress:self.address port:portNumber tls:NO dataHandlerTarget:self selector:@selector(_connection:handleData:context:) context:context];
			exception = nil;
			break;
		} @catch (NSException* e) {
			exception = e;
			NSLog(@"Port %d: %@", portNumber, [e reason]);
		}
	} if (exception)
		@throw exception;
}

enum SMTPClientContextStatuses {
	InitialStatus = 0,
	StatusHELO,
	StatusEHLO,
	StatusSTARTTLS,
	StatusAUTH,
	StatusMAIL,
	StatusRCPT,
	StatusDATA,
	StatusQUIT
};

enum SMTPClientContextSubstatuses {
	PlainAUTH = 1,
	LoginAUTH,
	CramMD5AUTH
};

+(NSString*)CramMD5:(NSString*)challengeString key:(NSString*)secretString {
	unsigned char ipad[64], opad[64];
	
	NSData* secretData = [secretString dataUsingEncoding:NSUTF8StringEncoding];
	if (secretData.length > 64)
		secretData = [secretData md5];
	[secretData getBytes:ipad];
	memset(&ipad[secretData.length], 0, 64-secretData.length);
	memcpy(opad, ipad, 64);
	for (NSInteger i = 0; i < 64; ++i) {
		ipad[i] ^= 0x36;
		opad[i] ^= 0x5c;
	}
	
	// MD5(opad, MD5(ipad, challenge))
	NSMutableData* r1 = [NSMutableData dataWithBytes:opad length:64];
	NSMutableData* r2 = [NSMutableData dataWithBytes:ipad length:64];
	[r2 appendData:[challengeString dataUsingEncoding:NSUTF8StringEncoding]];
	[r1 appendData:[r2 md5]];
	return [[r1 md5] hex];
}

-(void)_writeLine:(id)line to:(N2Connection*)connection {
	NSLog(@"<- %@", line);
	if ([line isKindOfClass:NSString.class])
		line = [line dataUsingEncoding:NSUTF8StringEncoding];
	[connection writeData:line];
	[connection writeData:[NSData dataWithBytesNoCopy:(void*)"\r\n" length:2 freeWhenDone:NO]];
}

-(void)_ehlo:(N2Connection*)connection context:(_SMTPSendMessageContext*)context {
	[self _writeLine:[@"EHLO " stringByAppendingString:[N2Shell hostname]] to:connection];
	context.status = StatusEHLO;
}

-(void)_mail:(N2Connection*)connection context:(_SMTPSendMessageContext*)context {
	NSString* from = [NSString stringWithFormat:@"<%@>", context.from];
	[self _writeLine:[@"MAIL FROM: " stringByAppendingString:from] to:connection];
	context.status = StatusMAIL;
}

-(void)_auth:(N2Connection*)connection context:(_SMTPSendMessageContext*)context {
	if (self.username && self.password) {
		if ([context.authModes containsObject:@"CRAM-MD5"]) {
			[self _writeLine:@"AUTH CRAM-MD5" to:connection];
			context.status = StatusAUTH;
			context.substatus = CramMD5AUTH;
		}
		else if ([context.authModes containsObject:@"PLAIN"]) {
			[self _writeLine:[@"AUTH PLAIN " stringByAppendingString:[[[NSString stringWithFormat:@"%@\0%@\0%@", self.username, self.username, self.password] dataUsingEncoding:NSUTF8StringEncoding] base64]] to:connection];
			context.status = StatusAUTH;
			context.substatus = PlainAUTH;
		}
		else if ([context.authModes containsObject:@"LOGIN"]) {
			[self _writeLine:@"AUTH LOGIN" to:connection];
			context.status = StatusAUTH;
			context.substatus = LoginAUTH;
		}
		else [NSException raise:NSGenericException format:@"The server doesn't allow any authentication techniques supported by this client."];
	} else
		[self _mail:connection context:context];
}

-(void)_connection:(N2Connection*)connection handleCode:(NSInteger)code withMessage:(NSString*)message separator:(unichar)separator context:(_SMTPSendMessageContext*)context {
//	NSLog(@"HANDLE: [Status %d] Handling %d with %@", context.status, code, message);
	
	if (code >= 500)
		[NSException raise:NSGenericException format:@"Error %d: %@", code, message];
	
	switch (context.status) {
		case InitialStatus: {
			switch (code) {
				case 220:
					if ((![connection isSecure] && _tlsMode) || (self.username && self.password)) {
						[self _ehlo:connection context:context];
						return;
					} else {
						[self _writeLine:[@"HELO " stringByAppendingString:[N2Shell hostname]] to:connection];
						context.status = StatusHELO;
						return;
					}
			}
		} break;
		case StatusHELO:
		case StatusEHLO: {
			switch (code) {
				case 250:
					if (separator == '-') {
						NSString* name;
						NSString* value;
						[message splitStringAtCharacterFromSet:NSCharacterSet.whitespaceCharacterSet intoChunks:&name:&value separator:NULL];
						
						if ([name isEqualToString:@"AUTH"])
							context.authModes = [value componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
						if ([name isEqualToString:@"STARTTLS"])
							context.canStartTLS = YES;
					} else
						if (![connection isSecure] && _tlsMode) {
							if (context.canStartTLS) {
								[self _writeLine:@"STARTTLS" to:connection];
								context.status = StatusSTARTTLS;
							} else if (_tlsMode == SMTPClientTLSModeTLSOrClose)
								[NSException raise:NSGenericException format:@"Server doesn't support STARTTLS"];
							else { // TLSIfPossible, not possible...
								[self _auth:connection context:context];
							}
						} else
							[self _auth:connection context:context];
					return;
			}
		} break;
		case StatusSTARTTLS: {
			if (code == 220) {
				[connection startTLS];
				[self _ehlo:connection context:context];
				return;
			}
		} break;
		case StatusAUTH: {
			switch (context.substatus) {
				case PlainAUTH:
					switch (code) {
						case 235:
							[self _mail:connection context:context];
							return;
					} break;
				case LoginAUTH:
					switch (code) {
						case 334:
							message = [[[NSString alloc] initWithData:[NSData dataWithBase64:message] encoding:NSUTF8StringEncoding] autorelease];
							if ([message isEqualToString:@"Username:"]) {
								[self _writeLine:[[self.username dataUsingEncoding:NSUTF8StringEncoding] base64] to:connection];
								return;
							} else if ([message isEqualToString:@"Password:"]) {
								[self _writeLine:[[self.password dataUsingEncoding:NSUTF8StringEncoding] base64] to:connection];
								return;
							}
						case 235:
							[self _mail:connection context:context];
							return;
					} break;
				case CramMD5AUTH:
					switch (code) {
						case 334: {
							message = [[[NSString alloc] initWithData:[NSData dataWithBase64:message] encoding:NSUTF8StringEncoding] autorelease];
							NSString* temp = [NSString stringWithFormat:@"%@ %@", self.username, [[self class] CramMD5:message key:self.password]];
							NSLog(@"CRAM-MD5 %@", temp);
							[self _writeLine:[[temp dataUsingEncoding:NSUTF8StringEncoding] base64] to:connection];
							return;
						} break;
						case 235:
							[self _mail:connection context:context];
							return;
					} break;

			}
		} break;
		case StatusMAIL: {
			switch (code) {
				case 250:
					for (NSArray* ito in context.to) {
						NSString* to = [ito objectAtIndex:0];
						if ([to rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]].location == NSNotFound)
							to = [NSString stringWithFormat:@"<%@>", to];
						[self _writeLine:[@"RCPT TO: " stringByAppendingString:to] to:connection];
						context.rcptToCount += 1;
					}
					context.status = StatusRCPT;
					return;
			}
		} break;
		case StatusRCPT: {
			switch (code) {
				case 250: {
					context.rcptToCount -= 1;
					if (context.rcptToCount == 0) {
						[self _writeLine:@"DATA" to:connection];
						context.status = StatusDATA;
					}
					return;
				}
			}
		} break;
		case StatusDATA: {
			switch (code) {
				case 0: // disconnection
				case 250:
					[self _writeLine:@"QUIT" to:connection];
					context.status = StatusQUIT;
					if (code == 0)
						[connection close];
					return;
				case 354:
					if (context.fromDescription)
						[self _writeLine:[NSString stringWithFormat:@"From: =?UTF-8?B?%@?= <%@>", [[context.fromDescription dataUsingEncoding:NSUTF8StringEncoding] base64], context.from] to:connection];
					else [self _writeLine:[NSString stringWithFormat:@"From: %@", context.from] to:connection];
					
					NSMutableString* to = [NSMutableString string];
					for (NSArray* ito in context.to) {
						if (to.length)
							[to appendString:@", "];
						if (ito.count > 1)
							[to appendFormat:@"=?UTF-8?B?%@?= <%@>", [[[ito objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding] base64], [ito objectAtIndex:0]];
						else [to appendFormat:@"%@", [ito objectAtIndex:0]];
					}
					[self _writeLine:[NSString stringWithFormat:@"To: %@", to] to:connection];
					
					[self _writeLine:[NSString stringWithFormat:@"Subject: =?UTF-8?B?%@?=", [[context.subject dataUsingEncoding:NSUTF8StringEncoding] base64]] to:connection];
					[self _writeLine:@"Mime-Version: 1.0" to:connection];
					[self _writeLine:@"Content-Type: text/html; charset=\"UTF-7\"" to:connection];
					[self _writeLine:@"Content-Transfer-Encoding: 7bit" to:connection];
					
					[self _writeLine:@"" to:connection];
					
					NSString* message = [context.message stringByReplacingOccurrencesOfString:@"\r\n." withString:@"\r\n.."];
					[self _writeLine:[message UTF7Data] to:connection];
					
					[self _writeLine:@"." to:connection];

					return;
			}
		} break;
		case StatusQUIT: {
			switch (code) {
				case 0: // disconnection
				case 221:
					return;
			}
		} break;
	}
	
	[NSException raise:NSGenericException format:@"Don't know how to act with status %d, code %d", context.status, code];
}

-(void)_connection:(N2Connection*)connection handleLine:(NSString*)line context:(_SMTPSendMessageContext*)context {
	NSLog(@"-> %@", line);
	
	NSInteger code = 0;
	NSString* message = nil;
	NSString* temp = nil;
	unichar separator = 0;
	
	[line splitStringAtCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" -"] intoChunks:&temp:&message separator:&separator];
	code = [temp integerValue];
	
	if (code) {
		[self _connection:connection handleCode:code withMessage:message separator:separator context:context];
	} else [NSException raise:NSGenericException format:@"Couldn't parse line"];
}

-(NSInteger)_connection:(N2Connection*)connection handleData:(NSData*)data context:(_SMTPSendMessageContext*)context {
	if (!data) { // close
		[self _connection:connection handleCode:0 withMessage:nil separator:0 context:context];
//		NSLog(@"Closing :(");
		return 0;
	}
	
	if (!data.length) { // open
		context.dataTimeoutTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1] interval:0 target:self selector:@selector(_dataTimeoutCallback:) userInfo:connection repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:context.dataTimeoutTimer forMode:NSDefaultRunLoopMode];
		return 0;
	}
	
	if (context.dataTimeoutTimer) {
		[context.dataTimeoutTimer invalidate];
		context.dataTimeoutTimer = nil;
	}
	
	char* datap = (char*)data.bytes;
	NSInteger datal = data.length, datalused = 0;
	
	while (datal > 0) {
		char* p = strnstr(datap, "\r\n", datal);
		if (!p) return datalused;
		size_t l = p-datap;
		
		if (l) {
			NSString* line = [[NSString alloc] initWithCStringNoCopy:datap length:l freeWhenDone:NO];
			
			[self _connection:connection handleLine:line context:context];
			
			[line release];
		}
		
		l += 2;
		datap += l;
		datal -= l;
		datalused += l;
	}
	
	return datalused;
}

-(void)_dataTimeoutCallback:(NSTimer*)timer {
	N2Connection* connection = [timer userInfo];
	if (_tlsMode)
		[connection startTLS];
	else [NSException raise:NSGenericException format:@"Connection stalled, probably wants TLS handshake, user said no TLS"];
}

@end

@implementation _SMTPSendMessageContext

@synthesize message = _message;
@synthesize subject = _subject;
@synthesize from = _from;
@synthesize fromDescription = _fromDescription;
@synthesize to = _to;
@synthesize status = _status;
@synthesize substatus = _substatus;
@synthesize authModes = _authModes;
@synthesize canStartTLS = _canStartTLS;
@synthesize rcptToCount = _rcptToCount;
@synthesize dataTimeoutTimer = _dataTimeoutTimer;

-(void)setStatus:(NSInteger)status {
	_status = status;
	self.substatus = 0;
}

-(void)reset {
	[self setStatus:InitialStatus];
	self.authModes = nil;
	self.canStartTLS = NO;
	self.rcptToCount = 0;
	[self.dataTimeoutTimer invalidate];
	self.dataTimeoutTimer = nil;
}

-(void)dealloc {
	self.message = nil;
	self.subject = nil;
	self.from = nil;
	self.fromDescription = nil;
	self.to = nil;
	[self reset];
	[super dealloc];
}

@end

@implementation NSString (UTF7)

-(NSData*)UTF7Data {
	static iconv_t iconv_descr = nil;
	if (!iconv_descr) iconv_descr = iconv_open("UTF-7", "UTF-8");
	if (iconv_descr == (iconv_t)-1) [NSException raise:NSGenericException format:@"iconv_open error %d", errno];
	
	NSMutableData* odata = [NSMutableData data];
	
	char* in_p = (char*)[self UTF8String];
	size_t in_size = strlen(in_p);

	iconv(iconv_descr, NULL, 0, NULL, 0); // reset iconv
	
	do {
		char out_buff[1024];
		char* out_p = out_buff;
		size_t out_avail = sizeof(out_buff);
		// do the transformation
		iconv(iconv_descr, &in_p, &in_size, &out_p, &out_avail);
		// copy the output buffer to odata
		[odata appendBytes:out_buff length:(sizeof(out_buff)-out_avail)];
	} while (in_size > 0);

	return odata;
}

@end













