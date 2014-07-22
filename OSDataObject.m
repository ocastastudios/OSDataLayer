//
//  OSDataObject.m
//  Ocasta Studios
//
//  Created by Chris Birch on 18/02/2013.
//  Modified by:
//  Date:
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import "OSDataObject.h"
#import "OSWhereClause.h"

@implementation OSDataObject


-(id)initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [super init])
    {
        _dictionary = dictionary;
        _userData = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(id)init
{
    [NSException raise:@"Dont use this init!" format:@"Use initWithDictionary instead"];
    return nil;
}

-(BOOL)expression:(NSString*) expression matchesString: (NSString*) string withComparisonMode: (OSComparisonMode)compareMode
{
    if (compareMode == OSComparisonModeLiteral)
    {
        return [expression isEqualToString:string];
    }
    else if (compareMode == OSComparisonModeRegEx)
    {
        NSError* error=nil;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                            options:0
                                                              range:NSMakeRange(0, [string length])];
        
        return numberOfMatches > 0;
    }
    
    return NO;
}

-(BOOL)matchesWhereClause:(OSWhereClause*)clause
{
    if (clause)
    {
        //Do we match this level of clause?
        NSString* fieldName = clause.fieldName;
        
        if (!fieldName || [fieldName isEqualToString:@""])
        {
            //No field name has been supplied
            [NSException raise:@"Where Clause error" format:@"No fieldName has been supplied"];
        }
        else
        {
            
            OSWhereClause* linkedClause = clause.linkedClause;
            
            BOOL matches=NO;
            
            //Check that we have been supplied some values.
            if (!clause.values || clause.values.count == 0)
            {
                //we havent so we assume that this matches
                matches = YES;
            }
            else
            {
                //Search through all data objects in memory selecting those
                //that match the criteria specified by the where clause dictionary
                for (NSString* value in clause.values)
                {
                    //First check if data object contains key
                    NSString* dataObjectFieldValue = [_dictionary valueForKey:fieldName];
                    
                    
                    if (![self expression:value matchesString:dataObjectFieldValue withComparisonMode:clause.comparisonMode])
                    {
                        
                        
                        if (clause.valueCombineOperator == OSCombineOperatorAND)
                        {
                            matches = NO;
                            //no point coninuing because this where parameter didnt match
                            break;
                        }
                        //else keep going

                    }
                    else
                    {
                        //this part matched!
                     
                        matches = YES;
                        
                        //now check if we need to eval the rest of the clause
                        if (clause.valueCombineOperator == OSCombineOperatorOR)
                            //a part of the clause matched and thats enough because they are combined using OR
                            break;

                        
                    }
                    //else carry on to see if match the next
                }
            }
            
            if (!matches)
            {
                //This dataobject does not meet the criteria so no point continuing to other clauses
                if (clause.linkedClauseCombineOperator == OSCombineOperatorAND)
                    return NO;
            }
            
            //Do we need to evaluate linked clause(s)?
            if (linkedClause)
            {
                BOOL clauseMatches =[self matchesWhereClause:linkedClause];
                
                //How should the linked clause be combined
                if (clause.linkedClauseCombineOperator == OSCombineOperatorAND)
                    return matches && clauseMatches;
                else
                    return matches || clauseMatches;
            }
            else
                return matches;
        }
    }
    else
    {
        //There is no where clause so we match!
        return YES;
    }
}


-(NSString *)description
{
    return [[NSString alloc] initWithFormat:@"DataObject\n%@",self.dictionary];
}

/**
 * Awaiting implementation:
 * Provide bodies for the other method signatatures in the header file as well!
 */


+(float)valueAsFloat:(NSString*)dictionaryKey fromDictionary:(NSDictionary*)dictionary
{
    NSNumber* obj = [dictionary objectForKey:dictionaryKey];
    
    if ((NSNull *)obj == [NSNull null]) {
        return 0;
    }

    if (obj)
    {
        return [obj floatValue];
    }
    else
    {
        NSLog(@"No value for key: %@ stored in dictionary: \n%@",dictionaryKey,dictionary);
        return 0;
    }
}


+(int)valueAsInt:(NSString*)dictionaryKey fromDictionary:(NSDictionary*)dictionary
{
    NSNumber* obj = [dictionary objectForKey:dictionaryKey];
    
    if (obj)
    {
        return [obj intValue];
    }
    else
    {
        NSLog(@"No value for key: %@ stored in dictionary: \n%@",dictionaryKey,dictionary);
        return 0;
    }
}


+(BOOL)valueAsBOOL:(NSString *)dictionaryKey fromDictionary:(NSDictionary *)dictionary
{
    NSNumber* obj = [dictionary objectForKey:dictionaryKey];
    
    if (obj)
    {
        return [obj boolValue];
    }
    else
    {
        NSLog(@"No value for key: %@ stored in dictionary: \n%@",dictionaryKey,dictionary);
        return NO;
    }
}


#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    // Copy NSObject subclasses
    NSDictionary* dictionary = [_dictionary copyWithZone:zone];
    
    
    id copy = [[OSDataObject alloc] initWithDictionary:dictionary];
    
    
    return copy;
}


@end
