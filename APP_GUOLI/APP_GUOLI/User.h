//
//  User.h
//  APP_GUOLI
//
//  Created by xiaobin on 15-12-4.
//  Copyright (c) 2015年 renda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong,nonatomic) NSUserDefaults *user;

-(void)setUserInfo:(NSString *)key value:(NSString *)value;
-(void)setUserInfos:(NSMutableDictionary *)data;
-(NSString *)getUserInfo:(NSString *) key;
-(NSMutableDictionary *)getUserInfos:(NSMutableArray *)keys;
-(void)remove:(NSString *)key;
@end
