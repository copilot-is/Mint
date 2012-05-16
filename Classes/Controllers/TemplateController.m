//
//  TemplateController.m
//  Mint
//
//  Created by 马 军 on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TemplateController.h"

@implementation TemplateController

-(id)init{
	if (self=[super init]) {
        templateEngine = [[TemplateEngine alloc] init];
	}
	return self;
}

- (NSString*)getThemes
{
    return @"default";
}

- (NSURL*)getBaseURL
{
    NSString *basePath = [[[NSString alloc] initWithFormat:@"%@%@%@",[[NSBundle mainBundle] resourcePath],@"/themes/",[self getThemes]] autorelease];
    return [NSURL fileURLWithPath:basePath];
}

- (NSString*)getMain
{
    NSString *mainTemplate = [[NSBundle mainBundle] pathForResource:@"main" 
                                                             ofType:@"html" 
                                                        inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:mainTemplate withContext:nil];
    return templateString;
}

- (NSString*)getPreview
{
    NSString *previewTemplate = [[NSBundle mainBundle] pathForResource:@"preview" 
                                                             ofType:@"html" 
                                                        inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:previewTemplate withContext:nil];
    return templateString;
}

- (NSString*)getStatuses:(NSDictionary*)dic
{
    NSString *statusesTemplate = [[NSBundle mainBundle] pathForResource:@"statuses" 
                                                                 ofType:@"html" 
                                                            inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:statusesTemplate withContext:dic];
    return templateString;
}

- (NSString*)getMentions:(NSDictionary*)dic
{
    NSString *mentionsTemplate =  [[NSBundle mainBundle] pathForResource:@"mentions" 
                                                                         ofType:@"html" 
                                                                    inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:mentionsTemplate withContext:dic];
    return templateString;
}

- (NSString*)getComments:(NSDictionary*)dic
{ 
    NSString *commentsTemplate =  [[NSBundle mainBundle] pathForResource:@"comments" 
                                                                          ofType:@"html" 
                                                                     inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:commentsTemplate withContext:dic];
    return templateString;
}

- (NSString*)getFavorites:(NSDictionary *)dic
{
    NSString *favoritesTemplate =  [[NSBundle mainBundle] pathForResource:@"favorites" 
                                                                  ofType:@"html" 
                                                             inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:favoritesTemplate withContext:dic];
    return templateString;
}

- (NSString*)getStatusesDetails:(NSDictionary*)dic
{    
    NSString *statusesDetailsTemplate =  [[NSBundle mainBundle] pathForResource:@"statuses_details" 
                                                                         ofType:@"html" 
                                                                    inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:statusesDetailsTemplate withContext:dic];
    return templateString;
}

- (NSString*)getStatusesComments:(NSDictionary*)dic
{
    NSString *statusesCommentsTemplate =  [[NSBundle mainBundle] pathForResource:@"statuses_comments" 
                                                                  ofType:@"html" 
                                                             inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:statusesCommentsTemplate withContext:dic];
    return templateString;
}

- (NSString*)getUserStatuses:(NSDictionary*)dic
{
    NSString *userTemplate =  [[NSBundle mainBundle] pathForResource:@"user_statuses" 
                                                              ofType:@"html" 
                                                         inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:userTemplate withContext:dic];
    return templateString;
}

- (NSString*)getUserInfo:(NSDictionary*)dic
{
    NSString *userInfoTemplate =  [[NSBundle mainBundle] pathForResource:@"user_info" 
                                                                  ofType:@"html" 
                                                             inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:userInfoTemplate withContext:dic];
    return templateString;
}

- (NSString*)getUserList:(NSDictionary*)dic
{
    NSString *userListTemplate =  [[NSBundle mainBundle] pathForResource:@"user_list" 
                                                                  ofType:@"html" 
                                                             inDirectory:[NSString stringWithFormat:@"themes/%@",[self getThemes]]];
    NSString *templateString = [templateEngine renderTemplateFileAtPath:userListTemplate withContext:dic];
    return templateString;
}

- (void)dealloc
{
    [templateEngine release];
    [super dealloc];
}

@end