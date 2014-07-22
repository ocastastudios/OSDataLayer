//
//  OSDataLayer.m
//  Ocasta Studios
//
//  Created by Chris Birch on 19/02/2013.
//  Modified by:
//  Date:
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import "OSDataLayer.h"
#import "OSDataLayerRequest.h"
#import "OSWhereClause.h"


//"Friend" methods of data layer request
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



@interface OSDataLayer ()
{
    NSMutableArray* _requests;
    //not subclasses of OSDatalayerRequest
    NSOperationQueue* _requestQueue;
    
    
}

@end


@implementation OSDataLayer


#pragma mark -
#pragma mark Properties


-(BOOL)openDataConnection
{
    [NSException raise:@"Not implemented" format:@""];
    return NO;
}


#pragma mark -
#pragma mark Item searching

-(void)requestItemsInEntityNamed:(NSString*)tableName whereItemsMatchWhereClause:(OSWhereClause*)whereClause withDelegate:(id<OSDataLayerRequestDelegate>)delegate
{
    if (_dataConnectionEstablished)
    {
        NSMutableDictionary* customData = [[NSMutableDictionary alloc] init];
        OSDataLayerRequest* request = [[OSDataLayerRequest alloc] initWithDictionary:customData type:OSDataLayerRequestTypeSelect andDelegate:delegate];
        request.whereClause = whereClause;
        
        [self _queueRequest:request];
        
    }
    else
    {
        [NSException raise:@"Data connection not established" format:@"Please enusre data connection has been established before trying to access data"];
    }
}



-(void)actionRequest:(OSDataLayerRequest*)request
{
    [NSException raise:@"Not implemented" format:@""];
}


/**
 * Called on worker thread.
 */
-(void)_actionRequest:(OSDataLayerRequest*)request
{
    //If the request has been cancelled then dont bother
    if (!request.cancelled)
    {
        [request _setActive:YES];
        
        [self actionRequest:request];
        
    }
    else
    {
        //Request was cancelled
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _completeRequest:request withItems:nil];
        });
        
    }
}

#pragma mark -
#pragma mark Cancel Requests

-(void)cancelRequests
{
    @synchronized(_requests)
    {
        //Loop through all the requests and modify each one so that its cancelled flag is true
        //If the request is queued in the operation queue, when it is started it will check to see if
        //it has been cancelled, if its active then when it completes it will not fire back success delegate.
        for (OSDataLayerRequest* request in _requests)
        {
            [request _setCancelled:YES];
        }
    }
    
}

-(void)cancelRequestsForDelegate:(id<OSDataLayerRequestDelegate>)delegate
{
    @synchronized(_requests)
    {
        //Loop through all the requests and modify each one that shares the
        //specified delegate so that its cancelled flag is true
        //If the request is queued in the operation queue, when it is started it will check to see if
        //it has been cancelled, if its active then when it completes it will not fire back success delegate.
        for (OSDataLayerRequest* request in _requests)
        {
            if (request.delegate == delegate)
            {
                [request _setCancelled:YES];
            }
        }
    }
}

#pragma mark -
#pragma mark Internal stuff

-(void)_queueRequest:(OSDataLayerRequest*)request
{
    //    @synchronized(_requests)
    {
        [_requests addObject:request];
    }
    
    //not active until its started in the operation queue
    [request _setActive:NO];
    //not cancelled
    [request _setCancelled:NO];
    
    NSOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(_actionRequest:) object:request];
    [_requestQueue addOperation:operation];
    [_requestQueue setMaxConcurrentOperationCount:5];
}

-(void)_completeRequest:(OSDataLayerRequest*)request withItems:(NSArray*)items
{
    @synchronized(_requests)
    {
        [_requests removeObject:request];
    }
    
    [request _setActive:NO];
    
    if (request.cancelled)
    {
        //request was cancelled so alert delegate
        if ([request.delegate respondsToSelector:@selector(osDataLayerRequestCancelled:)])
        {
            [request.delegate osDataLayerRequestCancelled:request];
        }
    }
    else
    {
        //alert delegate
        [request.delegate osDataLayerRequest:request itemsRetrieved:items];
    }
    
    
}

-(void)_failRequest:(OSDataLayerRequest*)request withError:(NSError*)error
{
    @synchronized(_requests)
    {
        [_requests removeObject:request];
    }
    
    [request _setActive:NO];
    
    if (request.cancelled)
    {
        //request was cancelled so alert delegate
        if ([request.delegate respondsToSelector:@selector(osDataLayerRequestCancelled:)])
        {
            [request.delegate osDataLayerRequestCancelled:request];
        }
    }
    else
    {
        //alert delegate
        [request.delegate osDataLayerRequest:request retrievalFailedWithError:error];
    }
    
    
    
}



-(id)init
{
    if (self = [super init])
    {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requests = [[NSMutableArray alloc] init];
    }
    
    return self;
}


@end