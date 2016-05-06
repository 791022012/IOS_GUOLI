// JavaScript Document

$(document).ready(function(){
	function GetQueryString(name) { 
		var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i"); 
		var r = window.location.search.substr(1).match(reg);  //获取url中"?"符后的字符串并正则匹配
		var context = ""; 
		if (r != null) 
			 context = unescape(r[2]); 
		reg = null; 
		r = null; 
		return context == null || context == "" || context == "undefined" ? "" : context; 
	}
  
$("#zhongdianchengshi").text(GetQueryString("txt")==""?'点击选择终点城市':GetQueryString("txt"));
	
$('#dianjizhongdianchengshi').click(function() {
		window.location.href="CityList.html?action=PublishingreSources";
	});	 
});


























