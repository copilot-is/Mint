//
//  NSURLAdditions.m
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSURLAdditions.h"


@implementation NSURL(Additions)
+ (NSString*) urlStringWithBaseurl:(NSString*) baseurl path:(NSString*)path queryParameters:(NSDictionary *) params
{
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
	if(path){
		[str appendString:path];
	}

    if (params) {
        NSUInteger i;
        NSArray *names = [params allKeys];
        for (i = 0; i < [names count]; i++) {
            if (i == 0) {
                [str appendString:@"?"];
            } else if (i > 0) {
                [str appendString:@"&"];
            }
            NSString *name = [names objectAtIndex:i];
			NSString *value =[params objectForKey:name];
            //NSLog(@"name:%@, value:%@",name,value);
            [str appendString:[NSString stringWithFormat:@"%@=%@", 
							   name, [self encodeString:value]]];
        }
    }
    
    return [NSString stringWithFormat:@"%@/%@",baseurl,str];
}

+ (NSString *)encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
																		   (CFStringRef)string, 
																		   NULL, 
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}
@end
