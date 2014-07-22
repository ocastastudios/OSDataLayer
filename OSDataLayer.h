//
//  OSDataLayer.h
//  Ocasta Studios
//
//  Created by Chris Birch on 18/02/2013.
//  Modified by:
//  Date:
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

/**
 * Implement this in order to implement a custom data layer.
 *
 * Data layer responibility is to keep track of all objects using a particular storage technology
 * and then return a unified/standard representation of them via the exposed "dictionary" property.
 *
 * The app that this code is bundled with only needs to know how to interact with this protocol in order to
 * retrieve data. implementing this protocol ensures loose coupling of application logic and as a bonus makes it
 * possible to mix and match data sources with (relative) ease. i.e within the same app we can have many different
 * data sources; One protocol implementation could have mysql backend, one a json store, etc ......
 *
 * Data is represented in this system using OSDataObject instances.
 */

#import <Foundation/Foundation.h>

@class OSDataLayerRequest;
@class OSWhereClause;

@protocol OSDataLayerDelegate;
@protocol OSDataLayerRequestDelegate;

@interface OSDataLayer : NSObject
{
@protected
    BOOL _dataConnectionEstablished;
}
/**
 * Instance that will respond to data layer events
 */
@property(nonatomic,assign) id<OSDataLayerDelegate> delegate;

/**
 * Returns YES if data connection has been opened.
 * If this property doenst return YES then non of the data retrieval functions will work.
 */
@property(nonatomic,readonly) BOOL dataConnectionEstablished;

/**
 * An array of data layer requests that are pending
 */
@property(nonatomic,readonly) NSArray* requests;

/**
 * Called when the data layer implementation should intinitate contact with it's data source.
 * This could do many differnt things depending on its imp. For instance if using a smallish json
 * data file, we could use this oppertunity to create in memory representations of the json file.
 * Be careful though! Dont use a long running blocking operation here!
 */
-(BOOL)openDataConnection;


#pragma mark -
#pragma mark Action request (Override this!)

/**
 * Inheriting class must provide an implementation of this method in order
 * to carry out the specified request.
 * After request has been actioned, be sure to call _completeRequest or _failRequest.
 * NB! this method is called on a worker thread so you should NOT start a new thread or call any async library functions.
 */
-(void)actionRequest:(OSDataLayerRequest*)request;

#pragma mark -
#pragma mark Item searching

///**
// * Starts async request for all items stored in the specified table thats contains the field whose value matches the
// * specified string literal.
// * Returns NO if data connection isnt open
// */
//-(BOOL)requestItemsInEntityNamed:(NSString*)entityName matchingFieldValueString:(NSString*)fieldName usingStringLiteral:(NSString*)literal withDelegate:(id<OSDataLayerRequestDelegate>)delegate;

/**
 * Starts async request for all items stored in the specified table thats contains the field whose value matches the
 * specified regex expression
 * Returns NO if data connection isnt open
 */
//-(BOOL)requestItemsInTableNamed: (NSString*)tableName matchingFieldValueRegex:(NSString*)fieldName usingRegEx:(NSString*)regex withDelegate:(id<OSDataLayerRequestDelegate>)delegate;

/**
 * Convenient method allowing use of NSPredicates and NSSortDescriptors
 */
//-(BOOL)requestItemsInEntityNamed:(NSString*)tableName withArrayOfPredicate:(NSArray*)predicates sortDescriptors:(NSArray*)sortDescriptors;

/**
 * Starts async request for all items stored in the specified table that match the values specified in the dictionary
 * Throws an exception if data layer connection is not established
 */
-(void)requestItemsInEntityNamed:(NSString*)tableName whereItemsMatchWhereClause:(OSWhereClause*)whereClause withDelegate:(id<OSDataLayerRequestDelegate>)delegate;

#pragma mark -
#pragma mark Cancel requests

/**
 * Cancels all active requests
 */
-(void)cancelRequests;

/**
 * Cancels all requests for the specified delegate
 */
-(void)cancelRequestsForDelegate:(id<OSDataLayerRequestDelegate>)delegate;

#pragma mark -
#pragma mark Internal stuff, should only be called by inheritors of this class!

-(void)_queueRequest:(OSDataLayerRequest*)request;

-(void)_completeRequest:(OSDataLayerRequest*)request withItems:(NSArray*)items;

-(void)_failRequest:(OSDataLayerRequest*)request withError:(NSError*)error;

@end

#pragma mark -
#pragma mark OSDataLayerDelegate

@protocol OSDataLayerDelegate <NSObject>

@required

/**
 * Called when data layer establishes a connection to its data source
 */
-(void)osDataLayerConnected:(OSDataLayer*)dataLayer;

/**
 * Called when data layer fails to establish a connection to its data source
 */
-(void)osDataLayerFailedToConnect:(OSDataLayer*)dataLayer withError:(NSError*)error;


@end

