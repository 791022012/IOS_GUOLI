//
//  User.m
//  APP_GUOLI
//
//  Created by xiaobin on 15-12-4.
//  Copyright (c) 2015年 renda. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize user;

//获取NSUserDefaults对象
-(NSUserDefaults *)getUser{
    if(user == nil){
        user = [NSUserDefaults standardUserDefaults];
    }
    return user;
}
//插入key-value值
-(void)setUserInfo:(NSString *)key value:(NSString *)value{
    NSLog(@"serUserInfo,%@:%@",key,value);
    NSUserDefaults *tmpUser = [self getUser];
    key = [key uppercaseString];
    [tmpUser setObject:value forKey:key];
    [tmpUser synchronize];
}
-(void)setUserInfos:(NSMutableDictionary *) data{
    NSUserDefaults *tmpUser = [self getUser];
    for(id x in data){
        //插入一个key - value值
        [tmpUser setObject:[data objectForKey:x] forKey:[x uppercaseString]];
        //这里是为了把设置及时写入文件，防止由于崩溃等情况App内存信息丢失
        [tmpUser synchronize];
    }
}
//返回指定某个key的值
-(NSString *)getUserInfo:(NSString *) key{
    key = [key uppercaseString];
    NSString *value = [[self getUser] objectForKey:key];
    if(value == nil || [value isEqualToString:@""]){
        return @"";
    }else{
        return [[self getUser] objectForKey:key];
    }
}
//返回指定keys的值
-(NSMutableDictionary *)getUserInfos:(NSMutableArray *)keys{
    NSMutableDictionary *userInfos = [[NSMutableDictionary alloc] init];
    for(int i=0;i<[keys count];i++){
        [userInfos setObject:[self getUserInfo:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
    }
    return userInfos;
}
-(void)remove:(NSString *)key{
    NSUserDefaults *tmpUser = [self getUser];
    [tmpUser removeObjectForKey:[key uppercaseString]];
    [tmpUser synchronize];
}
@end
