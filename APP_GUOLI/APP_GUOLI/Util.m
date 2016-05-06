//
//  Util.m
//  APP_GUOLI
//
//  Created by xiaobin on 15/12/17.
//  Copyright © 2015年 renda. All rights reserved.
//

#import "Util.h"

@implementation Util

+(NSString *)transDictionaryToSoapMessage:(NSMutableDictionary *)dictionary{
    NSMutableString *result = [NSMutableString stringWithString:@"<Object>"];
    if(dictionary != nil && [dictionary count] > 0){
        for(id x in dictionary){
            [result appendFormat:@"<%@ type=\"string\">%@</%@>",x,[dictionary objectForKey:x],x];
        }
    }
    [result appendString:@"</Object>"];
    return result;
}

+(NSString *)checkedMessageOfJson:(NSString *)msg success:(NSString *)success code:(int)code{
    return [NSString stringWithFormat:@"{\"result\":{\"success\":\"%@\",\"msg\":\"%@\",\"code\":\"%d\"}}",success,msg,code];
}
+(NSString *)checkedMessageOfJson:(NSString *)msg code:(int)code{
    return [self checkedMessageOfJson:msg success:@"false" code:code];
}
+(NSString *)checkedMessageOfJson:(NSString *)msg{
    return [self checkedMessageOfJson:msg code:-1];
}

+(void) dialog:(NSString *)title msg:(NSString *)msg delegate:(id)delegate btnName:(NSString *)btnName{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:btnName otherButtonTitles:nil, nil];
    [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    [alert show];
}
+(void) dialog:(NSString *)title msg:(NSString *)msg delegate:(id)delegate{
    [self dialog:title msg:msg delegate:delegate btnName:@"确定"];
}

/*-(void) uploadImage:(NSString *)url user_id:(NSString *)user_id index:(NSString *)index trs_id:(NSString *)trs_id role_id:(NSString *)role_id delegate:(nullable id)delegate imageData:(NSMutableDictionary *)imageData imageName:(NSMutableDictionary *)imageName{
    if([imageData count] == 0) return;
    //分界线的标示符
    NSString *TWITTERFON_FROM_BOUNDARY = @"Renda_App";
    //根据url初始化request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //分界线 --Renda_App
    NSString *MPBoundary = [[NSString alloc] initWithFormat:@"--%@",TWITTERFON_FROM_BOUNDARY];
    //结束符 Renda_App--
    NSString *endMPBoundary = [[NSString alloc] initWithFormat:@"%@--",MPBoundary];
    //http body的字符串
    NSMutableString *body = [[NSMutableString alloc] init];
    
    //添加分割线
    [body appendFormat:@"%@\r\n",MPBoundary];
    //添加字段名称，换两行
    [body appendFormat:@"Content-Disposition: form-data; name=\"USER_ID\"\r\n\r\n"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",user_id];
    //添加分割线
    [body appendFormat:@"%@\r\n",MPBoundary];
    //添加字段名称，换两行
    [body appendFormat:@"Content-Disposition: form-data; name=\"INDEX\"\r\n\r\n"];
    //添加字段的值
    [body appendFormat:@"%d\r\n",[index intValue]+1];
    //添加分割线
    [body appendFormat:@"%@\r\n",MPBoundary];
    //添加字段名称，换两行
    [body appendFormat:@"Content-Disposition: form-data; name=\"TRS_ID\"\r\n\r\n"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",trs_id];
    //添加分割线
    [body appendFormat:@"%@\r\n",MPBoundary];
    //添加字段名称，换两行
    [body appendFormat:@"Content-Disposition: form-data; name=\"ROLE_ID\"\r\n\r\n"];
    //添加字段的值
    [body appendFormat:@"%@\r\n",role_id];
    
    
    NSMutableData *requestData = [NSMutableData data];
    //for(NSString *index in imageData){
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPBoundary];
    //声明pic字段，文件名
    [body appendFormat:@"Content-Disposition: form-data; name=\"img\"; filename=\"%@.JPEG\"\r\n",[imageName objectForKey:index]];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type:image/jpeg\r\n\r\n"];
    //}
    //声明结束符: --Renda_App--
    NSString *end = [[NSString alloc] initWithFormat:@"\r\n%@",endMPBoundary];
    //将body字符串转化成UTF8格式的二进制
    [requestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [requestData appendData:[imageData objectForKey:index]];
    //加入结束符--Renda_App--
    [requestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content－Type的值
    NSString *content = [[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FROM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content－Length
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:requestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    //建立连接，设置代理
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //设置接受response的data；
    NSMutableData *responseData = [[NSMutableData alloc] init];
    NSLog(@"uploadImage:11");
    if(conn){
        responseData = [NSMutableData data];
    }
}*/
@end
