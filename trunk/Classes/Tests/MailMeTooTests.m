//
//  SMTPClientTests.mm
//
//  Created by Alessandro Volz on 6/13/11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import "MailMeTooTests.h"
#import "SMTPClient.h"

@implementation SMTPClientTests

-(void)testCramMD5 {
	NSString* result = [SMTPClient CramMD5:@"<1896.697170952@postoffice.reston.mci.net>" key:@"tanstaaftanstaaf"];
	NSLog(@"CramMD5 says %@...", result);
    STAssertTrue([result caseInsensitiveCompare:@"b913a602c7eda7a495b4e6e7334d3890"] == NSOrderedSame, @"Problem with CRAM-MD5." );
}

@end
