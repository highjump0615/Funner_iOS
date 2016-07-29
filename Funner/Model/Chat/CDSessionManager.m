//
//  CDSessionManager.m
//  AVOSChatDemo
//
//  Created by Qihe Bian on 7/29/14.
//  Copyright (c) 2014 AVOS. All rights reserved.
//

#import "CDSessionManager.h"
#import "FMDB.h"
#import "CommonDefine.h"

#import "UserData.h"

@interface CDSessionManager () {
    FMDatabase *_database;
    AVSession *_session;
    NSMutableArray *_chatRooms;
}

@end

static id instance = nil;
static BOOL initialized = NO;

@implementation CDSessionManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    if (!initialized) {
        [instance commonInit];
    }
    return instance;
}

- (NSString *)databasePath {
    static NSString *databasePath = nil;
    if (!databasePath) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        databasePath = [cacheDirectory stringByAppendingPathComponent:@"chat.db"];
    }
    return databasePath;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init {
    if ((self = [super init])) {
        _chatRooms = [[NSMutableArray alloc] init];
        
        AVSession *session = [[AVSession alloc] init];
        session.sessionDelegate = self;
        session.signatureDelegate = self;
        _session = session;

        NSLog(@"database path:%@", [self databasePath]);
        _database = [FMDatabase databaseWithPath:[self databasePath]];
        [_database open];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (![_database tableExists:@"messages"]) {
        [_database executeUpdate:@"create table \"messages\" (\"username\" text, \"fromid\" text, \"toid\" text, \"type\" text, \"message\" text, \"object\" text, \"blog\" text, \"time\" integer, \"width\" double, \"height\" double, \"isread\" integer default 0)"];
    }
    if (![_database tableExists:@"sessions"]) {
        [_database executeUpdate:@"create table \"sessions\" (\"type\" integer, \"otherid\" text)"];
    }
    [AVGroup setDefaultDelegate:self];
    [_session openWithPeerId:[AVUser currentUser].objectId];

//    FMResultSet *rs = [_database executeQuery:@"select \"type\", \"otherid\" from \"sessions\""];
//    NSMutableArray *peerIds = [[NSMutableArray alloc] init];
//    while ([rs next]) {
//        NSInteger type = [rs intForColumn:@"type"];
//        NSString *otherid = [rs stringForColumn:@"otherid"];
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        [dict setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
//        [dict setObject:otherid forKey:@"otherid"];
//        if (type == CDChatRoomTypeSingle) {
//            [peerIds addObject:otherid];
//        } else if (type == CDChatRoomTypeGroup) {
//            [dict setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
//            [dict setObject:otherid forKey:@"otherid"];
//            
//            AVGroup *group = [AVGroup getGroupWithGroupId:otherid session:_session];
//            group.delegate = self;
//            [group join];
//        }
//        [_chatRooms addObject:dict];
//    }
//    [_session watchPeerIds:peerIds callback:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"watch success");
//        } else {
//            NSLog(@"%@", error);
//        }
//    }];
    initialized = YES;
}

- (void)removeSession {
    [_chatRooms removeAllObjects];
    [_session close];
    initialized = NO;
}

- (void)clearData {
    [_database executeUpdate:@"DROP TABLE IF EXISTS messages"];
    [_database executeUpdate:@"DROP TABLE IF EXISTS sessions"];
    [self removeSession];
}

- (NSArray *)chatRooms {
    return _chatRooms;
}

- (void)addChatWithPeerId:(NSString *)peerId {
    BOOL exist = NO;
    for (NSDictionary *dict in _chatRooms) {
        CDChatRoomType type = [[dict objectForKey:@"type"] integerValue];
        NSString *otherid = [dict objectForKey:@"otherid"];
        if (type == CDChatRoomTypeSingle && [peerId isEqualToString:otherid]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [_session watchPeerIds:@[peerId] callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"watch success");
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSNumber numberWithInteger:CDChatRoomTypeSingle] forKey:@"type"];
                [dict setObject:peerId forKey:@"otherid"];
                [_chatRooms addObject:dict];
//                [_database executeUpdate:@"insert into \"sessions\" (\"type\", \"otherid\") values (?, ?)" withArgumentsInArray:@[[NSNumber numberWithInteger:CDChatRoomTypeSingle], peerId]];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SESSION_UPDATED object:_session userInfo:nil];
            } else {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void)unwatchPeerId:(NSString *)peerId {
    if (peerId) {
        [_session unwatchPeerIds:@[peerId] callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"%@ unwatched!", peerId);
            } else {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (AVGroup *)joinGroup:(NSString *)groupId {
    BOOL exist = NO;
    for (NSDictionary *dict in _chatRooms) {
        CDChatRoomType type = [[dict objectForKey:@"type"] integerValue];
        NSString *otherid = [dict objectForKey:@"otherid"];
        if (type == CDChatRoomTypeGroup && [groupId isEqualToString:otherid]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        AVGroup *group = [AVGroup getGroupWithGroupId:groupId session:_session];
        group.delegate = self;
        [group join];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInteger:CDChatRoomTypeGroup] forKey:@"type"];
        [dict setObject:groupId forKey:@"otherid"];
        [_chatRooms addObject:dict];
        [_database executeUpdate:@"insert into \"sessions\" (\"type\", \"otherid\") values (?, ?)" withArgumentsInArray:@[[NSNumber numberWithInteger:CDChatRoomTypeGroup], groupId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SESSION_UPDATED object:group.session userInfo:nil];
    }
    return [AVGroup getGroupWithGroupId:groupId session:_session];;
}
- (void)startNewGroup:(AVGroupResultBlock)callback {
    [AVGroup createGroupWithSession:_session groupDelegate:self callback:^(AVGroup *group, NSError *error) {
        if (!error) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInteger:CDChatRoomTypeGroup] forKey:@"type"];
            [dict setObject:group.groupId forKey:@"otherid"];
            [_chatRooms addObject:dict];
            [_database executeUpdate:@"insert into \"sessions\" (\"type\", \"otherid\") values (?, ?)" withArgumentsInArray:@[[NSNumber numberWithInteger:CDChatRoomTypeGroup], group.groupId]];
            if (callback) {
                callback(group, error);
            }
        } else {
            NSLog(@"error:%@", error);
        }
    }];
}

- (void)sendMessage:(NSString *)message toPeerId:(NSString *)peerId blogId:(NSString *)strBlogId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:strBlogId forKey:@"blog"];
    [dict setObject:message forKey:@"msg"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
    [_session sendMessage:messageObject requestReceipt:YES];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:peerId forKey:@"toid"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"message"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    
    [dict setObject:[UserData currentUser].objectId forKey:@"username"];
    [dict setObject:strBlogId forKey:@"blog"];
    
    [_database executeUpdate:@"insert into \"messages\" (\"username\", \"blog\", \"fromid\", \"toid\", \"type\", \"message\", \"time\", \"isread\") values (:username, :blog, :fromid, :toid, :type, :message, :time, 1)"
     withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
}

- (void)sendAttachment:(AVObject *)object toPeerId:(NSString *)peerId blogId:(NSString *)strBlogId width:(double)dWidth height:(double)dHeight {
    NSString *type = [object objectForKey:@"type"];
//    AVFile *file = [object objectForKey:type];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:strBlogId forKey:@"blog"];
    [dict setObject:object.objectId forKey:@"object"];
    
    [dict setObject:[NSNumber numberWithDouble:dWidth] forKey:@"width"];
    [dict setObject:[NSNumber numberWithDouble:dHeight] forKey:@"height"];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
    [_session sendMessage:messageObject requestReceipt:YES];
    //    [_session sendMessage:payload isTransient:NO toPeerIds:@[peerId]];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:peerId forKey:@"toid"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    
    [dict setObject:[NSNumber numberWithDouble:dWidth] forKey:@"width"];
    [dict setObject:[NSNumber numberWithDouble:dHeight] forKey:@"height"];
    
    [dict setObject:[UserData currentUser].objectId forKey:@"username"];
    [dict setObject:strBlogId forKey:@"blog"];
    
    [_database executeUpdate:@"insert into \"messages\" (\"username\", \"blog\", \"fromid\", \"toid\", \"type\", \"object\", \"time\", \"width\", \"height\", \"isread\") values (:username, :blog, :fromid, :toid, :type, :object, :time, :width, :height, 1)"
     withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}

- (void)sendMessage:(NSString *)message toGroup:(NSString *)groupId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"msg"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVGroup *group = [AVGroup getGroupWithGroupId:groupId session:_session];
    AVMessage *messageObject = [AVMessage messageForGroup:group payload:payload];
    [group sendMessage:messageObject];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:groupId forKey:@"toid"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"message"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"message\", \"time\") values (:fromid, :toid, :type, :message, :time)" withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}

- (void)sendAttachment:(AVObject *)object toGroup:(NSString *)groupId {
    NSString *type = [object objectForKey:@"type"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVGroup *group = [AVGroup getGroupWithGroupId:groupId session:_session];
    AVMessage *messageObject = [AVMessage messageForGroup:group payload:payload];
    [group sendMessage:messageObject];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:groupId forKey:@"toid"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\") values (:fromid, :toid, :type, :object, :time)" withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];

}

- (NSArray *)getMessagesForPeerId:(NSString *)peerId blogId:(NSString *)strBlogId {
    NSString *selfId = _session.peerId;
    NSString *strUsername = [UserData currentUser].objectId;
    
    FMResultSet *rs;
    
    if (strBlogId) {
        rs = [_database executeQuery:@"select \"fromid\", \"toid\", \"type\", \"message\", \"object\", \"time\", \"width\", \"height\", \"isread\" from \"messages\" where \"username\"=? and \"blog\"=? and ((\"fromid\"=? and \"toid\"=?) or (\"fromid\"=? and \"toid\"=?))"
                withArgumentsInArray:@[strUsername, strBlogId, selfId, peerId, peerId, selfId]];
    }
    else {
        rs = [_database executeQuery:@"select \"fromid\", \"toid\", \"type\", \"message\", \"object\", \"time\", \"width\", \"height\", \"isread\" from \"messages\" where \"username\"=? and ((\"fromid\"=? and \"toid\"=?) or (\"fromid\"=? and \"toid\"=?))"
                withArgumentsInArray:@[strUsername, selfId, peerId, peerId, selfId]];
    }
    
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        NSString *fromid = [rs stringForColumn:@"fromid"];
        NSString *toid = [rs stringForColumn:@"toid"];
        double time = [rs doubleForColumn:@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *type = [rs stringForColumn:@"type"];
        NSNumber *numIsread = [NSNumber numberWithBool:[rs intForColumn:@"isread"]];
        
        if ([type isEqualToString:@"text"]) {
            NSString *message = [rs stringForColumn:@"message"];
            NSDictionary *dict = @{@"fromid":fromid,
                                   @"toid":toid,
                                   @"type":type,
                                   @"message":message,
                                   @"time":date,
                                   @"isread":numIsread};
            [result addObject:dict];
        } else {
            NSString *object = [rs stringForColumn:@"object"];
            NSNumber *numWidth = [NSNumber numberWithDouble:[rs doubleForColumn:@"width"]];
            NSNumber *numHeight = [NSNumber numberWithDouble:[rs doubleForColumn:@"height"]];
            NSDictionary *dict = @{@"fromid":fromid,
                                   @"toid":toid,
                                   @"type":type,
                                   @"object":object,
                                   @"time":date,
                                   @"width":numWidth,
                                   @"height":numHeight,
                                   @"isread":numIsread};
            [result addObject:dict];
        }
    }
    return result;
}

- (void)deleteMessagesForPeerId:(NSString *)peerId {
    
    NSString *selfId = _session.peerId;
    NSString *strUsername = [UserData currentUser].objectId;
    
    [_database executeUpdate:@"delete from \"messages\" where \"username\"=? and ((\"fromid\"=? and \"toid\"=?) or (\"fromid\"=? and \"toid\"=?))"
        withArgumentsInArray:@[strUsername, selfId, peerId, peerId, selfId]];
}

- (void)deleteMessagesForBlogId:(NSString *)blogId {
    [_database executeUpdate:@"delete from \"messages\" where \"blog\"=?"
        withArgumentsInArray:@[blogId]];
}

- (NSDictionary *)getLatestMessageForPeerId:(NSString *)peerId {
    NSString *selfId = _session.peerId;
    NSString *strUsername = [UserData currentUser].objectId;
    
    if (!selfId || !strUsername) {
        return nil;
    }
    
    FMResultSet *rs = [_database executeQuery:@"select \"fromid\", \"toid\", \"type\", \"message\", \"object\", \"time\", \"width\", \"height\", \"isread\" from \"messages\" where \"username\"=? and ((\"fromid\"=? and \"toid\"=?) or (\"fromid\"=? and \"toid\"=?)) order by \"time\" desc limit 1"
                         withArgumentsInArray:@[strUsername, selfId, peerId, peerId, selfId]];
    
    NSDictionary *dictRes;

    while ([rs next]) {
        NSString *fromid = [rs stringForColumn:@"fromid"];
        NSString *toid = [rs stringForColumn:@"toid"];
        double time = [rs doubleForColumn:@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *type = [rs stringForColumn:@"type"];
        NSNumber *numIsread = [NSNumber numberWithBool:[rs intForColumn:@"isread"]];
        
        if ([type isEqualToString:@"text"]) {
            NSString *message = [rs stringForColumn:@"message"];
            NSDictionary *dict = @{@"fromid":fromid,
                                   @"toid":toid,
                                   @"type":type,
                                   @"message":message,
                                   @"time":date,
                                   @"isread":numIsread};
            dictRes = dict;
        }
        else {
            NSString *object = [rs stringForColumn:@"object"];
            NSNumber *numWidth = [NSNumber numberWithDouble:[rs doubleForColumn:@"width"]];
            NSNumber *numHeight = [NSNumber numberWithDouble:[rs doubleForColumn:@"height"]];
            NSDictionary *dict = @{@"fromid":fromid,
                                   @"toid":toid,
                                   @"type":type,
                                   @"object":object,
                                   @"time":date,
                                   @"width":numWidth,
                                   @"height":numHeight,
                                   @"isread":numIsread};
            dictRes = dict;
        }
    }
    return dictRes;
}

- (NSArray *)getLatestMessagesForPeerId {
    NSString *selfId = _session.peerId;
    NSString *strUsername = [UserData currentUser].objectId;
    
    if (!selfId || !strUsername) {
        return nil;
    }
    
    FMResultSet *rs = [_database executeQuery:@"select * from (select * from \"messages\" order by \"time\" asc) where (\"username\"=? and (\"fromid\"=? or \"toid\"=?)) group by \"blog\""
                         withArgumentsInArray:@[strUsername, selfId, selfId]];
    
    NSMutableArray *aryRes = [[NSMutableArray alloc] init];
    
    while ([rs next]) {
        NSString *blog = [rs stringForColumn:@"blog"];
        if (!blog || [blog length] == 0) {
            continue;
        }
        
        NSString *fromid = [rs stringForColumn:@"fromid"];
        NSString *toid = [rs stringForColumn:@"toid"];
        double time = [rs doubleForColumn:@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *type = [rs stringForColumn:@"type"];
        NSNumber *numIsread = [NSNumber numberWithBool:[rs intForColumn:@"isread"]];
        
        NSDictionary *dict;
        
        if ([type isEqualToString:@"text"]) {
            NSString *message = [rs stringForColumn:@"message"];
            dict = @{@"fromid":fromid,
                     @"toid":toid,
                     @"type":type,
                     @"message":message,
                     @"time":date,
                     @"blog":blog,
                     @"isread":numIsread};
        }
        else {
            NSString *object = [rs stringForColumn:@"object"];
            NSNumber *numWidth = [NSNumber numberWithDouble:[rs doubleForColumn:@"width"]];
            NSNumber *numHeight = [NSNumber numberWithDouble:[rs doubleForColumn:@"height"]];
            dict = @{@"fromid":fromid,
                     @"toid":toid,
                     @"type":type,
                     @"message":@"[图片]",
                     @"object":object,
                     @"time":date,
                     @"width":numWidth,
                     @"height":numHeight,
                     @"blog":blog,
                     @"isread":numIsread};
        }
        
        [aryRes addObject:dict];
    }
    
    return aryRes;
}


- (NSInteger)getUnreadCountForPeerId:(NSString *)peerId {
    NSString *selfId = _session.peerId;
    NSInteger nRes = 0;
    NSString *strUsername = [UserData currentUser].objectId;
    
    if (!selfId || !strUsername) {
        return 0;
    }
    
    FMResultSet *rs = [_database executeQuery:@"select count(*) as \"unreadcount\" from \"messages\" where ((\"fromid\"=? and \"toid\"=?) or (\"fromid\"=? and \"toid\"=?)) and \"isread\"=0 and \"username\"=?"
                         withArgumentsInArray:@[selfId, peerId, peerId, selfId, strUsername]];
    while ([rs next]) {
        nRes = [rs intForColumn:@"unreadcount"];
    }
    
    return nRes;
}

- (void)setUnreadToReadForPeerId:(NSString *)peerId {
    NSString *selfId = _session.peerId;
    NSString *strUsername = [UserData currentUser].objectId;
    
    [_database executeUpdate:@"update \"messages\" set \"isread\"=1 where ((\"fromid\"=? and \"toid\"=?) or (\"fromid\"=? and \"toid\"=?)) and \"isread\"=0 and \"username\"=?"
        withArgumentsInArray:@[selfId, peerId, peerId, selfId, strUsername]];
}


- (NSArray *)getMessagesForGroup:(NSString *)groupId {
    FMResultSet *rs = [_database executeQuery:@"select \"fromid\", \"toid\", \"type\", \"message\", \"object\", \"time\" from \"messages\" where \"toid\"=?" withArgumentsInArray:@[groupId]];
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        NSString *fromid = [rs stringForColumn:@"fromid"];
        NSString *toid = [rs stringForColumn:@"toid"];
        double time = [rs doubleForColumn:@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *type = [rs stringForColumn:@"type"];
        if ([type isEqualToString:@"text"]) {
            NSString *message = [rs stringForColumn:@"message"];
            NSDictionary *dict = @{@"fromid":fromid, @"toid":toid, @"type":type, @"message":message, @"time":date};
            [result addObject:dict];
        } else {
            NSString *object = [rs stringForColumn:@"object"];
            NSDictionary *dict = @{@"fromid":fromid, @"toid":toid, @"type":type, @"object":object, @"time":date};
            [result addObject:dict];
        }
    }
    return result;
}

- (void)getHistoryMessagesForPeerId:(NSString *)peerId callback:(AVArrayResultBlock)callback {
    AVHistoryMessageQuery *query = [AVHistoryMessageQuery queryWithFirstPeerId:_session.peerId secondPeerId:peerId];
    [query findInBackgroundWithCallback:^(NSArray *objects, NSError *error) {
        callback(objects, error);
    }];
}

- (void)getHistoryMessagesForGroup:(NSString *)groupId callback:(AVArrayResultBlock)callback {
    AVHistoryMessageQuery *query = [AVHistoryMessageQuery queryWithGroupId:groupId];
    [query findInBackgroundWithCallback:^(NSArray *objects, NSError *error) {
        callback(objects, error);
    }];
}
#pragma mark - AVSessionDelegate
- (void)sessionOpened:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)sessionPaused:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)sessionResumed:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)session:(AVSession *)session didReceiveMessage:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ fromPeerId:%@", session.peerId, message, message.fromPeerId);
    NSError *error;
    NSData *data = [message.payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"%@", jsonDict);
    
    NSString *blog = [jsonDict objectForKey:@"blog"];
    if (!blog || [blog length] == 0) {
        return;
    }
    
    NSString *type = [jsonDict objectForKey:@"type"];
    NSString *msg = [jsonDict objectForKey:@"msg"];
    NSString *object = [jsonDict objectForKey:@"object"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:message.fromPeerId forKey:@"fromid"];
    [dict setObject:session.peerId forKey:@"toid"];
    [dict setObject:@(message.timestamp/1000) forKey:@"time"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:blog forKey:@"blog"];
    
    [dict setObject:[UserData currentUser].objectId forKey:@"username"];
    
    if ([type isEqualToString:@"text"]) {
        [dict setObject:msg forKey:@"message"];
        [_database executeUpdate:@"insert into \"messages\" (\"username\", \"blog\", \"fromid\", \"toid\", \"type\", \"message\", \"time\") values (:toid, :blog, :fromid, :toid, :type, :message, :time)"
         withParameterDictionary:dict];
    } else {
        NSNumber *numWidth = [jsonDict objectForKey:@"width"];
        NSNumber *numHeight = [jsonDict objectForKey:@"height"];
        
        [dict setObject:object forKey:@"object"];
        [dict setObject:numWidth forKey:@"width"];
        [dict setObject:numHeight forKey:@"height"];
        
        [_database executeUpdate:@"insert into \"messages\" (\"username\", \"blog\", \"fromid\", \"toid\", \"type\", \"object\", \"time\", \"width\", \"height\") values (:toid, :blog, :fromid, :toid, :type, :object, :time, :width, :height)"
         withParameterDictionary:dict];
    }
//    [self addChatWithPeerId:message.fromPeerId];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:session userInfo:dict];
}

- (void)session:(AVSession *)session messageSendFailed:(AVMessage *)message error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ toPeerId:%@ error:%@", session.peerId, message, message.toPeerId, error);
}

- (void)session:(AVSession *)session messageSendFinished:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ toPeerId:%@", session.peerId, message, message.toPeerId);
}

- (void)session:(AVSession *)session messageArrived:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);

}

- (void)session:(AVSession *)session didReceiveStatus:(AVPeerStatus)status peerIds:(NSArray *)peerIds {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ peerIds:%@ status:%@", session.peerId, peerIds, status==AVPeerStatusOffline?@"offline":@"online");
}

- (void)sessionFailed:(AVSession *)session error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ error:%@", session.peerId, error);
}

#pragma mark - AVGroupDelegate
- (void)group:(AVGroup *)group didReceiveMessage:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@ fromPeerId:%@", group.groupId, message, message.fromPeerId);
    NSError *error;
    NSData *data = [message.payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"%@", jsonDict);
    
    NSString *type = [jsonDict objectForKey:@"type"];
    NSString *msg = [jsonDict objectForKey:@"msg"];
    NSString *object = [jsonDict objectForKey:@"object"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:message.fromPeerId forKey:@"fromid"];
    [dict setObject:group.groupId forKey:@"toid"];
    [dict setObject:@(message.timestamp/1000) forKey:@"time"];
    [dict setObject:type forKey:@"type"];
    if ([type isEqualToString:@"text"]) {
        [dict setObject:msg forKey:@"message"];
        [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"message\", \"time\") values (:fromid, :toid, :type, :message, :time)" withParameterDictionary:dict];
    } else {
        [dict setObject:object forKey:@"object"];
        [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\") values (:fromid, :toid, :type, :object, :time)" withParameterDictionary:dict];
    }
    [self joinGroup:group.groupId];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:group.session userInfo:dict];
}

- (void)group:(AVGroup *)group didReceiveEvent:(AVGroupEvent)event peerIds:(NSArray *)peerIds {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ event:%lu peerIds:%@", group.groupId, (long)event, peerIds);
    if (event == AVGroupEventSelfJoined) {
        [self joinGroup:group.groupId];
    }
}

- (void)group:(AVGroup *)group messageSendFinished:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@", group.groupId, message.payload);

}

- (void)group:(AVGroup *)group messageSendFailed:(AVMessage *)message error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@ error:%@", group.groupId, message.payload, error);

}

- (void)session:(AVSession *)session group:(AVGroup *)group messageSent:(NSString *)message success:(BOOL)success {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@ success:%d", group.groupId, message, success);
}

- (AVSignature *)signatureForPeerWithPeerId:(NSString *)peerId watchedPeerIds:(NSArray *)watchedPeerIds action:(NSString *)action {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"peerId:%@ action:%@", peerId, action);
    return nil;
}

- (AVSignature *)signatureForGroupWithPeerId:(NSString *)peerId groupId:(NSString *)groupId groupPeerIds:(NSArray *)groupPeerIds action:(NSString *)action {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"peerId:%@ groupId:%@ action:%@", peerId, groupId, action);
    return nil;
}
@end
