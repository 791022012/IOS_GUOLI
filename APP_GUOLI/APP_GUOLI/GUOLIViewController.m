//
//  GUOLIViewController.m
//  APP_GUOLI
//
//  Created by xiaobin on 15-12-2.
//  Copyright (c) 2015年 renda. All rights reserved.
//

#import "GUOLIViewController.h"
#import "StaticRef.h"
#import "User.h"
#import "RendaKeychain.h"
#import "Util.h"
#import "sys/utsname.h"

@interface GUOLIViewController ()
@property (strong,nonatomic) NSMutableString *jsonResult;
@property (strong,nonatomic) NSString *resultMethod;
@property (strong,nonatomic) UIWebView *webView;
@property (strong,nonatomic) NSString *imagePath;
@property (strong,nonatomic) NSMutableDictionary *imageData;       //用于存放所选图片的二进制
@property (strong,nonatomic) NSString *imageIndex;          //表示当前所选的图片的序号
@property (strong,nonatomic) NSMutableDictionary *imageName;        //用于保存图片的名字
@property (strong,nonatomic) NSString *callMethod;
@property (strong,nonatomic) NSDictionary *logInfo;
@property (strong,nonatomic) NSString *webservice_id;
@property (strong,nonatomic) NSString *webservice_port;
@property (strong,nonatomic) NSString *webservice_name;
@property (strong,nonatomic) NSString *webservice_subname;
@property (strong,nonatomic) NSString *scaleSize;
@property int picIndex;


@end

@implementation GUOLIViewController

@synthesize webData;
@synthesize soapResults;
@synthesize xmlParser;
@synthesize elementFound;
@synthesize matchingElement;
@synthesize conn;
@synthesize jsonResult;
@synthesize imagePath;
@synthesize imageData;
@synthesize imageName;
@synthesize txtLat;
@synthesize txtLng;
@synthesize txtAlt;
//@synthesize href;
//@synthesize resultMethod;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    static dispatch_once_t onceToken;
    __block NSString *iphoneVersion;
    __block CGRect rect;
    dispatch_once(&onceToken, ^{
        self.webservice_id = [WEBSERVICE_ID substringFromIndex:0];
        self.webservice_name = [WEBSERVICE_NAME substringFromIndex:0];
        self.webservice_port = [WEBSERVICE_PORT substringFromIndex:0];
        self.webservice_subname = [WEBSERVICE_SUBNAME substringFromIndex:0];
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        //NSLog(@"deviceString:%@",deviceString);
        User *user = [[User alloc] init];
        if(deviceString == nil || [deviceString rangeOfString:@"iPhone"].location != NSNotFound){
            if(deviceString == nil || [deviceString rangeOfString:@"iPhone3"].location != NSNotFound || [deviceString rangeOfString:@"iPhone4"].location != NSNotFound){
                self.scaleSize = @"0px";
                [user setUserInfo:@"iphoneversion" value:@"4"];
                iphoneVersion = @"4";
            }else if([deviceString rangeOfString:@"iPhone5"].location != NSNotFound){
                [user setUserInfo:@"iphoneversion" value:@"5"];
                iphoneVersion = @"5";
            }else{
                self.scaleSize = @"0px";
                [user setUserInfo:@"iphoneversion" value:@"6"];
                iphoneVersion = @"6";
            }
        }else{
            [user setUserInfo:@"iphoneversion" value:@"ipad"];
            iphoneVersion = @"ipad";
        }
        //获取首页图片
        self.callMethod = @"getMainPic";
        [self soap:@"ExecSqlService" methodName:@"getPicDir" fields:@"<func_mode>FUNC01</func_mode>"];
        
        //获取屏幕分辨率
        //屏幕尺寸
        rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        NSLog(@"width:%f,height:%f",width,height);
        //分辨率
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        NSLog(@"scale:%f,%f",width*scale_screen,height*scale_screen);
        [user setUserInfo:@"width" value:[NSString stringWithFormat:@"%f",width]];
        [user setUserInfo:@"height" value:[NSString stringWithFormat:@"%f",height]];
        [user setUserInfo:@"scale" value:[NSString stringWithFormat:@"%f",scale_screen]];
    });
    
    //[self.webView autoresizesSubviews];
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = rect;
    
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    self.webView.scrollView.delegate = self;
    imageData = [[NSMutableDictionary alloc] init];
    imageName = [[NSMutableDictionary alloc] init];
    //self.webView.autoresizesSubviews = YES;
    //self.webView.scalesPageToFit = YES;
    [self.webView setScalesPageToFit:YES];
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2.加载网页
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *htmlView = [[NSString alloc] init];
    //判断是否第一次使用
    User *user = [[User alloc] init];
    //NSLog(@"firstinstall:%@",[user getUserInfo:@"firstinstall"]);
    if([user getUserInfo:@"FIRSTINSTALL"] == nil || [@"" isEqualToString:[user getUserInfo:@"firstinstall"]] || [@"true" isEqualToString:[user getUserInfo:@"FIRSTINSTALL"]]){
        //NSLog(@"guideView");
        htmlView = @"guideView";
    }else{
        //NSLog(@"startView");
        htmlView = @"startView";
    }
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:htmlView ofType:@"html"];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var iphoneversion=%@",iphoneVersion]];
    NSString *htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding
                                                      error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:baseURL];
    //[webView loadRequest:request];
    
    //定位代码
    //判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]){
        //NSLog(@"使用系统定位");
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 1000.0f;
        [_locationManager startUpdatingLocation];
    }else{
        //提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请确认开启定位功能" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

//页面不上划
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

//禁止屏幕旋转
-(BOOL)shouldAutorotate{
    return NO;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
}

//定位成功
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //NSLog(@"定位成功");
    CLLocation *currLocation = [locations lastObject];
    txtLat = [NSString stringWithFormat:@"%3.16f",currLocation.coordinate.latitude];
    txtLng = [NSString stringWithFormat:@"%3.16f",currLocation.coordinate.longitude];
    txtAlt = [NSString stringWithFormat:@"%3.16f",currLocation.altitude];
    //NSLog(@"lat:%@;lng:%@",txtLat,txtLng);
    //获取当前所在城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    User *user = [[User alloc] init];
    __block CLPlacemark *placemark = nil;
    [geocoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *array,NSError *error) {
        if(array.count > 0){
            placemark = [array objectAtIndex:0];
            //NSLog(@"%@",placemark.name);
            //NSDictionary *location = [placemark addressDictionary];
            /*//NSLog(@"国家: %@",[location objectForKey:@"Country"]);
            //NSLog(@"城市: %@",[location objectForKey:@"State"]);
            //NSLog(@"区: %@",[location objectForKey:@"SubLocality"]);
            //NSLog(@"位置: %@",placemark.name);
            //NSLog(@"国家: %@",placemark.country);
            //NSLog(@"城市: %@",placemark.locality);
            //NSLog(@"区: %@",placemark.subLocality);
            //NSLog(@"街道: %@",placemark.thoroughfare);
            //NSLog(@"子街道: %@",placemark.subThoroughfare);*/
            //获取城市
            NSString *city = placemark.locality;
            if(!city){
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得(如果city为空，则可知为直辖市)
                city = placemark.administrativeArea;
            }
            //设定城市
            [user setUserInfo:@"cityname" value:city];
            //判断是否将定为信息保存到服务器
            NSString *username = [user getUserInfo:@"username"];
            NSString *lastLocateTime = [user getUserInfo:[NSString stringWithFormat:@"%@_locatetime",username]];
            NSDate *date = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
            NSDateComponents *d = [calendar components:unitFlags fromDate:date];
            if(lastLocateTime == nil || [@"" isEqualToString:lastLocateTime] || labs([[[lastLocateTime componentsSeparatedByString:@":"] objectAtIndex:0] intValue] - [d hour]) >= 2){
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setObject:[user getUserInfo:@"username"] forKey:@"APP_ID"];
                [dictionary setObject:placemark.name forKey:@"ADDRESS"];
                [dictionary setObject:placemark.locality forKey:@"CITY"];
                [dictionary setObject:txtLat forKey:@"LAT"];
                [dictionary setObject:txtLng forKey:@"LNG"];
                [user setUserInfo:@"lat" value:txtLat];
                [user setUserInfo:@"lng" value:txtLng];
                [self soap:@"LogService" methodName:@"baiduMapLog" fields:[Util transDictionaryToSoapMessage:dictionary]];
            }
            //NSLog(@"%@",city);
        }else if(error == nil && [array count] == 0){
            //NSLog(@"No results were returned");
        }else if(error != nil) {
            //NSLog(@"An error occured = %@",error);
        }
    }];
    //如果定位成功，就关闭定位
    if([txtLat intValue] > 0 && [txtLng intValue] > 0){
        [_locationManager stopUpdatingLocation];
    }
}
//定位失败
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //NSLog(@"定位失败,error: %@",error);
    User *user = [[User alloc] init];
    NSString *username = [user getUserInfo:@"username"];
    NSString *lastLocateTime = [user getUserInfo:[NSString stringWithFormat:@"%@_locatetime",username]];
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *d = [calendar components:unitFlags fromDate:date];
    if(lastLocateTime == nil || [@"" isEqualToString:lastLocateTime] || labs([[[lastLocateTime componentsSeparatedByString:@":"] objectAtIndex:0] intValue] - [d hour]) >= 2){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:[user getUserInfo:@"username"] forKey:@"APP_ID"];
        [dictionary setObject:error forKey:@"MSG"];
        [self soap:@"LogService" methodName:@"baiduMapLog" fields:[Util transDictionaryToSoapMessage:dictionary]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)soap:(NSString *)serviceName methodName:(NSString *)methodName fields:(NSString *)fields {
    //创建SOAP消息，内容格式就是网站上提供的请求报文的实体主体部分
    matchingElement = methodName;
    NSString *soapMsg = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" "
                         ">"
                         "<soap:Body>"
                         "<%@ xmlns=\"http://rd\">"
                         "%@"
                         "</%@>"
                         "</soap:Body>"
                         "</soap:Envelope>",methodName,fields,methodName];
    //将这个XML字符串打印出来
    //NSLog(@"%@",soapMsg);
    //创建URL，内容是前面的请求报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@/%@/%@"
                                       ,self.webservice_id
                                       ,self.webservice_port
                                       ,self.webservice_name
                                       ,self.webservice_subname
                                       ,serviceName]];
    //NSLog(@"创建请求");
    //根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMsg length]];
    //添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"application/soap+xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    //设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    
    //将SOAP消息加到请求中
    [req setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    [req setTimeoutInterval:30.0];
    
    [req addValue:methodName forHTTPHeaderField:@"SOAPAction"];
    //创建连接
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if(conn){
        webData = [NSMutableData data];
    }
}

//刚开始接受响应时调用
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response{
    //NSLog(@"刚开始接受响应");
    [webData setLength:0];
}

//每接受到一部分数据就追加到webData中
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *) data{
    //NSLog(@"追加数据");
    [webData appendData:data];
}

//出现错误时
-(void) connection:(NSURLConnection *) connection didFailWithError:(NSError *)error{
    conn = nil;
    webData = nil;
    //NSLog(@"connection - error:%@",error);
    NSString *result = @"";
    switch ([error code]) {
        case -1004://Could not connect to the server;
            result = @"连接应用服务器失败,请稍后重试";
            break;
        case -1001://The request timed out;
            result = @"服务器未响应";
            break;
        default:
            result = @"操作失败,请稍后重试";
            break;
    }
    //[self callJs:[Util checkedMessageOfJson:result code:(int)[error code]]];
    //[self callJs:[NSString stringWithFormat:@"{\"result\":{\"success\":\"false\",\"msg\":\"%@\",\"code\":\"%d\"}}",result,[error code]]];
}

//完成接受数据时调用
-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
    //NSLog(@"完成接受数据");
    //NSLog(@"webData length,%lu",(unsigned long)[webData length]);
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    //打印出得到的XML
    //NSLog(@"返回值:%@",theXML);
    //如果需要调用的返回方法不为空，则开始拼接字符串
    if(![self.resultMethod isEqualToString:@""]){
        if([theXML rangeOfString:@"Error report"].location != NSNotFound){
            [self callJs:[Util checkedMessageOfJson:@"操作失败，请检查应用服务设置"]];
        }else{
            jsonResult = [[NSMutableString alloc] initWithString:@""];
            //使用NSXMLParser解析出我们想要的结果
            xmlParser = [[NSXMLParser alloc] initWithData:webData];
            [xmlParser setDelegate:self];
            [xmlParser setShouldResolveExternalEntities:YES];
            [xmlParser parse];
        }
    }
}

//开始解析第一个元素名
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //如果是.*Return，表示一条数据开始
    if([elementName isEqualToString:[NSString stringWithFormat:@"%@Return",matchingElement]]){
        [jsonResult appendString:@"{"];
    }else if(![elementName isEqualToString:@"soapenv:Envelope"] &&
             ![elementName isEqualToString:@"soapenv:Body"] &&
             ![elementName isEqualToString:[[NSString alloc] initWithFormat:@"%@Response",matchingElement]]){
        if(!soapResults){
            soapResults = [[NSMutableString alloc] init];
        }
    }
}

//追加找到的元素值，一个元素值可能要分几次追加
-(void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string{
    [soapResults appendString:string];
}

//结束解析这个元素名
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    //如果是.*Return，表示一条数据结束
    if([elementName isEqualToString:[NSString stringWithFormat:@"%@Return",matchingElement]]){
        [jsonResult setString:[jsonResult substringToIndex:[jsonResult length] - 1]];
        [jsonResult appendString:@"},"];
    }else if(![elementName isEqualToString:@"soapenv:Envelope"] &&
             ![elementName isEqualToString:@"soapenv:Body"] &&
             ![elementName isEqualToString:[[NSString alloc] initWithFormat:@"%@Response",matchingElement]]){
        [jsonResult appendString:[[NSString alloc] initWithFormat:@"\"%@\":\"%@\",",elementName,soapResults]];
        [soapResults setString:@""];
    }
}

//解析整个文件结束后
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    if(soapResults){
        soapResults = nil;
    }
    //NSLog(@"解析完毕");
    if(![jsonResult isEqualToString:@""]){
        [jsonResult setString:[jsonResult substringToIndex:[jsonResult length] - 1]];
        [jsonResult appendString:@",{}"];
    }
    [jsonResult appendString:@"]"];
    
    if([@"setUserInfo" isEqualToString:self.callMethod]){
        NSString *result = [[NSString alloc] initWithFormat:@"%@",jsonResult];
        result = [result substringToIndex:[result length] - 4];
        self.callMethod = @"";
        [self setUserInfo:result];
    }else if([@"getMainPic" isEqualToString:self.callMethod]){
        User *user = [[User alloc] init];
        [user setUserInfo:@"mainPic" value:[NSString stringWithFormat:@"{\"result\":[%@}",jsonResult]];
        self.callMethod = @"";
    }else if([@"uploadImageResult" isEqualToString:self.resultMethod]){
        self.picIndex = self.picIndex + 1;
        if(self.picIndex >= [imageData count]){
            [self callJs:@"{\"result\":\"true\"}"];
        }
    }else{
        NSString *result = [[NSString alloc] initWithFormat:@"{\"result\":[%@}",jsonResult];
        [self callJs:result];
        //NSLog(@"解析XML结果:%@",result);
    }
}

//出错时，例如强制结束解析
-(void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    if(soapResults){
        soapResults = nil;
    }
}


//IOS  头部信号栏 变白色
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  
    
    
    //去右侧的下拉滚动条
    for (UIView *_aView in [webView subviews])
    {
        if ([_aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO];
            //右侧的滚动条
            
            [(UIScrollView *)_aView setShowsHorizontalScrollIndicator:NO];
            //下侧的滚动条
            
            for (UIView *_inScrollview in _aView.subviews)
            {
                if ([_inScrollview isKindOfClass:[UIImageView class]])
                {
                    _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                }
            }
        }
    }
    //去掉弹簧效果
    for (id subview in webView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
        {
            ((UIScrollView *)subview).bounces = NO;
        }
    //var meta = document.createElement('meta');meta.name = 'viewport';meta.content = 'width=320,initial-scale=1.0,minimum-scale=0.1,maximum-scale=%@,user-scalable=yes';document.getElementsByTagName('head')[0].appendChild(meta);
    NSString *js_fit_code = [NSString stringWithFormat:@"$('body').css('padding-bottom','%@');document.documentElement.style.webkitTouchCallout='none';document.documentElement.style.webkitUserSelect='none';",self.scaleSize];
    [self.webView stringByEvaluatingJavaScriptFromString:js_fit_code];
    
    NSString *requestString = [[request URL] absoluteString];//获取请求的绝对路径.
    //NSLog(@"requestString:%@",requestString);
    NSRange range = [[requestString uppercaseString] rangeOfString:@"IOS_DRIVER://"];
    self.resultMethod = @"resultList";//初始化返回调用js方法
    if(range.location != NSNotFound){
        NSString *serviceName = [requestString substringFromIndex:range.location+range.length];
        NSArray *components = [serviceName componentsSeparatedByString:@"//"];//提交请求时候分割参数的分隔符
        if ([components count] >1) {
            NSString *serviceName = [components objectAtIndex:0];
            NSString *methodName = [components objectAtIndex:1];
            NSString *fields = [[components objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if([@"getPicDir" isEqualToString:methodName] && [fields rangeOfString:@"FUNC01"].location != NSNotFound){
                User *user = [[User alloc] init];
                NSString *mainPic = [user getUserInfo:@"mainPic"];
                if(![@"" isEqualToString:mainPic] && mainPic != nil){
                    [self callJs:mainPic];
                    return NO;
                }
            }
            //NSString *resultMethod = [components objectAtIndex:3];
            if([components count] == 4){
                self.resultMethod = [components objectAtIndex:3];
                //NSLog(@"%@",self.resultMethod);
            }
            [self soap:serviceName methodName:methodName fields:fields];
            return NO;
        }
    }
    if([[requestString uppercaseString] rangeOfString:@"PHOTO://"].location != NSNotFound){
        //图片预览
        range = [[requestString uppercaseString] rangeOfString:@"PHOTO://"];
        self.imageIndex = [requestString substringFromIndex:range.location + range.length];
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
        }
        pickerImage.delegate = self;
        pickerImage.allowsEditing = NO;
        [self presentViewController:pickerImage animated:YES completion:nil];
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"CALL://"].location != NSNotFound){
        //打电话
        range = [[requestString uppercaseString] rangeOfString:@"CALL://"];
        //NSLog(@"tel:%@",[[requestString substringFromIndex:range.location + range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel://%@",[[requestString substringFromIndex:range.location + range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }else if([[requestString uppercaseString] rangeOfString:@"CAMERA://"].location != NSNotFound){
        //相机
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [self callJs:@"{'result':'相机不可用'}"];
            return NO;
        }
        //sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
        //sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//图片库
        //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//保存的图片
        range = [[requestString uppercaseString] rangeOfString:@"CAMERA://"];
        self.imageIndex = [requestString substringFromIndex:range.location + range.length];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"USERINFO://"].location != NSNotFound){
        //获取用户信息
        User *user = [[User alloc] init];
        //NSLog(@"userInfo");
        range = [[requestString uppercaseString] rangeOfString:@"USERINFO://"];
        NSMutableString *result = [[NSMutableString alloc] init];
        [result appendString:@"{"];
        if(range.location+range.length == requestString.length){
            //说明没有参数
            NSMutableArray *userKeys = [[NSMutableArray alloc] init];
            [userKeys setObject:@"rememberflag" atIndexedSubscript:0];
            [userKeys setObject:@"cityname" atIndexedSubscript:1];
            [userKeys setObject:@"role_id" atIndexedSubscript:2];
            [userKeys setObject:@"lat" atIndexedSubscript:3];
            [userKeys setObject:@"lng" atIndexedSubscript:4];
            [userKeys setObject:@"iphoneversion" atIndexedSubscript:5];
            [userKeys setObject:@"address" atIndexedSubscript:6];
            [userKeys setObject:@"width" atIndexedSubscript:7];
            [userKeys setObject:@"height" atIndexedSubscript:8];
            [userKeys setObject:@"scale" atIndexedSubscript:9];
            NSMutableDictionary *userDictionary = [user getUserInfos:userKeys];
            RendaKeychain *keyChain = [[RendaKeychain alloc] init];
            [keyChain initWithKeys];
            if([keyChain load:keyChain.KEY_USERNAME] != nil){
                [userDictionary setObject:[keyChain load:keyChain.KEY_USERNAME] forKey:@"username"];
                [userDictionary setObject:[keyChain load:keyChain.KEY_PASSWORD] forKey:@"password"];
            }
            for(id x in userDictionary){
                [result appendFormat:@"\"%@\":\"%@\",",x,userDictionary[x]];
            }
            [result setString:[result substringToIndex:[result length] - 1]];
        }else{
            //说明获取指定的值
            NSString *name = [requestString substringFromIndex:range.location+range.length];
            [result appendFormat:@"'%@':'%@'",name,[user getUserInfo:name]];
        }
        [result appendString:@"}"];
        //NSLog(@"userInfo:%@",result);
        self.resultMethod = @"userInfoResult";
        [self callJs:[[NSString alloc] initWithFormat:@"{\"result\":%@}",result]];
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"SETUSERINFO://"].location !=NSNotFound){
        //设置用户信息
    }else if([[requestString uppercaseString] rangeOfString:@"UPLOADIMAGE://"].location != NSNotFound){
        //上传图片
        range = [[requestString uppercaseString] rangeOfString:@"UPLOADIMAGE://"];
        NSString *inputs = [requestString substringFromIndex:range.location+range.length];
        NSArray *components = [inputs componentsSeparatedByString:@"//"];
        //Util *util = [[Util alloc] init];
        self.resultMethod = @"uploadImageResult";
        self.picIndex = 0;
        for(id index in imageData){
            //[util uploadImage:[NSString stringWithFormat:@"http://%@:%@/%@/servlet/UploadFileServlet",self.webservice_id,self.webservice_port,self.webservice_name] user_id:[components objectAtIndex:0] index:index trs_id:[components objectAtIndex:1] role_id:[components objectAtIndex:2] delegate:self imageData:imageData imageName:imageName];
            [self uploadImage:[[NSString alloc] initWithFormat:@"http://%@:%@/%@/servlet/UploadFileServlet",self.webservice_id,self.webservice_port,self.webservice_name] user_id:[components objectAtIndex:0] index:index trs_id:[components objectAtIndex:1] role_id:[components objectAtIndex:2]];
        }
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"LOGIN://"].location != NSNotFound){
        //检查登陆用户名
        self.callMethod = @"setUserInfo";
        range = [requestString rangeOfString:@"LOGIN://"];
        NSString *jsonString = [[requestString substringFromIndex:range.location + range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        self.logInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if(error){
            //NSLog(@"error:%@",error);
        }
        if(self.logInfo != nil) {
            NSString *inputs = [[NSString alloc] initWithFormat:@"<%@>%@</%@><%@>%@</%@>",@"username",[self.logInfo objectForKey:@"username"],@"username",@"password",[self.logInfo objectForKey:@"password"],@"password"];
            [self soap:@"LoginService" methodName:@"doLogin" fields:inputs];
        }
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"GETWEBSERVICE://"].location != NSNotFound){
        //获取端口信息
        NSMutableString *webservice = [[NSMutableString alloc] init];
        [webservice appendString:@"{"];
        [webservice appendFormat:@"\"webservice_id\":\"%@\",",self.webservice_id];
        [webservice appendFormat:@"\"webservice_port\":\"%@\"",self.webservice_port];
        [webservice appendString:@"}"];
        [self callJs:webservice];
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"SETWEBSERVICE://"].location != NSNotFound){
        //设置端口信息(有效期:软件关闭之前)
        range = [[requestString uppercaseString] rangeOfString:@"SETWEBSERVICE://"];
        NSString *iport = [requestString substringFromIndex:range.location+range.length];
        //NSLog(@"%@",iport);
        if([iport rangeOfString:@"//"].location == NSNotFound){
            self.webservice_id = iport;
        }else{
            self.webservice_id = [iport substringToIndex:[iport rangeOfString:@"//"].location];
            self.webservice_port = [iport substringFromIndex:[iport rangeOfString:@"//"].location+[iport rangeOfString:@"//"].length];
        }
        self.resultMethod = @"setPortResult";
        [self callJs:@"{\"success\":\"true\"}"];
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"GETVERSION://"].location != NSNotFound){
        //获取版本号等一些软件的信息
        //获取项目名称
        //NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
        //获取项目版本号
        //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDictionary));
        //app名称
        //NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        //app版本
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        //app build版本
        //NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
        //NSLog(@"version:%@,%@,%@,%@,%@",executableFile,version,appName,appVersion,appBuild);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前版本号" message:appVersion delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
        [alert show];
        //[UIView animateWithDuration:0.5 animations:^{alert.alpha = 0.0;} completion:^(BOOL finished){[alert setHidden:YES];[alert dismissWithClickedButtonIndex:nil animated:YES];}];
    }else if([[requestString uppercaseString] rangeOfString:@"LOGOUT://"].location != NSNotFound){
        User *user = [[User alloc] init];
        [user remove:@"username"];
        [user remove:@"password"];
        [user remove:@"rememberflag"];
        //NSLog(@"logout");
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"GETWHETHER://"].location != NSNotFound){
        //返回天气信息  每天每个城市只会发送一次请求
        range = [[requestString uppercaseString] rangeOfString:@"GETWHETHER://"];
        NSMutableString *weatherJson = [[NSMutableString alloc]init];
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
        NSDateComponents *d = [calendar components:unitFlags fromDate:date];
        User *user = [[User alloc] init];
        NSString *httpArg = [requestString substringFromIndex:range.location+range.length];
        if([user getUserInfo:@"getWeatherTime"] != nil
           && [[user getUserInfo:@"getWeatherTime"] isEqualToString:[NSString stringWithFormat:@"%ld-%ld-%ld",(long)[d year],(long)[d month],(long)[d day]]]
           && [user getUserInfo:httpArg] != nil){
            [weatherJson setString:[user getUserInfo:httpArg]];
            self.resultMethod = @"weatherResult";
            [self callJs:weatherJson];
            return NO;
        }
        NSString *httpUrl = @"http://apis.baidu.com/heweather/weather/free";
        NSString *urlStr = [[NSString alloc] initWithFormat:@"%@?city=%@",httpUrl,httpArg];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        [request addValue:[APIKEY substringFromIndex:0] forHTTPHeaderField:@"apikey"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
            if(error){
                //NSLog(@"HttpError:%@%ld",error.localizedDescription,(long)error.code);
            }else{
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSRange range1 = [responseString rangeOfString:@"\"daily_forecast\""];
                NSRange range2 = [responseString rangeOfString:@"\"hourly_forecast\""];
                NSString *daily_forecast = [responseString substringWithRange:NSMakeRange(range1.location, range2.location - range1.location)];
                NSMutableArray *weatherResult2 = [[NSJSONSerialization JSONObjectWithData:[[[NSString alloc] initWithFormat:@"{%@}",daily_forecast] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error] objectForKey:@"daily_forecast"];
                if(error){
                    //NSLog(@"weatherJson --> json error:%@",error);
                }else{
                    //开始遍历天气
                    [weatherJson appendString:@"{\"result\":["];
                    for(int i=0;i<[weatherResult2 count]&&i<3;i++){
                        [weatherJson appendString:@"{"];
                        [weatherJson appendFormat:@"\"%@\":\"%@\",",@"MINTMP",[[[weatherResult2 objectAtIndex:i] objectForKey:@"tmp"] objectForKey:@"min"]];
                        [weatherJson appendFormat:@"\"%@\":\"%@\",",@"MAXTMP",[[[weatherResult2 objectAtIndex:i] objectForKey:@"tmp"] objectForKey:@"max"]];
                        [weatherJson appendFormat:@"\"%@\":\"%@\",",@"WINDDIR",[[[weatherResult2 objectAtIndex:i] objectForKey:@"wind"] objectForKey:@"dir"]];
                        [weatherJson appendFormat:@"\"%@\":\"%@\",",@"TXT_D",[[[weatherResult2 objectAtIndex:i] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        [weatherJson appendFormat:@"\"%@\":\"%@\"",@"TXT_N",[[[weatherResult2 objectAtIndex:i] objectForKey:@"cond"] objectForKey:@"txt_n"]];
                        [weatherJson appendString:@"},"];
                    }
                    [weatherJson setString:[weatherJson substringToIndex:[weatherJson length] - 1]];
                    [weatherJson appendString:@"]}"];
                    self.resultMethod = @"weatherResult";
                    [user setUserInfo:@"getWeatherTime" value:[NSString stringWithFormat:@"%ld-%ld-%ld",(long)[d year],(long)[d month],(long)[d day]]];
                    [user setUserInfo:httpArg value:weatherJson];
                    [self callJs:weatherJson];
                }
            }
        }];
        return NO;
    }else if([[requestString uppercaseString] rangeOfString:@"ALERT://"].location != NSNotFound){
        range = [[requestString uppercaseString] rangeOfString:@"ALERT://"];
        NSString *msg = [[requestString substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [Util dialog:@"" msg:msg delegate:self];
        return NO;
    }
    return YES;
}

-(void) setUserInfo:(NSString *)data{
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error){
        //NSLog(@"setUserInfo --> Json error:%@",error);
    }
    if([@"00" isEqualToString:[dictionary objectForKey:@"RESULT_FLAG"]]){
        RendaKeychain *keyChain = [[RendaKeychain alloc] init];
        //保存用户名和密码信息(加密)
        [keyChain initWithKeys];
        [keyChain save:keyChain.KEY_USERNAME data:[self.logInfo objectForKey:@"username"]];
        [keyChain save:keyChain.KEY_PASSWORD data:[self.logInfo objectForKey:@"password"]];
        //保存用户信息
        User *user = [[User alloc] init];
        [user setUserInfo:@"role_id" value:[dictionary objectForKey:@"ROLE_ID"]];
        [user setUserInfo:@"rememberflag" value:[self.logInfo objectForKey:@"rememberflag"]];
        [user setUserInfo:@"firstinstall" value:@"false"];
    }
    //NSLog(@"setUserInfo:%@",data);
    [self callJs:data];
}


-(void) uploadImage:(NSString *)url user_id:(NSString *)user_id index:(NSString *)index trs_id:(NSString *)trs_id role_id:(NSString *)role_id{
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
    NSURLConnection *mconn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //设置接受response的data；
    NSMutableData *responseData = [[NSMutableData alloc] init];
    //NSLog(@"uploadImage:11");
    if(mconn){
        responseData = [NSMutableData data];
    }
}

//调用网页JS
- (void) callJs:(NSString *)result{
    //NSLog(@"jsonResult:%@,method:%@",result,self.resultMethod);
    [self.webView stringByEvaluatingJavaScriptFromString:[[NSString alloc] initWithFormat:@"%@(%@)",self.resultMethod,result]];
}

//点击相册中的图片或者照相机照完后点击use动作时调用
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //NSLog(@"选择完毕");
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImage *newImage = nil;
            CGSize imageSize = image.size;
            CGFloat width = imageSize.width;
            CGFloat height = imageSize.height;
            CGFloat targetWidth = width/10;
            CGFloat targetHeight = height/10;
            CGFloat scaleFactor = 0.0;
            CGFloat scaledWidth = targetWidth;
            CGFloat scaledHeight = targetHeight;
            CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
            if(CGSizeEqualToSize(imageSize, CGSizeMake(targetWidth,targetHeight)) == NO){
                CGFloat widthFactor = targetWidth / width;
                CGFloat heightFactor = targetHeight / height;
                if(widthFactor > heightFactor)
                scaleFactor = widthFactor;
                else
                scaleFactor = heightFactor;
                scaledWidth = width*scaleFactor;
                scaledHeight = height*scaleFactor;
            }
            UIGraphicsBeginImageContext(CGSizeMake(targetWidth,targetHeight));
            CGRect thumbnailRect = CGRectZero;
            thumbnailRect.origin = thumbnailPoint;
            thumbnailRect.size.width = scaledWidth;
            thumbnailRect.size.height = scaledHeight;
            
            [image drawInRect:thumbnailRect];
            newImage = UIGraphicsGetImageFromCurrentImageContext();
            if(newImage == nil){
                //NSLog(@"cound not scale image");
            }
            UIGraphicsEndImageContext();
            
            NSData *data;
             if(UIImagePNGRepresentation(newImage) == nil){
             data = UIImageJPEGRepresentation(newImage, 1.3);
             }else{
             data = UIImagePNGRepresentation(newImage);
             }
             //文件管理器
             NSFileManager *fileManager = [NSFileManager defaultManager];
             NSArray *arry = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *path = [arry objectAtIndex:0];
             path = [path stringByAppendingPathComponent:@"Image"];
             if(![fileManager fileExistsAtPath:path]){
             [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
             }
             //图片保存的路径
             //把刚刚图片转换的data对象拷贝至沙盒中，并保存为image.png;
             NSString *fileName = [NSString stringWithFormat:@"%ld",time(NULL)];
             [fileManager createFileAtPath:[path stringByAppendingPathComponent:fileName] contents:data attributes:nil];
             //得到选择后沙盒中图片的完成路径
             imagePath = [path stringByAppendingPathComponent:fileName];
             //关闭相册界面
             [imageData setObject:data forKey:self.imageIndex];
             [imageName setObject:fileName forKey:self.imageIndex];
             //NSLog(@"{'result':'%@'}",imagePath);
             [self callJs:[[NSString alloc] initWithFormat:@"{'result':'%@'}",imagePath]];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//将原始图片的URL转化为NSData数据，写入沙盒
-(void)imageWithUrl:(NSURL *)url withFileName:(NSString *)fileName{
    //进这个方法的时候也应该加判断，如果已经转化了的就不要调用这个方法
    //如何判断已经转化了，通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    //创建存放原始图的文件夹 --> OriginalPhotoImages
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arry = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [arry objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"Image"];
    if(![fileManager fileExistsAtPath:path]){
        //NSLog(@"create");
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(url){
            //主要方法
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset){
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                Byte *buffer = (Byte *) malloc((unsigned long) rep.size);
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long) rep.size) error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                imagePath = [path stringByAppendingPathComponent:fileName];
                [data writeToFile:imagePath atomically:YES];
                [imageData setObject:data forKey:self.imageIndex];
                [imageName setObject:fileName forKey:self.imageIndex];
                //NSLog(@"count:%lu,%lu",(unsigned long)[imageName count],(unsigned long)[imageData count]);
                //通知主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"{'result':'%@'}",imagePath);
                    [self callJs:[[NSString alloc] initWithFormat:@"{'result':'%@'}",imagePath]];
                });
            } failureBlock:nil];
            
        }
        
    });
    ////NSLog([[NSString alloc] initWithFormat:@"{'result':'%@'}",imagePath]);
    //[self callJs:[[NSString alloc] initWithFormat:@"{'result':'%@'}",imagePath]];
}



@end
