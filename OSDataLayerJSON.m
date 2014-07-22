//
//  OSDataLayerJSON.m
//  Ocasta Studios
//
//  Created by Chris Birch on 22/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import "OSDataLayerJSON.h"
#import "OSDataLayerRequest.h"
#import "OSDataObject.h"
#import "OSWhereClause.h"
#import "AFNetworking.h"
#import "AppDelegate.h"


#define LOCAL_FILE @"local.json"
#define BG_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


//server keys
#define SERVER_RESPONSE_UPDATE @"update"
#define SERVER_RESPONSE_PUBS @"pubs"
#define SERVER_RESPONSE_VERSION @"version"

@interface OSDataLayerJSON ()
{
    /**
     * Stores all the data objects
     */
    NSArray* dataObjects;
}

-(id)getValueForKey: (NSString*)key fromDictionary:(NSDictionary*)json;
-(void)firstRunCopyBundledData;
-(NSURL*)urlToFileInDocsDir:(NSString*)filename;
-(NSURL*) buildDownloadURL:(NSString*)currentVersion;

/**
 * Loads the most recently downloaded data from disk
 */
-(void)loadMostRecentDataFromDisk;

@end

@implementation OSDataLayerJSON

#pragma mark -
#pragma mark Properties


-(NSURL *)localURL
{
    return [self urlToFileInDocsDir:LOCAL_FILE];
}


#pragma mark -
#pragma mark Server comms




-(void)checkForUpdate
{
    
    //construct the url where the data is
    NSURL* updateURL = [self buildDownloadURL:_currentFileVersion];
    
    NSURLRequest* updateURLRequest = [[NSURLRequest alloc] initWithURL:updateURL];
    AFJSONRequestOperation* request = [[AFJSONRequestOperation alloc] initWithRequest:updateURLRequest];

    NSUserDefaults* defaults= [NSUserDefaults standardUserDefaults];
    
    //store the current time so we know when to check again when we resume from background in the app delegate
    [defaults setValue:[NSDate date] forKey:USER_DEFAULTS_LAST_CHECKED];
    [defaults synchronize];

    
    [request setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* json = (NSDictionary*)responseObject;
         
         if (json)
         {
             NSArray* pubs = [self getValueForKey:SERVER_RESPONSE_PUBS fromDictionary:json];
             //Have we been given an array of pubs?
             if (!pubs)
             {
                 NSNumber* shouldUpdate = [self getValueForKey:SERVER_RESPONSE_UPDATE fromDictionary:json];

                 if (shouldUpdate != nil)
                 {
                     NSLog(@"Should update: %d",[shouldUpdate intValue]);
                 }
                 //Do nothing as we are already up to date
             }
             else
             {
                 //We've received some pubs
                 NSString* version = [self getValueForKey:SERVER_RESPONSE_VERSION fromDictionary:json];
                 
                 if (version)
                 {   
                     
                     //Now save the file so we can load it next time
                     if ([self saveJSONObject:pubs])
                     {
                         
                         //Now customise this data and store in dataObjects array
                         [self customiseVenues:pubs];

                     

                         NSUserDefaults* defaults= [NSUserDefaults standardUserDefaults];

                         //store the current version of the file
                         [defaults setValue:version forKey:USER_DEFAULTS_FILE_VERSION];
                         [defaults synchronize];
                         
                         _currentFileVersion = version;
                         
                         
                         _dataConnectionEstablished = YES;
                         NSLog(@"Connection estanlished");
                         [self.delegate osDataLayerConnected:self];
                         

                         
                         
                         return;
                         
                     }
                     else
                     {
                        //Do nothing as we failed to save data
                     }
                     
                     
                     
                 }
                 else
                 {
                     NSLog(@"Error occured! File version wasnt supplied");
                 }
             }
         }
         else
         {
             NSLog(@"Error occured! Invalid server response");
         }
         
         //If we are here then just load the most recent data
         [self loadMostRecentDataFromDisk];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        // [self fireFileNotDownloadedForReason:OSFileNotDownloadedReasonError withError:error];
         if (error)
         {
             NSLog(@"Error: %@", error);
         }
         
         [self loadMostRecentDataFromDisk];

     }];
    
    [request start];
    
    
}
/**
 * Loads the most recently downloaded data from disk
 */
-(void)loadMostRecentDataFromDisk
{
    NSLog(@"Loading most recent data from disk");
    
    [self loadJSONFromFile:self.localURL];
    
    _dataConnectionEstablished = YES;
    [self.delegate osDataLayerConnected:self];
}

-(BOOL)saveJSONObject:(id)json
{
    NSError* error=nil;
    
    //Now save the file so we can load it next time
    NSData* data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    
    if(data)
    {
        BOOL written = [data writeToURL:self.localURL options:NSDataWritingAtomic error:&error];

        if (written)
        {
            return YES;
        }
        else
        {
            if (error)
            {
                NSLog(@"Error: %@", error);
            }
            
            return NO;
        }
    }
    else
    {
       if (error)
       {
           NSLog(@"Error: %@", error);
       }
        
        return NO;
    }
}

#pragma mark -
#pragma mark Constructors

-(id)initWithJSONFileDownloadURL:(NSURL *)url
{
    if (self = [super init])
    {
        _fileURL = url;
        
        //try and retrieve current file version from user defaults
        _currentFileVersion = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FILE_VERSION];
     
        //check if this is the first run. If it is then copy the bundled data to the local file
        //as if we had downloaded it from the server.
        //We dont set the file version so next time we connect to the server, we will download the latest file.
        [self firstRunCopyBundledData];
    }
    
    return self;
}

-(id)init
{
    [NSException raise:@"Dont use this init" format:@"Use initWithJSONFileDownloadURL"];
    return nil;
}


#pragma mark -
#pragma mark DataLayer


-(BOOL)openDataConnection
{

    //_currentFileVersion = @"6ed7c316c492315fbec4b81899be0c6c";
    [self checkForUpdate];
    
    return YES;
}

-(void)actionRequest:(OSDataLayerRequest *)request
{
    //This datalayer can only handle requests of type: SELECT
    switch (request.type)
    {
        case OSDataLayerRequestTypeSelect:
        {
            dispatch_async(BG_QUEUE,
            ^{
                NSMutableArray* foundItems = [[NSMutableArray alloc] init];
                
                OSWhereClause* whereClause = request.whereClause;
                
                for (OSDataObject* dataObject in dataObjects)
                {
                    //eval where clause components
                    BOOL matches= [dataObject matchesWhereClause:whereClause];
                    
                    if (matches)
                    {
                        [foundItems addObject:dataObject];
                    }
                }
                
                //Complete request
                [self _completeRequest:request withItems:foundItems];
                
            });
            
            break;
        }
        default:
        {
            [NSException raise:@"Invalid request" format:@"Data layer doesnt support request type: %d",request.type];
        }
    }
}

-(void)customiseVenues:(NSArray*)array
{
    NSMutableArray* dataObjectArray = [[NSMutableArray alloc] init];
    NSError*error=nil;
    
    if (array)
    {
        for (NSDictionary* venueDictionary in array)
        {
            NSMutableDictionary* mutVenueDictionary = [venueDictionary mutableCopy];
            
            //Customise the data object by adding a field which concats name and address
            //this is used when searching
            {
                NSString*name = [mutVenueDictionary objectForKey:@"title"];
                NSString* address = [mutVenueDictionary objectForKey:@"address"];
                NSString* nameAndAddress = [[NSString alloc] initWithFormat:@"%@ %@",name,address];
                [mutVenueDictionary setObject:nameAndAddress forKey:@"name_address"];
            }
            
            //Now create the venue data object from the dictionary
            OSDataObject* venueObject = [[OSDataObject alloc] initWithDictionary:mutVenueDictionary];
            [dataObjectArray addObject:venueObject];
        }
        
        dataObjects = dataObjectArray;
        
        NSLog(@"Loaded %d venues from JSON file",dataObjects.count);
    }
    else
    {
        //error
        NSLog(@"Failed to load venues from JSON. Reason: %@",error.localizedDescription);
    }
}

-(void)loadJSONFromFile:(NSURL*)file
{
    NSError*error=nil;
    
    NSData* data = [NSData dataWithContentsOfURL:file];
    NSArray* array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (!array)
    {
        NSLog(@"Failed to parse JSON");
    }
    
    //Now customise this data and store in dataObjects array
    [self customiseVenues:array];
    
    
}


#pragma mark -
#pragma mark Helpers



-(void)firstRunCopyBundledData
{
    NSURL* localURL = self.localURL;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localURL.path])
    {
        NSLog(@"Copying bundled data to local url for the first run");
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"BundledData" ofType:@"json"];
        NSURL* url = [NSURL fileURLWithPath:path];

        [[NSFileManager defaultManager] removeItemAtURL:localURL error:nil];
        
        BOOL copied = [[NSFileManager defaultManager] copyItemAtURL:url toURL:localURL error:nil];


    }
    
    
    
}


-(id)getValueForKey: (NSString*)key fromDictionary:(NSDictionary*)json
{
    if (json)
    {
        if ([json.allKeys containsObject:key])
        {
            return [json objectForKey:key];
        }
    }
    
    return nil;
}


-(NSURL*) buildDownloadURL:(NSString*)currentVersion
{
    //AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* baseURL = DOWNLOAD_URL;
    NSString* updateURLString =nil;
    
    if (currentVersion)
        updateURLString = [[NSString alloc] initWithFormat:@"%@%@",baseURL,currentVersion];
    else
        //This must be the first run because we have no current version stored
        updateURLString = baseURL;
    
    
    NSURL* updateURL = [[NSURL alloc] initWithString:updateURLString];
    
    
    return updateURL;
    
}

-(NSURL*)urlToFileInDocsDir:(NSString*)filename
{
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [documentdir stringByAppendingPathComponent:filename];
    
    NSURL* destURL = [[NSURL alloc] initFileURLWithPath:file];
    
    return destURL;
    
}

@end
