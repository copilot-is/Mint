//
//  WeiboGlobal.h
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

typedef enum {
	Home=0,
	Mentions,
	Comments,
	Favorites
}TimelineType;

#define OAuthConsumerKey @""
#define OAuthConsumerSecret @""

//Status Finished Notification,Tell webview and mainWindow to update
#define ReloadTimelineNotification @"ReloadTimelineNotification"
#define ShowLoadingPageNotification @"ShowLoadingPageNotification"
#define AccountVerifiedNotification @"AccountVerifiedNotification"

//HTTP Connection Notification
#define HTTPConnectionErrorNotification @"HTTPConnectionErrorNotification"
#define HTTPConnectionStartNotification @"HTTPConnectionStartNotification"
#define HTTPConnectionFinishedNotification @"HTTPConnectionFinishedNotification"


//URL Handler Notification
#define StartLoadOlderTimelineNotification @"StartLoadOlderTimelineNotification"
#define DidClickTimelineNotification @"DidClickTimelineNotification"
#define DidLoadOlderTimelineNotification @"DidLoadOlderTimelineNotification"
#define DidLoadNewerTimelineNotification @"DidLoadNewerTimelineNotification"
#define DidLoadTimelineWithPageNotification @"DidLoadTimelineWithPageNotification"
#define GetUserNotification @"GetUserNotification"

//Other Notification
#define UpdateTimelineSegmentedControlNotification @"UpdateTimelineSegmentedControlNotification"

#define SaveScrollPositionNotification @"SaveScrollPositionNotification"

#define DidPostStatusNotification @"DidPostStatusNotification"
#define DidGetUserNotification @"DidGetUserNotification"
#define DisplayImageNotification @"DisplayImageNotification"
#define GetFriendsNotification @"GetFriendsNotification"
#define DidGetFriendsNotification @"DidGetFriendsNotification"
#define GetStatusCommentsNotification @"GetStatusCommentsNotification"
#define DidGetStatusCommentsNotification @"DidGetStatusCommentsNotification"
#define DidGetMessageSentNotification @"DidGetMessageSentNotification"
#define ShowStatusCommentsNotification @"ShowStatusCommentsNotification"
#define ShowStatusNotification @"ShowStatusNotification"
#define DidShowStatusNotification @"DidShowStatusNotification"
#define DidGetDirectMessageNotification @"DidGetDirectMessageNotification"

#define ReplyNotification @"ReplyNotification"
#define RepostNotification @"RepostNotification"
#define SendMessageNotification @"SendMessageNotification"
#define PathChangedNotification @"PathChangedNotification"

#define ShowTipMessageNotification @"ShowTipMessageNotification"

#define DidGetUserTimelineNotification @"DidGetUserTimelineNotification"
#define DidGetFollowersNotification @"DidGetFollowersNotification"

#define DidExpandShortURLNotification @"DidExpandShortURLNotification"

// 通知 Notification
#define NewNotification @"NewNotification"
//#define NewMentionsNotification @"NewMentionsNotification"
//#define NewCommentsNotification @"NewCommentsNotification"
//#define NewFollowerNotification @"NewFollowerNotification"
