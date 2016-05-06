//
//  RendaKeychain.m
//  APP_GUOLI
//
//  Created by xiaobin on 15-12-4.
//  Copyright (c) 2015年 renda. All rights reserved.
//

#import "RendaKeychain.h"

@implementation RendaKeychain

@synthesize KEY_USERNAME_PASSWORD;
@synthesize KEY_USERNAME;
@synthesize KEY_PASSWORD;

-(void) initWithKeys{
    KEY_USERNAME_PASSWORD = @"com.ios.app.usernamepassword";
    KEY_USERNAME = @"com.ios.app.username";
    KEY_PASSWORD = @"com.iso.app.password";
}
-(NSMutableDictionary *)getKeychainQuery:(NSString *)service{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass
            ,service,(__bridge id)kSecAttrService
            ,service,(__bridge id)kSecAttrAccount
            ,(__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,nil];
}
-(void)save:(NSString *)service data:(id)data{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}
-(id)load:(NSString *)service{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr){
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *exception) {
            NSLog(@"Unarchive of %@ failed:%@",service,exception);
        }
        @finally {
            
        }
    }
    if(keyData) CFRelease(keyData);
    return ret;
}
-(void)delete:(NSString *)service{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}
@end
