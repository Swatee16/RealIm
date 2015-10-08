//
//  Utilities.m
//  Flights_RKT
//
//  Created by Shin, Jin on 8/6/13.
//  Copyright (c) 2013 RIG. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message setDelegate:(UIViewController *)controller{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:controller
                                          cancelButtonTitle:@"Login"
                                          otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show)
                            withObject:nil
                         waitUntilDone:NO];
}

@end
