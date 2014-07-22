//
//  OSDataLayerJSON.h
//  Ocasta Studios
//
//  Created by Chris Birch on 22/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDataLayer.h"


@interface OSDataLayerJSON : OSDataLayer

/**
 * The url that points to the json file on the server
 */
@property(nonatomic,strong) NSURL* fileURL;


/**
 * The url that points to file on the local system
 */
@property(nonatomic,readonly) NSURL* localURL;

/**
 * The date of the latest downloaded content
 */
@property(nonatomic,readonly)NSString* currentFileVersion;
/**
 * Inits a new instance
 */
-(id)initWithJSONFileDownloadURL:(NSURL*)url;

/**
 * Causes the server to be  for the latest version
 */
-(void)checkForUpdate;

@end
