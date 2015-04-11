//
//  SMTPClientWindowComtroller.h
//
//  Created by Alessandro Volz on 08.06.11.
//  Copyright 2011 Alessandro Volz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MailMeTooWindowController : NSWindowController<NSMenuDelegate> {
	IBOutlet NSTextField* _addressField;
	IBOutlet NSTextField* _portsField;
	IBOutlet NSMatrix* _tlsMatrix;
	IBOutlet NSTextField* _fromField;
	IBOutlet NSButton* _authCheckbox;
	IBOutlet NSTextField* _usernameField;
	IBOutlet NSTextField* _passwordField;
	IBOutlet NSTextField* _toField;
	IBOutlet NSTextField* _subjectField;
	IBOutlet NSTextField* _messageField;
	IBOutlet NSTextField* _statusField;
}

-(void)setStatus:(NSString*)str;

-(IBAction)setPassword:(id)sender;

-(IBAction)sendAction:(id)sender;

@end
