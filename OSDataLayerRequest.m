//
//  OSDataLayerRequest.m
//  Ocasta Studios
//
//  Created by Chris Birch on 19/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import "OSDataLayerRequest.h"

@interface OSDataLayerRequest ()


#pragma mark -
#pragma mark "Friend" Declarations
/**
 * "Friend" method called by base OSDataLayer implementation when it needs to change the 
 * "active" property of a request
 */
-(void)_setActive:(BOOL)isActive;


/**
 * "Friend" method called by base OSDataLayer implementation when it needs to change the
 * "cancelled" property of a request
 */
-(void)_setCancelled:(BOOL)isCancelled;

@end

@implementation OSDataLayerRequest


#pragma mark -
#pragma mark Constructors

-(id)initWithDictionary:(NSMutableDictionary*)userInfo type:(OSDataLayerRequestType)type andDelegate:(id<OSDataLayerRequestDelegate>)delegate
{
    if (self = [super init])
    {
        _type = type;
        _delegate = delegate;
        _userInfo = userInfo;
    }
    
    return self;
}


#pragma mark -
#pragma mark "Friend" implementations


-(void)_setActive:(BOOL)isActive
{
    _active = isActive;
}

-(void)_setCancelled:(BOOL)isCancelled
{
    _cancelled = isCancelled;
}



@end
