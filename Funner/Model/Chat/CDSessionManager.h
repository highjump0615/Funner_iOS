//
//  CDSessionManager.h
//  AVOSChatDemo
//
//  Created by Qihe Bian on 7/29/14.
//  Copyright (c) 2014 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

typedef enum : NSUInteger {
    CDChatRoomTypeSingle = 1,
    CDChatRoomTypeGroup,
} CDChatRoomType;

@interface CDSessionManager : NSObject <AVSessionDelegate, AVSignatureDelegate, AVGroupDelegate>
+ (instancetype)sharedInstance;
//- (void)startSession;
//- (void)addSession:(AVSession *)session;
//- (NSArray *)sessions;
- (NSArray *)chatRooms;

- (void)addChatWithPeerId:(NSString *)peerId;
- (void)unwatchPeerId:(NSString *)peerId;

- (AVGroup *)joinGroup:(NSString *)groupId;
- (void)startNewGroup:(AVGroupResultBlock)callback;
- (void)sendMessage:(NSString *)message toPeerId:(NSString *)peerId blogId:(NSString *)strBlogId;
- (void)sendMessage:(NSString *)message toGroup:(NSString *)groupId;
- (void)sendAttachment:(AVObject *)object toPeerId:(NSString *)peerId blogId:(NSString *)strBlogId width:(double)dWidth height:(double)dHeight;
- (void)sendAttachment:(AVObject *)object toGroup:(NSString *)groupId;

- (NSArray *)getMessagesForPeerId:(NSString *)peerId blogId:(NSString *)strBlogId;
- (void)deleteMessagesForPeerId:(NSString *)peerId;
- (void)deleteMessagesForBlogId:(NSString *)blogId;

- (NSDictionary *)getLatestMessageForPeerId:(NSString *)peerId;
- (NSArray *)getLatestMessagesForPeerId;

- (NSInteger)getUnreadCountForPeerId:(NSString *)peerId;
- (void)setUnreadToReadForPeerId:(NSString *)peerId;

- (NSArray *)getMessagesForGroup:(NSString *)groupId;
- (void)getHistoryMessagesForPeerId:(NSString *)peerId callback:(AVArrayResultBlock)callback;
- (void)getHistoryMessagesForGroup:(NSString *)groupId callback:(AVArrayResultBlock)callback;
- (void)clearData;
- (void)removeSession;
@end
