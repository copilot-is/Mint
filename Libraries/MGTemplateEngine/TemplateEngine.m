//
//  TemplateEngine.m
//  Mint
//
//  Created by john on 10/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TemplateEngine.h"


@implementation TemplateEngine
-(id)init{
	if (self=[super init]) {
		engine=[[MGTemplateEngine templateEngine] retain];
		[engine setDelegate:self];
		[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
		[engine loadFilter:[[[WeiboFilters alloc] init] autorelease] ];
	}
	return self;
}

-(NSString*)renderTemplateFileAtPath:(NSString*)templatePath withContext:(NSDictionary*)context{
	return [engine processTemplateInFileAtPath:templatePath
								withVariables:context];
}

-(NSString*)renderTemplate:(NSString*)template withContext:(NSDictionary*)context{
	return [engine processTemplate:template withVariables:context];
}
// ****************************************************************
// 
// Methods below are all optional MGTemplateEngineDelegate methods.
// 
// ****************************************************************


- (void)templateEngine:(MGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo
{
	//NSLog(@"Started block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo
{
	//NSLog(@"Ended block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngineFinishedProcessingTemplate:(MGTemplateEngine *)engine
{
	//NSLog(@"Finished processing template.");
}


- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;
{
	NSLog(@"Template error: %@", error);
}


@end
