//
//  OSDataLayerRequestWhereClause.h
//  Ocasta Studios
//
//  Created by Chris Birch on 22/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    /**
     * Specifies that values within the values array will be combined using AND
     */
    OSCombineOperatorAND,
    /**
     * Specifies that values within the values array will be combined using OR
     */
    OSCombineOperatorOR
    
} OSCombineOperator;

typedef enum
{
    
    OSComparisonModeLiteral,
    OSComparisonModeRegEx
} OSComparisonMode;


@interface OSWhereClause : NSObject

/**
 * 
 */
@property(nonatomic,strong) OSWhereClause* linkedClause;

/**
 * Specifies the method of combining the linked clause with the current clause
 */
@property(nonatomic,assign) OSCombineOperator linkedClauseCombineOperator;

/**
 * The field name that this where clause relates to.
 */
@property(nonatomic,strong) NSString* fieldName;

/**
 * Specifies the method of combining different values within the values array
 */
@property(nonatomic,assign) OSCombineOperator valueCombineOperator;

/**
 * A list of values that will combined using 
 */
@property(nonatomic,strong) NSArray* values;

/**
 * Describes the type of string comparison
 */
@property(nonatomic,assign) OSComparisonMode comparisonMode;




-(id)initWithFieldName:(NSString*)fieldName;

@end
