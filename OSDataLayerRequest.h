//
//  OSDataLayerRequest.h
//  Ocasta Studios
//
//  Created by Chris Birch on 19/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDataLayerEnums.h"

@class OSDataLayer;
@class OSWhereClause;

@protocol OSDataLayerRequestDelegate;

@interface OSDataLayerRequest : NSObject

/**
 * The name of the entity (or table) that is affected by this request
 */
@property(nonatomic,strong) NSString* entityName;
/**
 * The type of request
 */
@property(nonatomic,readonly) OSDataLayerRequestType type;

/**
 * Set to YES when this request is being actioned.
 */
@property(nonatomic,readonly) BOOL active;

/**
 * Set to YES when this request has been cancelled. When a request is cancelled, it will no longer 
 * fire itemsRetrieved or failed delegate methods. Instead the cancelled method will fire.
 */
@property(nonatomic,readonly) BOOL cancelled;

/**
 * Pointer to the parent data layer
 */
@property(nonatomic,weak) OSDataLayer* dataLayer;
/**
 * The instance that is notified of retrieval success or failure
 */
@property(nonatomic,assign) id<OSDataLayerRequestDelegate>delegate;

/**
 * Holds user defined data about the request
 */
@property(nonatomic,strong) NSMutableDictionary* userInfo;

#pragma mark -
#pragma mark Properties concerning Request type SELECT

/**
 * An array of strings representing the names of fields that are to be included in the results of a Select request
 */
@property(nonatomic,strong) NSArray* selectFields;

/**
 * An OSWhereClause that describes which entities should be returned
 */
@property(nonatomic,strong) OSWhereClause* whereClause;



#pragma mark -
#pragma mark Properties concerning Request type INSERT

#pragma mark -
#pragma mark Properties concerning Request type UPDATE

#pragma mark -
#pragma mark Properties concerning Request type DELETE


#pragma mark -
#pragma mark Constructors

/**
 * Creates a new instance by specifying the requests type, custom data and callback delegate
 */
-(id)initWithDictionary:(NSMutableDictionary*)userInfo type:(OSDataLayerRequestType)type andDelegate:(id<OSDataLayerRequestDelegate>)delegate;

@end

#pragma mark -
#pragma mark OSDataLayerRequestDelegate

/**
 * Implement in order to be notified of data layer request events
 */
@protocol OSDataLayerRequestDelegate <NSObject>

@required
/**
 * Called when data layer succesfully retrieves items
 */
-(void)osDataLayerRequest:(OSDataLayerRequest*)request itemsRetrieved:(NSArray*)items;


/**
 * Called when data layer fails to retrieves items
 */
-(void)osDataLayerRequest:(OSDataLayerRequest*)request retrievalFailedWithError:(NSError*)error;


@optional

/**
 * Called when data layer fails to retrieves items
 */
-(void)osDataLayerRequestCancelled:(OSDataLayerRequest*)request;


@end