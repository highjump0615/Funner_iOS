//
//  AdData.h
//  Funner
//
//  Created by highjump on 14-11-22.
//
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@class CategoryData;

@interface AdData : AVObject <AVSubclassing>

@property (retain) AVFile *image;
@property (retain) CategoryData *category;

@end
