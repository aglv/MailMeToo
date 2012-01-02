//
//  MailApp.h
//
//  Created by Alessandro Volz on 6/18/11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MailApp : NSObject {
}

+(NSDictionary*)SmtpAccounts;
+(NSString*)SmtpPasswordForAccount:(NSDictionary*)account;

@end
