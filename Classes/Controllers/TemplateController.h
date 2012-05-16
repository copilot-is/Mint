//
//  TemplateController.h
//  Mint
//
//  Created by 马 军 on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TemplateEngine.h"

@interface TemplateController : NSObject {
    TemplateEngine *templateEngine;
}

- (id)init;
- (NSURL*)getBaseURL;
- (NSString*)getMain;
- (NSString*)getPreview;
- (NSString*)getStatuses:(NSDictionary*)dic;
- (NSString*)getComments:(NSDictionary*)dic;
- (NSString*)getMentions:(NSDictionary*)dic;
- (NSString*)getFavorites:(NSDictionary*)dic;
- (NSString*)getStatusesDetails:(NSDictionary*)dic;
- (NSString*)getStatusesComments:(NSDictionary*)dic;
- (NSString*)getUserStatuses:(NSDictionary*)dic;
- (NSString*)getUserInfo:(NSDictionary*)dic;
- (NSString*)getUserList:(NSDictionary*)dic;

@end
