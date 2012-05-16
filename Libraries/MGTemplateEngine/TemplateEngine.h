//
//  TemplateEngine.h
//  Mint
//
//  Created by john on 10/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "WeiboFilters.h"
@interface TemplateEngine : NSObject<MGTemplateEngineDelegate> {
	MGTemplateEngine *engine;
}
-(id)init;
-(NSString*)renderTemplateFileAtPath:(NSString*)templatePath withContext:(NSDictionary*)context;
-(NSString*)renderTemplate:(NSString*)template withContext:(NSDictionary*)context;
@end
