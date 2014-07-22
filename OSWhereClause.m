//
//  OSDataLayerRequestWhereClause.m
//  Ocasta Studios
//
//  Created by Chris Birch on 22/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import "OSWhereClause.h"

@implementation OSWhereClause

-(id)initWithFieldName:(NSString*)fieldName
{
    if (self = [super init])
    {
        _fieldName = fieldName;
    }
    
    return self;
}

-(NSString *)description
{
    return [self describeNode:self];
}

-(NSString*)stringFromCombineEnumValue:(OSCombineOperator)operator
{
    NSString* valueCombinationOperator=@"OR";
    
    if (operator == OSCombineOperatorAND)
        valueCombinationOperator=@"AND";
    
    return valueCombinationOperator;
}

-(NSString*)describeNode:(OSWhereClause*)clause
{
        
    if (clause)
    {
        //Build up textual description of the where clause
        NSMutableString *str = [[NSMutableString alloc] init];
        

    
        NSString* valueCombinationOperator=[self stringFromCombineEnumValue:clause.valueCombineOperator];
        
        for (int i=0;i< clause.values.count;i++)
        {
            NSString* value = [clause.values objectAtIndex:i];
            [str appendFormat:@"%@ == '%@'",clause.fieldName,value];
            
            if (i+1 < clause.values.count)
                [str appendFormat:@" %@ " ,valueCombinationOperator];
        }
        
        
        NSString* nextNode = [self describeNode:clause.linkedClause];
        
        if (nextNode)
        {
            NSString* linkedCombineOperator=[self stringFromCombineEnumValue:clause.linkedClauseCombineOperator];
            [str appendFormat:@"%@\n%@\n(%@)",str,linkedCombineOperator, nextNode];
        }
        
        return str;
    }
    
    return nil;
    
}


@end
