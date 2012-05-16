//
//  WeiboConnector.m
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboConnector.h"

#pragma mark Weibo Private Interface
@interface WeiboConnector(Private)
- (NSString*)_sendRequestWithMethod:(NSString*) method 
                            baseurl:(NSString*) baseurl
                               path:(NSString*) path
                    queryParameters:(NSDictionary *) params
                               body:(NSMutableData*) body
                   completionTarget:(id)target
                   completionAction:(SEL)action;

- (NSString*) _sendRequest:(NSURLRequest*)request
          completionTarget:(id)target
          completionAction:(SEL)action;

- (void)_parseDataForConnection:(WeiboURLConnection*)connection;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
@end

@implementation WeiboConnector

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
{
    if ((self = [super init])) {
        consumer = [[OAConsumer alloc] initWithKey:OAuthConsumerKey secret:OAuthConsumerSecret];
        accessToken = [[OAToken alloc] initWithKey:aKey secret:aSecret];
        multipartBoundary = @"JOHN&JIE&20110327";
    }
    return self;
}

#pragma mark Sina Weibo API Interface Implementation
-(NSString *) verifyAccountWithParameters:(NSMutableDictionary*)params 
						 completionTarget:(id)target  
						 completionAction:(SEL)action{
	NSString *path = @"account/verify_credentials.json";
	return [self _sendRequestWithMethod:nil
								baseurl:WEIBO_BASE_URL 
								   path:path
						queryParameters:params
								   body:nil 
                       completionTarget:target
					   completionAction:action];
}

-(NSString *)checkUnreadWithParameters:(NSMutableDictionary*)params 
					  completionTarget:(id)target  
					  completionAction:(SEL)action{
	NSString *path=@"statuses/unread.json";
	return [self _sendRequestWithMethod:nil
								baseurl:WEIBO_BASE_URL 
								   path:path
						queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}

-(NSString *) getHomeTimelineWithParameters:(NSMutableDictionary*)params
						   completionTarget:(id)target
						   completionAction:(SEL)action
{
	NSString *path=[NSString stringWithString:@"statuses/home_timeline.json"];
	return [self _sendRequestWithMethod:nil 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *) getMentionsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/mentions.json"];
    
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:target
					   completionAction:action];	
}

-(NSString *)getUserTimelineWithParameters:(NSMutableDictionary*)params
						  completionTarget:(id)target
						  completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/user_timeline.json"];
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}

-(NSString *)getFollowersWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/followers.json"];
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
	
}

-(NSString *) getCommentsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/comments_timeline.json"];
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}


-(NSString *) getFavoritesWithParameters:(NSMutableDictionary*)params
						completionTarget:(id)target
						completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"favorites.json"];
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}

-(NSString *) replyWithParameters:(NSMutableDictionary*)params
                 completionTarget:(id)target
                 completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/comment.json"];
	NSMutableData *postBody = [NSMutableData data];
	NSString *comment=[params objectForKey:@"comment"];
	NSString *sid=[params objectForKey:@"id"];
	NSString *cid=[params objectForKey:@"cid"];
	if (cid) {
		[postBody appendData:[[NSString stringWithFormat:@"comment=%@&id=%@&cid=%@",[comment encodeAsURIComponent],sid,cid]dataUsingEncoding:NSUTF8StringEncoding]];
	}else {
		[postBody appendData:[[NSString stringWithFormat:@"comment=%@&id=%@",[comment encodeAsURIComponent],sid]dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
    
}

-(NSString *) repostWithParamters:(NSMutableDictionary*)params
				 completionTarget:(id)target
				 completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/repost.json"];
	NSMutableData *postBody = [NSMutableData data];
	NSString *status=[params objectForKey:@"status"];
	NSString *sid=[params objectForKey:@"id"];
    NSString *isComment=[params objectForKey:@"isComment"];
	[postBody appendData:[[NSString stringWithFormat:@"status=%@&id=%@&is_comment=%@",[status encodeAsURIComponent],sid,isComment]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
}

-(NSString *) destroyStatusWithParameters:(NSMutableDictionary*)params
                         completionTarget:(id)target
                         completionAction:(SEL)action{
    NSString *path = [NSString stringWithFormat:@"statuses/destroy/:id.json"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"id=%@",[params objectForKey:@"id"]]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *) createFriendshipsWithParameters:(NSMutableDictionary*)params
                             completionTarget:(id)target
                             completionAction:(SEL)action{
    NSString *path = [NSString stringWithFormat:@"friendships/create/:id.json"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"id=%@",[params objectForKey:@"id"]]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *)shortenShortURLWithParameters:(NSMutableDictionary*)params
                          completionTarget:(id)target
                          completionAction:(SEL)action{
    NSString *path = [NSString stringWithFormat:@"short_url/shorten.json"];
	return [self _sendRequestWithMethod:nil 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *)expandShortURLWithParameters:(NSMutableDictionary*)params
                          completionTarget:(id)target
                          completionAction:(SEL)action{
    NSString *path = [NSString stringWithFormat:@"short_url/expand.json"];
	return [self _sendRequestWithMethod:nil 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *) updateWithStatus:(NSString*)status				  
			  completionTarget:(id)target
			  completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/update.json"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"status=%@",[status encodeAsURIComponent]]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
}

-(NSString*) updateWithStatus:(NSString *)status 
						image:(NSData*)imageData
					imageName:(NSString*)imageName
			 completionTarget:(id)target 
			 completionAction:(SEL)action{
    
	NSString *path=[NSString stringWithString:@"statuses/upload.json"];
    
    NSString* urlString = [NSURL urlStringWithBaseurl:WEIBO_BASE_URL path:path queryParameters:nil];
    
    NSMutableData * body = [NSMutableData data];
    
	//fill the post body data
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                             timeoutInterval:60.0] autorelease];
	
	NSString * timestamp = [self _generateTimestamp];
	NSString * nonce = [self _generateNonce];
	NSMutableArray *par = [[NSMutableArray alloc]init];
	
	[par addObject:[[OARequestParameter requestParameterWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
	[par addObject:[[OARequestParameter requestParameterWithName:@"oauth_signature_method" value:@"HMAC-SHA1"] URLEncodedNameValuePair]];
	[par addObject:[[OARequestParameter requestParameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
	[par addObject:[[OARequestParameter requestParameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
	[par addObject:[[OARequestParameter requestParameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
	[par addObject:[[OARequestParameter requestParameterWithName:@"oauth_token" value:accessToken.key] URLEncodedNameValuePair]];
    [par addObject:[[OARequestParameter requestParameterWithName:@"status" value:[status encodeAsURIComponent]] URLEncodedNameValuePair]];
    
	NSArray *sortedPairs = [par sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
    
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@",
                            @"POST",
                            [urlString URLEncodedString],
                            [normalizedRequestParameters URLEncodedString]];
	
	NSString *signature = [[[OAHMAC_SHA1SignatureProvider alloc] init] signClearText:baseString
                                                                          withSecret:[NSString stringWithFormat:@"%@&%@", [consumer.secret URLEncodedString], [accessToken.secret URLEncodedString]]];
	NSString *oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [accessToken.key URLEncodedString]];
    
	NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"%@\", oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"%@",
							 @"",
                             [OAuthConsumerKey URLEncodedString],
                             oauthToken,
                             [@"HMAC-SHA1" URLEncodedString],
                             [signature URLEncodedString],
                             timestamp,
                             nonce,
							 @""];
    
	NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",multipartBoundary];
    
	[request setHTTPMethod:@"POST"];
	[request setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // status
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"status\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[status encodeAsURIComponent] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // image
    NSString *imgExt = (NSString*)[[imageName componentsSeparatedByString:@"."] lastObject];
	if ([imgExt isEqualToString:@"jpg"]) {
		imgExt = @"jpeg";
	}
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pic\"; filename=\"%@\"\r\n",imageName]dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-type: image/%@\r\n",imgExt] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:imageData];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:body];
    
    return [self _sendRequest:request 				  
			 completionTarget:(id)target
			 completionAction:(SEL)action];
	
}

-(NSString *) getUserWithParameters:(NSMutableDictionary*)params 
                   completionTarget:(id)target
                   completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"users/show.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}

-(NSString *) getFriendsWithParameters:(NSMutableDictionary*)params 
                      completionTarget:(id)target
                      completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/friends.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}
-(NSString *) getStatusCommentsWithParameters:(NSMutableDictionary*)params 
                             completionTarget:(id)target
                             completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/comments.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}

-(NSString *) resetCountWithParameters:(NSMutableDictionary*)params 
					  completionTarget:(id)target
					  completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/reset_count.json"];
	NSMutableData *postBody = [NSMutableData data];
	NSString *type=[params objectForKey:@"type"];
	[postBody appendData:[[NSString stringWithFormat:@"type=%@",type]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
}

-(NSString *) showStatusWithParameters:(NSMutableDictionary*)params 
                      completionTarget:(id)target
                      completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/show/:id.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *) createFavoritesWithParameters:(NSMutableDictionary*)params
                           completionTarget:(id)target
                           completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"favorites/create.json"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"id=%@",[params objectForKey:@"id"]]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *) destroyFavoritesWithParameters:(NSMutableDictionary*)params
                            completionTarget:(id)target
                            completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"favorites/destroy.json"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"id=%@",[params objectForKey:@"id"]]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

#pragma mark Request Send Method
-(NSString*)_sendRequestWithMethod:(NSString*)method 
						   baseurl:(NSString*)baseurl
							  path:(NSString*)path
				   queryParameters:(NSMutableDictionary*)params
							  body:(NSMutableData*)body
				  completionTarget:(id)target
				  completionAction:(SEL)action{
	
	NSString* urlString = [NSURL urlStringWithBaseurl:baseurl path:path queryParameters:params];
    
    // OAuth
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                    consumer:consumer
                                                                       token:accessToken
                                                                       realm:nil
                                                           signatureProvider:nil] autorelease];
    [request setTimeoutInterval:60];
	
	if(method && [method isEqualToString:@"POST"]){
		[request setHTTPMethod:method];
		if(body){
			[request setHTTPBody:body]; 
		}
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
    
    [request prepare];
    
	return [self _sendRequest:request 				  
			 completionTarget:(id)target
			 completionAction:(SEL)action];
}

-(NSString*) _sendRequest:(NSMutableURLRequest*)request 				  
		 completionTarget:(id)target
		 completionAction:(SEL)action{
    
	WeiboURLConnection * connection = [[[WeiboURLConnection alloc] 
                                        initWithRequest:request delegate:self] autorelease];
	if (!connection) {
        return nil;
    } else {
		[[NSNotificationCenter defaultCenter] postNotificationName:HTTPConnectionStartNotification 
															object:nil];
		
		connection.completionTarget = target;
		connection.completionAction = action;
        [_connections setObject:connection forKey:[connection identifier]];
    }
	return [connection identifier];
	
}

- (NSString *)_generateTimestamp 
{
    return [[[NSString stringWithFormat:@"%d", time(NULL)] retain] autorelease];
}

- (NSString *)_generateNonce 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
	return [(NSString *)string autorelease];
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(WeiboURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[connection resetDataLength];
    
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [resp statusCode];
	if (statusCode >= 400) {
		[_connections removeObjectForKey:connection.identifier];
		NSError *error = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:HTTPConnectionErrorNotification
															object:error];
	}
}

- (void)connection:(WeiboURLConnection *)connection didReceiveData:(NSData *)data
{
    [connection appendData:data];
}

- (void)connectionDidFinishLoading:(WeiboURLConnection *)connection
{
	[[NSNotificationCenter defaultCenter]postNotificationName:HTTPConnectionFinishedNotification object:nil];
	
	NSData *receivedData = connection.data;
    
	if(receivedData){
		[self _parseDataForConnection:connection];
	}
    
    [_connections removeObjectForKey:connection.identifier];
}

-(void)connection:(WeiboURLConnection *)connection didFailWithError:(NSError*)error{
	[_connections removeObjectForKey:connection.identifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:HTTPConnectionErrorNotification
														object:error];
}

#pragma mark Parse Data and perform target-action
-(void)_parseDataForConnection:(WeiboURLConnection*)connection{
	NSData *jsonData = [[connection.data copy] autorelease];
	NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    //NSLog(@"json: %@",jsonString);
	[connection.completionTarget performSelector:connection.completionAction 
									  withObject:[jsonString JSONValue]];
}

- (void)dealloc
{
    [_connections release];
    [multipartBoundary release];
    [accessToken release];
    [consumer release];
    [super dealloc];
}

@end
