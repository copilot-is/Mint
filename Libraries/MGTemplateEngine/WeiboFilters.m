//
//  WeiboFilters.m
//  Bubble
//
//  Created by Luke on 10/31/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboFilters.h"
#import "NSDateAdditions.h"
#import "AccountController.h"

#define WEIBO_DATE_FORMAT		@"weibo_date_format"
#define WEIBO_CONTENT_FORMAT    @"weibo_content_format"
#define WEIBO_CONTENT_TRUNCATE  @"weibo_content_truncate"
#define WEIBO_BIG_PROFILE_IMAGE @"weibo_big_image"
#define WEIBO_DELETE_STATUS     @"weibo_delete_status"

#define AT_STRING               @"(@)([\\x{4e00}-\\x{9fa5}A-Za-z0-9_\\-]+)"
#define AT_REPLACE_STRING       @"<a href='weibo://user?fetch_with=screen_name&value=$2' target='_blank'>$1$2</a> "
#define TOPIC_STRING            @"#(.+?)#"
#define TOPIC_REPLACE_STRING    @"<a href=\"http://weibo.com/k/$1\" target=\"_blank\">#$1#</a>"

#define EMOTIONS_STRING         @"\\[(.+?)\\]"

#define LINK_STRING             @"(http://t.cn/[a-zA-Z0-9]+)"
#define LINK_REPLACE_STRING     @"<a href=\"$1\" target=\"_blank\">$1</a>"

const int TRUNCATE_LENGTH = 140;

@implementation WeiboFilters

- (NSArray *)filters{
	return [NSArray arrayWithObjects:WEIBO_DATE_FORMAT, WEIBO_CONTENT_FORMAT,WEIBO_CONTENT_TRUNCATE,WEIBO_BIG_PROFILE_IMAGE,WEIBO_DELETE_STATUS,nil];
}

- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value{
    
    if ([filter isEqualToString:WEIBO_DATE_FORMAT]) {
        NSString *dateString = [NSString stringWithFormat:@"%@",value];
        
        struct tm created;
        time_t createdAt;
        time_t now;
        time(&now);
        
        if (dateString) {
            if (strptime([dateString UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
                strptime([dateString UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
            }
            createdAt = mktime(&created);
        }
        
        int distance = (int)difftime(now, createdAt);
        
        if (distance < 0) distance = 0;
        
        if (distance < 60) {
            return [NSString stringWithFormat:@"%d秒前",distance];
        }
        else if (distance < 60 * 60) {  
            distance = distance / 60;
            return [NSString stringWithFormat:@"%d分钟前",distance];
        }  
        else if (distance < 60 * 60 * 24) {
            distance = distance / 60 / 60;
            return [NSString stringWithFormat:@"%d小时前",distance];
        }
        else if (distance < 60 * 60 * 24 * 7) {
            distance = distance / 60 / 60 / 24;
            return [NSString stringWithFormat:@"%d天前",distance];
        }
        else if (distance < 60 * 60 * 24 * 7 * 4) {
            distance = distance / 60 / 60 / 24 / 7;
            return [NSString stringWithFormat:@"%d周前",distance];
        }
        else {
            static NSDateFormatter *dateFormatter = nil;
            if (dateFormatter == nil) {
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            }
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
            return [dateFormatter stringFromDate:date];
        }
	}
	if ([filter isEqualToString:WEIBO_CONTENT_FORMAT]) {
		NSMutableString *mutableContent=[NSMutableString stringWithFormat:@"%@",value];
		[mutableContent replaceOccurrencesOfRegex:LINK_STRING withString:LINK_REPLACE_STRING];
		[mutableContent replaceOccurrencesOfRegex:AT_STRING withString:AT_REPLACE_STRING];
		[mutableContent replaceOccurrencesOfRegex:TOPIC_STRING withString:TOPIC_REPLACE_STRING];
        
        // 表情处理开始
        NSString *emotDir = [NSString stringWithFormat:@"%@/emotions",[[NSBundle mainBundle] resourcePath]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *fileList =  [fileManager contentsOfDirectoryAtPath:emotDir error:&error];
        BOOL isDir = NO;
        
        for (NSString *file in fileList) {
            NSString *path = [emotDir stringByAppendingPathComponent:file];
            [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
            if (isDir) {
                //NSLog(@"%@",file);
                for(NSString *match in [mutableContent componentsMatchedByRegex:EMOTIONS_STRING]) {
                    NSString *emotName = [[match stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
                    
                    if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/%@",emotDir,file,emotName]]) {
                        [mutableContent replaceOccurrencesOfRegex:[NSString stringWithFormat:@"\\[%@\\]",emotName] withString:[NSString stringWithFormat:@"<img src=\"%@/%@/%@\" />",emotDir,file,emotName]];
                        //NSLog(@"%@",[NSString stringWithFormat:@"<img src=\"%@/%@/%@\" />",emotDir,file,emotName]);
                        return mutableContent;
                    }
                }
            }
            isDir = NO;
        }
        // 表情处理结束
        
		return mutableContent;
	}
	
	if ([filter isEqualToString:WEIBO_CONTENT_TRUNCATE]) {
		NSString *content=[NSString stringWithFormat:@"%@",value];
		int stringLength=content.length;
		int length=stringLength<TRUNCATE_LENGTH?stringLength:TRUNCATE_LENGTH;
		return [[NSString stringWithFormat:@"%@...",[content substringToIndex:length]] urlEncoded];
	}
	
	if ([filter isEqualToString:WEIBO_BIG_PROFILE_IMAGE]) {
		NSString *content=[NSString stringWithFormat:@"%@",value];
		return [content stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
	}

    if ([filter isEqualToString:WEIBO_DELETE_STATUS]) {
        
        if (value == nil || ![value isKindOfClass:[NSDictionary class]]) {
            return @"";
        }
        
		NSDictionary *status = (NSDictionary*)value;
        NSString *userid = [NSString stringWithFormat:@"%@",[[status objectForKey:@"user"] objectForKey:@"id"]];
        NSString *statusid = [NSString stringWithFormat:@"%@",[status objectForKey:@"id"]];
        
        if ([userid isEqualToString:[[AccountController instance] currentAccount].userID]) {
            return [NSString stringWithFormat:@"<a href='weibo://destroy?id=%@' class='delete-action' title='删除'><span><i></i><b>删除</b></span></a>",statusid];
        }
        return @"";
	}
    
	return value;
}

@end
