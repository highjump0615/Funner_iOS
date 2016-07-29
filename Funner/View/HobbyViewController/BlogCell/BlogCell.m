//
//  BlogRelationCell.m
//  Funner
//
//  Created by highjump on 14-12-3.
//
//

#import "BlogCell.h"
#import "BlogData.h"
#import "CommonUtils.h"
#import "NotificationData.h"
#import "UserData.h"

@interface BlogCell() {
    BlogData *mBlogData;
}

@end

@implementation BlogCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(BlogData *)data forHeight:(BOOL)bForHeight {
    
    [super fillContent:data forHeight:bForHeight];
    
//    if (data) {
//        if ([data isLiked]) {
//            [self.mButLike setTitle:@" 已赞" forState:UIControlStateNormal];
//            [self.mButLike setImage:[UIImage imageNamed:@"home_liked.png"] forState:UIControlStateNormal];
//        }
//        else {
//            [self.mButLike setTitle:@" 赞Ta" forState:UIControlStateNormal];
//            [self.mButLike setImage:[UIImage imageNamed:@"home_like.png"] forState:UIControlStateNormal];
//        }
//    }
    
    mBlogData = data;
}

- (IBAction)onButLike:(id)sender {
    if (![UserData currentUser]) {
        return;
    }
    
    if (!mBlogData) {
        return;
    }
    
    BOOL bRes = NO;
    
    if ([mBlogData isLiked]) {
        //
        // delete from notification database
        //
        bRes = NO;
        NotificationData *notifyData;
        for (NotificationData *nData in mBlogData.maryLikeData) {
            if ([nData.user.objectId isEqualToString:[UserData currentUser].objectId]) {
                notifyData = nData;
                break;
            }
        }
        
        bRes = [notifyData delete];
        if (bRes) {
            //
            // remove like object
            //
            [mBlogData.maryLikeData removeObject:notifyData];
            [mBlogData.likeobject removeObject:notifyData];
            [mBlogData saveInBackground];
        }
    }
    else {
        //
        // save to notification database
        //
        UserData *currentUser = [UserData currentUser];
        NotificationData *notifyObj = [NotificationData object];
        notifyObj.user = currentUser;
        notifyObj.blog = mBlogData;
        notifyObj.username = [currentUser getUsernameToShow];
        notifyObj[@"targetuser"] = mBlogData.user;
        notifyObj.thumbnail = mBlogData.image;
        notifyObj.type = NOTIFICATION_LIKE;
        notifyObj.isnew = [NSNumber numberWithBool:YES];
        notifyObj[@"isread"] = @(NO);
        
        bRes = [notifyObj save];
        
        if (bRes) {
            //
            // add like object
            //
            [mBlogData.maryLikeData addObject:notifyObj];
            [mBlogData.likeobject addObject:notifyObj];
            
            // set popularity
            [mBlogData incrementKey:@"likecomment"];
            [mBlogData calculatePopularity];
            
            [mBlogData saveInBackground];
        }
    }
    
    if (self.delegate) {
        [self.delegate onLikeResult:bRes];
    }
}


@end
