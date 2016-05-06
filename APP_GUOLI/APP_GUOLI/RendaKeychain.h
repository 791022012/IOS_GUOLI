//
//  RendaKeychain.h
//  APP_GUOLI
//
//  Created by xiaobin on 15-12-4.
//  Copyright (c) 2015年 renda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface RendaKeychain : NSObject
@property (strong,nonatomic) NSString *KEY_USERNAME_PASSWORD;
@property (strong,nonatomic) NSString *KEY_USERNAME;
@property (strong,nonatomic) NSString *KEY_PASSWORD;

-(void) initWithKeys;
-(NSMutableDictionary *)getKeychainQuery:(NSString *)service;
-(void)save:(NSString *)service data:(id)data;
-(id)load:(NSString *)service;
-(void)delete:(NSString *)service;
@end
