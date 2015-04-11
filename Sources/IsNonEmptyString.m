//
//  IsNonEmptyString.m
//  MailMeToo
//
//  Created by Alessandro Volz on 1/4/12.
//  Copyright (c) 2012 Ingroppalgrillo. All rights reserved.
//

#import "IsNonEmptyString.h"

@implementation IsNonEmptyString

+(void)load {
    id transformer = [[self alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"IsNonEmptyString"];
    [transformer release];
}

+(Class)transformedValueClass {
    return [NSString class];
}

+(BOOL)allowsReverseTransformation {
    return NO;
}

-(id)transformedValue:(NSString*)input {
    return [NSNumber numberWithBool: input.length != 0 ];
}

@end
