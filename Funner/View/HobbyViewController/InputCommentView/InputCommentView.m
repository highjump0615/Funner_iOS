//
//  InputCommentView.m
//  Funner
//
//  Created by highjump on 15-3-31.
//
//

#import "InputCommentView.h"

#import "NotificationData.h"
#import "UserData.h"
#import "BlogData.h"

@interface InputCommentView() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mImgIcon;

@end

@implementation InputCommentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [self.mTxtComment setDelegate:self];
}

- (void)setMnCommentType:(int)mnCommentType {
    
    _mnCommentType = mnCommentType;
    
    if (mnCommentType == NOTIFICATION_COMMENT) {
        [self.mImgIcon setImage:[UIImage imageNamed:@"home_like_white.png"]];
        [self.mTxtComment setPlaceholder:@"请输入你的欣赏"];
    }
    else if (mnCommentType == NOTIFICATION_SUGGEST) {
        [self.mImgIcon setImage:[UIImage imageNamed:@"home_comment_white.png"]];
        [self.mTxtComment setPlaceholder:@"请输入你的建议"];
    }
}

- (IBAction)onButSend:(id)sender {
    if ([self.mTxtComment.text length] == 0) {
        return;
    }
    
    NSString *strComment = [self.mTxtComment.text substringToIndex:MIN(self.mTxtComment.text.length, 100)];
    
    //
    // save to notification database
    //
    NotificationData *notifyObj = [NotificationData object];
    notifyObj.blog = self.mBlogData;
    notifyObj.user = [UserData currentUser];
    notifyObj.username = [[UserData currentUser] getUsernameToShow];
    notifyObj[@"targetuser"] = self.mBlogData.user;
    notifyObj.thumbnail = self.mBlogData.image;
    notifyObj.type = self.mnCommentType;
    notifyObj.comment = strComment;
    notifyObj.isnew = [NSNumber numberWithBool:YES];
    notifyObj[@"isread"] = @(NO);
    
    [notifyObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //        [self.mButSend setBackgroundColor:mColorNormal];
        
        if (succeeded) {
            //
            // add comment object
            //
            if (self.mnCommentType == NOTIFICATION_COMMENT) {
                [self.mBlogData.maryCommentData addObject:notifyObj];
            }
            else if (self.mnCommentType == NOTIFICATION_SUGGEST) {
                [self.mBlogData.marySuggestData addObject:notifyObj];
            }
            
            AVRelation *relation = self.mBlogData.commentobject;
            [relation addObject:notifyObj];
    
            // set popularity
            [self.mBlogData incrementKey:@"likecomment"];
            [self.mBlogData calculatePopularity];
            
            [self.mBlogData saveInBackground];
            
            [self.delegate onSentComment:YES];
        }
        else {
            [self.delegate onSentComment:NO];
        }
    }];
    
    //    [self.mButSend setBackgroundColor:mColorDisable];
    
    [self.mTxtComment setText:@""];
}

# pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onButSend:nil];
    return YES;
}



@end
