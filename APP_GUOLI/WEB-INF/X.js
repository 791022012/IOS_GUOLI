var X={
init:function(){
    X.ajax({action:"userOrAdmin"},function(data){
           var json = X.toJson(data);
           if(json.success){
           location.href = X.url.home + json.href;
           }else{
           X.dialog(json.resultMsg);
           }
           });
},
/*
 * 该方法暂时弃用
 */
ajax:function(data,callback,url){
    var s = {};
    s.type="GET";
    s.url = X.isEmpty(url) ? "action.do" : url;
    s.data = data;
    s.success = callback;
    s.dataType= 'html';
    s.headers = {'apikey':'befde4c0558df3bac630b9e07c31be37'};
    //s.contentType = 'application/x-www-form-urlencoded;charset='+(X.isEmpty(charset) ? 'UTF-8' : charset);
    s.error = function(){
        X.dialog("请求发生异常，请重试");
    }
    $.ajax(s);
},
    /**
     *serviceAction:service类名
     *action:类名中的具体的方法名
     *href:返回数据后需要跳转的界面链接
     */
soap:function(data,serviceAction,action,href){
    if(X.isEmpty(serviceAction) || X.isEmpty(action)){
        X.dialog('服务名或方法名不能为空');
        return;
    }
    var url = 'IOS_DRIVER://' + serviceAction + '//' + action;
    if('object' == typeof data){
    	url = url + '//<Object>';
        if(!X.isEmpty(data)){
            for(var x in data){
                url = url + '<' + x + ' type="string" >' + data[x] + '</' + x + '>';
            }  
        }
        url = url + '</Object>';
    }else{
    	url = url + '//' + data;
    }
    if(!X.isEmpty(href)){
        url = url + '//' + href;
    }
    window.location = url;
},
//调用IOS相册
photo:function(index){
	var url = 'PHOTO://'+index;
	window.location = url;
},
//调用IOS相机
camera:function(index){
	var url = 'CAMERA://'+index;
	window.location = url;
},
//调用IOS打电话
call:function(phoneNumber){
    if(X.isTel(phoneNumber) || X.isLandLine(phoneNumber)){
        var url = 'CALL://' + phoneNumber;
        window.location = url;
    }else{
        X.dialog('号码有误');
        return;
    }
},
//获取端口信息
getWebservice:function(){
  var url = 'GETWEBSERVICE://';
    window.location = url;
},
//设置端口信息
setWebservice:function(ip,port){
    var url = 'SETWEBSERVICE://'+ip+(X.isEmpty(port)?'':'//'+port);
    window.location = url;
},
//获取用户信息
getUserInfo:function(name){
    var url = 'USERINFO://' + (X.isEmpty(name) ? '' : name);
    window.location = url;
},
//设置用户信息
setUserInfo:function(names){
	if(X.getObjLenOrCompare(names, 0)){
		var t = '{';
		for(var x in names){
			t = t + '\'' + x + '\':\'' + names[x] + '\',';
		}
		t = t.substring(0,t.length - 1);
		var url = 'SETUSERINFO://' + t + '}';
		window.location = url;
	}
},
//获取版本号等信息
getVersion:function(){
  var url = 'GETVERSION://';
    window.location = url;
},
//用户登陆
chkUserAndSetUserInfo:function(data){
	var url = 'LOGIN://{';
	for(var x in data){
		url = url + '\"' + x + '\":\"' + data[x] + '\",';
	}
	url = url.substring(0,url.length - 1);
	url = url + '}';
	window.location = url;
},
logout:function(){
    var url = 'LOGOUT://';
    window.location = url;
},
//上传图片
uploadImage:function(user_id,trs_id,role_id){
    var url = 'UPLOADIMAGE://'+user_id+'//'+trs_id+'//'+role_id;
    window.location = url;
},
/*
 * 获取天气,单词有误,暂不修改
 */
getWhether:function(cityName){
	var url = 'GETWHETHER://'+encodeURIComponent(cityName);
	window.location = url;
},
getWeatherImg:function(weatherDes){
    if(weatherDes.indexOf('多云') != -1 || weatherDes.indexOf('晴') != -1){
        return 's_1.png';
    }else if(weatherDes.indexOf('多云') != -1 && weatherDes.indexOf('阴') != -1){
        return 's_2.png';
    }else if(weatherDes.indexOf('阴') != -1 && weatherDes.indexOf('雨') != -1){
        return 's_3.png';
    }else if(weatherDes.indexOf('晴') != -1 && weatherDes.indexOf('雨') != -1){
        return 's_12.png';
    }else if(weatherDes.indexOf('晴') != -1 && weatherDes.indexOf('雾') != -1){
        return 's_12.png';
    }else if(weatherDes.indexOf('晴') != -1) return 's_13.png';
    else if(weatherDes.indexOf('多云') != -1) return 's_2.png';
    else if(weatherDes.indexOf('阵雨') != -1) return 's_3.png';
    else if(weatherDes.indexOf('小雨') != -1) return 's_3.png';
    else if(weatherDes.indexOf('中雨') != -1) return 's_4.png';
    else if(weatherDes.indexOf('大雨') != -1) return 's_5.png';
    else if(weatherDes.indexOf('暴雨') != -1) return 's_5.png';
    else if(weatherDes.indexOf('冰雹') != -1) return 's_6.png';
    else if(weatherDes.indexOf('雷阵雨') != -1) return 's_7.png';
    else if(weatherDes.indexOf('小雪') != -1) return 's_8.png';
    else if(weatherDes.indexOf('中雪') != -1) return 's_9.png';
    else if(weatherDes.indexOf('大雪') != -1) return 's_10.png';
    else if(weatherDes.indexOf('暴雪') != -1) return 's_10.png';
    else if(weatherDes.indexOf('扬沙') != -1) return 's_11.png';
    else if(weatherDes.indexOf('尘沙') != -1) return 's_11.png';
    else return 's_12.png';
},
dialog:function(resultMsg){
    if(typeof resultMsg == 'undefined' || 'undefined' == resultMsg) return;
     window.location = 'ALERT://'+encodeURIComponent(resultMsg);
},
confirm:function (opciones,callback){
    if ( !opciones || typeof opciones != 'object' ) { opciones = {}  }
    if ( !opciones['title'] ) { opciones['title'] = ''; }
    if ( !opciones['message'] ) { opciones['message'] = '途易行'; }
    if ( !opciones['button1'] ) { opciones['button1'] = '确定'; }
    if ( !opciones['button2'] ) { opciones['button2'] = '取消'; }
    if ( !callback ) { callback = null ; }
    $('body').append( $('<div>').attr('id','iOSdialogBoxLockScreen') )
    .append(
            $('<div>').attr('id','iOSdialogBoxWindow')
            .append( $('<div>').attr('id','iOSdialogBoxWindowTitle').html( opciones['title'] ) )
            .append( $('<div>').attr('id','iOSdialogBoxWindowMessage').html( opciones['message'] ) )
            .append( $('<div>').attr('id','iOSdialogBoxWindowButtons')
                    .append(
                            $('<div>').attr('class','iOSdialogBoxButton')
                            .css('float','left')
                            .append(
                                    $('<div>').html( opciones['button1'] )
                                    .click(function(e){
                                           $('#iOSdialogBoxLockScreen').remove();
                                           $('#iOSdialogBoxWindow').remove();
                                           if(callback != null) callback();
                                           })
                                    )
                            )
                    .append(
                            $('<div>').attr('class','iOSdialogBoxButton')
                            .css('float','right')
                            .append(
                                    $('<div>').html( opciones['button2'] )
                                    .click(function(e){
                                           $('#iOSdialogBoxLockScreen').remove();
                                           $('#iOSdialogBoxWindow').remove();
                                           })
                                    )
                            )
                    )
            );
    var	altura = $('.iOSdialogBoxButton div').height(); altura /= 2 ; altura *= -1 ; altura += 'px' ;
    $('.iOSdialogBoxButton div').css('margin-top',altura);
},
toJson:function(data){
    //		return JSON.parse(data);
    //		return $.parseJSON(data);
    return eval('('+data+')');
},
isEmpty:function(v){
    switch (typeof v){
		case 'undefined':
			return true;
		case 'string':
			if(X.trim(v).length == 0) return true;
            break;
		case 'boolean':
			if(!v) return true;
            break;
		case 'number':
			if(0 === v || isNaN(v)) return true;
            break;
		case 'object':
			if(v === null || v.length === 0 || (v.length === 1 && X.trim(v[0]).length == 0)) return true;
			for(var i in v){
				return false;
			}
			return true;
    }
	return false;
},
copyObj:function(fromData,toData){
	if(X.getObjLenOrCompare(fromData, 0)){
		for(var x in fromData){
			toData[x] = fromData[x];
		}
	}
},
	//手机号
isTel:function(v){
    return !X.isEmpty(v) && (/((\+86)|(0086)|(86))?[ ]*[1-9][0-9]{10}/g).test(X.trim(v)) && v.length == 11;
},
	//固定电话
isLandLine:function(v){
    return (/[0-9^ ]{3,4} *-? *[1-9][0-9^ ]{6,7}/g).test(X.trim(v));
},
	//身份证
isIdCard:function(v){
    return (/(\d{18}|[0-9^ ]{14}[0-9X])/g).test(X.trim(v));
},
	//email
isEmail:function(v){
    
},
trim:function(v){
    return v.replace(/^[ \t\r\n]*/g,'').replace(/[ \r\t\n]*$/g,'');
},
delSpaceArrayEle:function(v,matchedEle){
    var count = 0;
    for(var i = v.length - 1;i>=0;i--){
        if(v[i] == matchedEle){
            count ++;
        }else{
            if(count > 0){
                v.splice(i+1,count);
                count = 0;
            }
        }
    }
},
toUpperAtPos:function(v,index,len){  //将给定长度的一段字符串转换成大写
    if(X.isEmpty(v)) return;
    if(X.isEmpty(index)) index = 0;
    if(X.isEmpty(len)) len = v.length;
    v = X.trim(v);
    return v.substring(0,index)+v.substring(index,index+len).toUpperCase()+v.substring(index+len);
},
toLowerAtPos:function(v,index,len){  //将给定长度的一段字符串转换成小写
    if(X.isEmpty(v)) return;
    if(X.isEmpty(index)) index = 0;
    if(X.isEmpty(len)) len = v.length;
    v = X.trim(v);
    return v.substring(0,index)+v.substring(index,index+len).toLowerCase()+v.substring(index+len);
},
loadXMLDoc:function(dname){
    try {//Internet Explorer
        xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
    }catch(e){
        try{ //Firefox, Mozilla, Opera, etc.
		    xmlDoc=document.implementation.createDocument("","",null);
        }catch(e) { X.dialog(e.message)}
    }
    try{
        xmlDoc.async=false;
        xmlDoc.load(dname);
        return(xmlDoc);
    }catch(e) { X.dialog(e.message)}
    return(null);
},
//比较json对象的键值对个数和给定数值的大小，如果com空，则返回data的键值对个数
getObjLenOrCompare:function(data,com){
    var size = 0;
    if(!X.isEmpty(data)){
        for(var x in data){
            size ++;
        }
        if(!X.isEmpty(com)){
            if(size > com) return true;
            else return false;
        }
    }
    return size;
}
}
X.html={
disBtn:function(names,boos){
    if(names.indexOf(",") >= 0){
        var name = names.split(',');
        var boo = boos.split(',');
        for(x in name){
            $('input[name="'+name[x]+'"]').attr('disabled',boo[x]);
        }
    }else{
        $('input[name="'+names+'"]').attr('disabled',boos);
    }
},
	//data:json数组格式
getSelect:function(data,flag){
    var t = new Text();
    t._('<option value="">请选择</option>');
    if(!X.isEmpty(data)){
        if(typeof data[0] == 'object'){
            for(x in data){
                t._('<option value="'+data[x].id+'">'+data[x].name+'</option>');
            }
        }else{
            for(var x=0;x < data.length;x++){
                t._('<option value="'+data[x]+'">'+data[++x]+'</option>');
            }
        }
    }
    if(!flag) t.prepend('<select>')._('</select>');
    return t.toString();
},
	//获取拥有两行明细的格式代码
getDoubleLinesDetails:function(){
    var t = new Text();
    t._('<div style="width:100%">')
    ._('<div style="width:100%;height:5px;margin-left:10px;margin-right:5px;background-color:#FFFFFF"></div>')
    ._('<span style="width:100%;font-size:1.5em;margin-left:25px">测试1</span>')
    ._('<div style="width:100%;height:1px;margin-left:20px;margin-right:8px;background-color:#FFFFFF"></div>')
    ._('<span style="width:100%;font-size:1.2em;marginleft:25px">测试2</span>')
    ._('</div>');
    return t.toString();
},
getTableTrs:function(cls){
    if(X.isEmpty(cls)) cls = 'table';
    var cols = $('.'+cls+' thead th').size();
    if(cols < 1) return '';
    var t = '';
    t = t + '<tr>';
    for(var i=0;i<cols;i++){
        t = t + '<td></td>';
    }
    t = t + '</tr>';
    return t.toString();
},
getTableTrsWithCheckbox:function(cls){
    if(X.isEmpty(cls)) cls = 'table';
    var cols = $('.'+cls+' thead th').size();
    if(cols < 1) return '';
    var t = '';
    t = t + '<tr>' + '<td style="text-align:center;"><input type="checkbox"/></td>';
    for(var i=0;i<cols-1;i++){
        t = t + '<td></td>';
    }
    t = t + '</tr>';
    return t;
},
getUnfocusedPic:function(){
    var t = new Text();
    t._('<img src="icon_addpic_unfocused.png" onclick="a();"/>');
    return t.toString();
},
/**
 * result:要放入table的数据;
 * trBody:一行table的html代码;
 * cls:table的样式:不必须,默认:table
 * 适用一条数据占一个tr
 */
putDataIntoTable:function(){
    var result,trBody,cls,emptyFlag,funcObj;
    for(var i=0;i<arguments.length && i<5;i++){
        switch(typeof arguments[i]){
            case 'object':
                if((arguments[i] instanceof Array) || !X.isEmpty(arguments[i].success)) result = arguments[i];
                else funcObj = arguments[i];
                break;
            case 'string':
                if(arguments[i].indexOf('<td>') >= 0) trBody = arguments[i];
                else cls = arguments[i];
                break;
            case 'boolean':
                emptyFlag = arguments[i];
                break;
        }
    }
    if(X.isEmpty(cls)) cls = 'table';
    //判断是否连接错误
    if(!X.isEmpty(result.success) && 'false' == result.success){
        $('.'+cls+' tbody').empty();
        var size = 0;
        if(X.isEmpty(trBody)){
            size = $('.'+cls+' thead th').size();
        }else{
            size = (trBody.split('td').length - 1)/2;
        }
        $('.'+cls+' tbody').append('<tr><td colspan="'+size+'">'+result.msg+'</td></tr>');
        $('.overlayX').css('display','none');
        return false;
    }
    //将result封装成一个Array,如果原来不是Array的话,方便遍历
	if(!(result instanceof Array)){
		if(X.getObjLenOrCompare(result, 0)){
			var array = new Array();
			array[0] = result;
			result = array;
		}
	}
    //判断是否有数据
    if(result.length == 0){
        $('.'+cls+' tbody').empty();
        var size = 0;
        if(X.isEmpty(trBody)){
            size = $('.'+cls+' thead th').size();
        }else{
            size = (trBody.split('td').length - 1)/2;
        }
        $('.'+cls+' tbody').append('<tr><td colspan="'+size+'">未找到任何数据</td></tr>');
        $('.overlayX').css('display','none');
        return false;
    }
    //如果不提供填充模板,就在thead中寻找
	if(X.isEmpty(trBody)){
		trBody = X.html.getTableTrs(cls);
	}
    //如果模板为空,则不填充
    if(X.isEmpty(trBody)){
        X.dialog('未找到有效的数据模板');
        $('.overlayX').css('display','none');
        return false;
    }
    //开始填充数据
	$('.'+cls).each(function(){
		var table = $(this);
		if(X.isEmpty(emptyFlag)) table.find('tbody').empty();
		for(var i=0;i<result.length;i++){
			if(!X.getObjLenOrCompare(result[i], 0)) continue;
			table.find('tbody').append(trBody);
		var tr = table.find('tbody').find('tr:last');
		table.find('thead').find('tr').find('th').each(function(){
			if(!X.isEmpty(this.id)){
				if(this.id == 'TRS_ID' || this.id == 'SO_ID'){
					tr.find('td').eq($(this).index()).text(result[i][this.id].substring(6));
				}else{
					tr.find('td').eq($(this).index()).text(result[i][this.id]);
				}
				
			}
		});
		}
       //改变checkbox的选择样式,整行改变
	   table.find('tbody input[type="checkbox"]').click(function(){
		   if($(this).is(':checked')){
			   $(this).parent().parent().addClass('selectedTr');
		   }else{
			   $(this).parent().parent().removeClass('selectedTr');
		   }
	   });
                    if(X.getObjLenOrCompare(funcObj,0)){
                    for(var x in funcObj){
                    $(x).click(funcObj[x]);
                    }
                    }
	});
    $('.overlayX').css('display','none');
    return true;
},
/*
 * 该方法暂时弃用
 * result:要放入table的数据;
 * trBody:一行table的html代码:不必须,如果为空，则取头表的html代码插入tbody
 * cls:table的样式:不必须
 * 适用一条数据占用多个tr
 */
putDataIntoMutableTable:function(result,trBody,cls){
	if(!result instanceof Array){
		if(X.getObjLenOrCompare(result, 0)){
			var array = new Array();
			array[0] = result;
			result = array;
		}else{
             X.dialog('未找到任何数据');
            return;
        }
	}
	if(X.isEmpty(cls)) cls = 'table';
	if(X.isEmpty(trBody)){
		$('.'+cls).each(function(){
			var table = $(this);
			var tbody = table.find('thead').html();
			for(var i = 0;i<result.length;i++){
				if(!X.getObjLenOrCompare(result[i], 0)) continue;
				table.find('tbody').append(tbody);
				$(this).find('thead td').each(function(){
					var clas = $(this).attr('class');
					if(X.isEmpty(clas) || clas.split(' ').length <= 1) return true;
					table.find('tbody').find('.'+clas+':last').text(result[i][clas.split(' ')[1]]);
				});
			}
		});
	}else{
		$('.'+cls).each(function(){
			var table = $(this);
			//获取thead中有几行tr
			var theadTrs = table.find('thead > tr').size();
			if(theadTrs <= 0){
				X.dialog('thead中没有tr,无法插入数据');
				return true;
			}
			//获取当前table的tbody中已经有的tr行数，方便分页扩展
			var tbodyTrs = table.find('tbody > tr').size();
			for(var i =0;i<result.length;i++){
				if(!X.getObjLenOrCompare(result[i], 0)) continue;
				table.find('tbody').append(trBody);
				//遍历thead中的每个tr
				table.find('thead').find('tr').each(function(){
					//获取当前tr在thead中的index
					var trIndex = $(this).index();
					//遍历当前tr中的每个td
					$(this).find('td').each(function(){
						if(!X.isEmpty(this.id)){
							table.find('tbody').find('tr')
							//eq()中:头表中tr的行数*当前遍历的数据下标+遍历的头表tr的index+原本tbody中残留的tr数
							.eq(theadTrs*i + trIndex + tbodyTrs).find('td')
							.eq($(this).index()).text(result[i][this.id]);
						}
					});
				});
			}
		});
	}
},
/**
 * 将数据放入div块
 * @param result 数组数据
 * @param cls	要放入数据的div块的cls(最外一层)
 */
putDataIntoDiv:function(){
    var result,cls,emptyFlag,funcObj;
    for(var i=0;i<arguments.length && i<4;i++){
        switch(typeof arguments[i]){
            case 'object':
                if((arguments[i] instanceof Array) || !X.isEmpty(arguments[i].success)) result = arguments[i];
                else funcObj = arguments[i];
                break;
            case 'string':
                cls = arguments[i];
                break;
            case 'boolean':
                emptyFlag = arguments[i];
                break;
        }
    }
    if(X.isEmpty(cls)) cls = 'detailBody';
    if($('.'+cls).length <= 0){
		$('body').append('<div class="'+cls+'"></div>');
	}
    //判断是否出现连接错误
    if(!X.isEmpty(result.success) && 'false' == result.success){
        $('.'+cls).empty();
        $('.'+cls).append('<div class="divTable" style="text-align:center">'+result.msg+'</div>');
        $('.overlayX').css('display','none');
        return false;
    }
    if(X.isEmpty(emptyFlag)){
        $('.'+cls).empty();
    }
    //如果result不是一个Array,就将Array封装成一个Array,方便遍历
	if(!result instanceof Array){
		if(X.getObjLenOrCompare(result, 0)){
			var array = new Array();
			array[0] = result;
			result = array;
		}
	}
    //判断result是否为空
    if(result.length == 0){
        $('.'+cls).append('<div class="divTable" style="text-align:center">未找到任何数据</div>');
        $('.overlayX').css('display','none');
        return false;
    }
    //查找模板Div,以便填充数据
	var divBody = $('.detailBodyModel').html();
	if(X.isEmpty(divBody)){
		X.dialog('未能获取有效的数据填充区域');
        $('.overlayX').css('display','none');
		return false;
	}
    //开始填充数据
	$('.'+cls).each(function(){
		var div = $(this);
        //遍历数据
		for(var i=0;i<result.length;i++){
			if(!X.getObjLenOrCompare(result[i], 0)) continue;
			div.append(divBody);
            //遍历模板中的div
			$('.detailBodyModel div').each(function(){
				var clas = $(this).attr('class');
				if(X.isEmpty(clas) || clas.split(' ').length <= 1) return true;
				var value = result[i][clas.split(' ')[1]];
                //对TRS_ID或SO_ID截取
				if(clas.indexOf(' TRS_ID') >= 0 || clas.indexOf(' SO_ID') >= 0){
					value = result[i][clas.split(' ')[1]].substring(6);
				}
                //填充动作
                if($('.'+cls + ' .'+clas.replace(' ','.')+':last').find('span').length > 0){
                    $('.'+cls + ' .'+clas.replace(' ','.')+':last').find('span').text(value);
                }else if($('.'+cls + ' .'+clas.replace(' ','.')+':last').find('strong').length > 0){
                	$('.'+cls + ' .'+clas.replace(' ','.')+':last').find('strong').text(value);
                }else{
                    $('.'+cls + ' .'+clas.replace(' ','.')+':last').html(value);
                }
			});
		}
        if(X.getObjLenOrCompare(funcObj,0)){
            for(var x in funcObj){
                $(x).click(funcObj[x]);
            }
        }
	});
    $('.overlayX').css('display','none');
    return true;
},
getInputs:function(){
	var src = window.location.href;
	var data = {};
    if(src.indexOf('?inputs') > -1){
        var inputs = src.substr(src.indexOf('?inputs') + '?inputs'.length + 1).split('&');
        for(var i=0;i<inputs.length;i++){
            data[decodeURIComponent(inputs[i].split('=')[0])] = inputs[i].split('=').length > 1 ? decodeURIComponent(inputs[i].split('=')[1]) : '';
        }
    }
	return data;
},
setInputs:function(data,toHtml){
    var href = '';
    if(X.getObjLenOrCompare(data,0)){
        href = href + '?inputs';
        for(var x in data){
            href = href + '&' + encodeURIComponent(x) + '=' + encodeURIComponent(data[x]);
        }
    }
    if(!X.isEmpty(toHtml)){
        href = toHtml + href;
    }
    return href;
},
goBack:function(){
	window.history.back();
},
goHome:function(){
	window.location.href = "main.html";
},
connError:function(data,b){
    if(!X.isEmpty(data) && !X.isEmpty(data.result) && !X.isEmpty(data.result.success) && 'false' == data.result.success){
        //X.dialog(data.result.msg);
        $('.overlayX').css('display','none');
        return true;
    }
    if(X.isEmpty(b)) $('.overlayX').css('display','none');
    return false;
},
setOverlay:function(txt){
    var t = '正在加载数据...';
    if(typeof txt == 'number'){
        switch(txt){
            case 0:
                t = '正在提交数据...';
                break;
            case 1:
                t = '正在查询天气...';
                break;
        }
    }else if(!X.isEmpty(txt)){
        t = txt;
    }
    if($('.overlayX').length <= 0) $('body').append('<div class="overlayX"><div><img src="loading.gif"/><span>'+t+'</span></div></div>');
    $('.overlayX').css('display','block');
},
removeOverlay:function(cls){
    if(X.isEmpty(cls)) cls = 'overlayX';
    $('.'+cls).css('display','none');
}
}
X.array={
contain:function(data,v){
    for(x in data){
        if(data[x] == v) return true;
    }
    return false;
}
}
X.cookie={
set:function(cookies,expiredays){
    if(X.isEmpty(cookies)) return;
    var date = new Date();
    date.setDate(date.getDate() + expiredays);
    for(var x in cookies){
    	document.cookie = x + '=' + escape(cookies[x]) + (X.isEmpty(expiredays) ? "" : ";expires="+date.toGMTString());
    }
},
get:function(name){
    if(X.isEmpty(name)) return '';
    if(document.cookie.length>0){
        var c_start = document.cookie.indexOf(name+'=');
        if(c_start >= 0){
            c_start = c_start + name.length + 1;
            var c_end = document.cookie.indexOf(';',c_start);
            if(c_end < 0) c_end = document.cookie.length;
            return unescape(document.cookie.substring(c_start,c_end));
        }
    }
    return '';
}
}
X.snail=function(){
    //$('.snail').animate({"margin-left":"80%"},15000);
}
X.city={
blur:function(id,callback){
    if(/[\u4e00-\u9fa5]/g.test($('#city_name').val())){
        //if(1 != citynames[$('#city_name').val()]) return;
        $('#'+id).text($('#city_name').val());
        if(typeof callback == 'function') callback();
    }
    $('.overlayCity').css('display','none');
    },
keyup:function(e){
        var v = $('#city_name').val();
        $('#citys ul').empty();
        var t;
        if(/[\u4e00-\u9fa5]/g.test(v)){
            t = new RegExp('^'+v+'.*','i');
        }else{
            t = new RegExp('.*?\\|'+v+'.*','i');
        }
        if(v != ''){
            var j = 0;
            for(var i=0;i<cities.length;i++){
                if(t.test(cities[i].match)){
                    $('#citys ul').append('<li class="'+(j%2 == 0?'ac_even':'ac_odd')+'">'+cities[i].name+'</li>');
                    j++;
                }
            }
        }
    },
showCitySelection:function(id){
        $('.overlayCity').css('display','block');
        $('#city_name').val('');
        $('#citys ul').empty();
        $('#city_name').focus();
        city_id = id;
    }
}