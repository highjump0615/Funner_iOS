//
//  CategoryData.h
//  Funner
//
//  Created by highjump on 14-11-22.
//
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@class BlogData;

@interface CategoryData : AVObject <AVSubclassing>

@property (retain) AVFile *icon;
@property (retain) NSString *name;
@property (retain) NSString *desc;
@property (retain) AVFile *imgBackground;
@property (retain) CategoryData *parent;

@property (nonatomic) BOOL mbGotLatest;
@property (strong) BlogData *mBlogLatest;
@property (nonatomic) BOOL mbGotNetworkLatest;
@property (strong) BlogData *mBlogNetworkLatest;

// parameters for me page
@property (nonatomic) BOOL mbShowedAll;

@end
