//
//  MMTPopUpButtonCell.m
//  MailMeToo
//
//  Created by Alessandro Volz on 1/2/12.
//  Copyright (c) 2012 Ingroppalgrillo. All rights reserved.
//

#import "MMTPopUpButtonCell.h"

@implementation MMTPopUpButtonCell

-(NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView {
    title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Clone an SMTP account...", nil) attributes:[title attributesAtIndex:0 effectiveRange:NULL]] autorelease];
    return [super drawTitle:title withFrame:frame inView:controlView];
}

@end
