//
//  OSDataObject.h
//  Ocasta Studios
//
//  Created by Chris Birch on 18/02/2013.
//  Modified by:
//  Date:
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

/**
 * Generic storage class used by all OSDataLayer implementations.
 */

#import <Foundation/Foundation.h>

@class OSWhereClause;

@interface OSDataObject : NSObject<NSCopying>


#pragma mark -
#pragma mark Properties

/**
 * Returns the value contained within this object as key(string) value (NSObject*) pair dictionary.
 */
@property(nonatomic,readonly) NSDictionary* dictionary;

/**
 * Allows arbitraty data to be stored along with this data object. This is used in app specific manner
 * and the data is not serialised so is lost when reset.
 */
@property(nonatomic,strong) NSMutableDictionary* userData;

#pragma mark -
#pragma mark Constructors


/**
 * Inits an instance of this class by passing a dictionary containing the values of the data entity
 */
-(id)initWithDictionary:(NSDictionary*)dictionary;


#pragma mark -
#pragma mark Matching

/**
 * Returns YES if the specified where clause (and children) match this object.
 */
-(BOOL)matchesWhereClause:(OSWhereClause*)clause;

#pragma mark -
#pragma mark Convenience methods for assisting with app logic

/**
 * Convenience method that casts the specified key in the specified dictionary as a float.
 * This method is used in conjunction with the value returned from the "dictionary" property
 * of an instance of this class.
 */
+(float)valueAsFloat:(NSString*)dictionaryKey fromDictionary:(NSDictionary*)dictionary;

/**
 * Convenience method that casts the specified key in the specified dictionary as an int.
 * This method is used in conjunction with the value returned from the "dictionary" property
 * of an instance of this class.
 */
+(int)valueAsInt:(NSString*)dictionaryKey fromDictionary:(NSDictionary*)dictionary;

/**
 * Convenience method that casts the specified key in the specified dictionary as a bool.
 * This method is used in conjunction with the value returned from the "dictionary" property
 * of an instance of this class.
 */
+(BOOL)valueAsBOOL:(NSString*)dictionaryKey fromDictionary:(NSDictionary*)dictionary;

///**
// * Convenience method that casts the specified key in the specified dictionary as a string.
// * This method is used in conjunction with the value returned from the "dictionary" property
// * of an instance of this class.
// */
//+(NSString*)valueAsString:(NSString*)dictionaryKey fromDictionary:(NSDictionary*)dictionary;
//




@end
