//
//  Util.h
//  APP_GUOLI
//
//  Created by xiaobin on 15/12/17.
//  Copyright © 2015年 renda. All rights reserved.
//
/*
 *静态通用类
 */
@interface Util : NSObject
NS_ASSUME_NONNULL_BEGIN //防止很多很多的编译警告,不影响实际运行
//将dictionary转成soap消息内容
+(NSString *)transDictionaryToSoapMessage:(NSMutableDictionary *) dictionary;

//返回json信息,一般用于弹出一些提示
+(NSString *)checkedMessageOfJson:(NSString *) msg success:(NSString *) success code:(int) code;
+(NSString *)checkedMessageOfJson:(NSString *) msg code:(int) code;
+(NSString *)checkedMessageOfJson:(NSString *) msg;

+(void) dialog:(NSString *)title msg:(NSString *)msg delegate:(nullable id)delegate btnName:(NSString *)btnName;
+(void) dialog:(NSString *)title msg:(NSString *)msg delegate:(nullable id)delegate;

//上传图片
//-(void) uploadImage:(NSString *)url user_id:(NSString *)user_id index:(NSString *)index trs_id:(NSString *)trs_id role_id:(NSString *)role_id delegate:(nullable id)delegate imageData:(NSMutableDictionary *)imageData imageName:(NSMutableDictionary *)imageName;

NS_ASSUME_NONNULL_END
@end
