function Text(){
	this.txt = "";
	this._ = function(txt){
		this.txt += txt;
		return this;
	}
	this.toString = function(){
		return this.txt.toString();
	}
	this.close = function(){
		this.txt = "";
		return this;
	}
	this.prepend = function(v){
		this.txt = v + this.txt.toString();
		return this;
	}
}

function Map(){
	this.map = {};
	this.m = function(key,value){
		if(typeof value == 'undefined'){
			return map[key];
		}else{
			map[key] = value;
			return this;
		}
	}
}

function a(){
	 X.dialog('点击功能可以使用');
}


var cityChange= eval(cityChange);
$(function(){
 $('#index_province').change(function(){
    for(var i in cityChange){
        if(i==this.value){
           var index_city_obj = $('#index_city')[0];
           index_city_obj.innerHTML='';
           var obj = cityChange[i];
           for(var k in obj){
              if(obj[k].name){             
			  	index_city_obj.options[index_city_obj.options.length] = new Option( obj[k].name,obj[k].pinyin);
              }
           }
           break;
        }
    }
    
 });
})
$(function() {
	$('#city_name').autocomplete(cities, {
	max: 12, //列表里的条目数
	minChars: 0, //自动完成激活之前填入的最小字符
	width: 320, //提示的宽度，溢出隐藏
	scrollHeight: 300, //提示的高度，溢出显示滚动条
	matchContains: true, //包含匹配，就是data参数里的数据，是否只要包含文本框里的数据就显示
	autoFill: false, //自动填充
	minChars:1,
	formatItem: function(row, i, max) {
	return row.name + '（'+row.pinyin+'）';
	},
	formatMatch: function(row, i, max) {
	return row.match;
	},
	
	formatResult: function(row) {
	return row.name;
	},resultsClass:'search-text'
	}).result(function(event, row, formatted) {
		$("#hid_city_name").val(row.pinyin);
		$("#hid_real_city_name").val(row.name);
		$('#pop_cities').hide();
		});
});
function append_city(){
	$('#cityarea').show();
	if($("#citylist").text()==""){
		$("#citylist").append(cityarea);
	}
}
$(document).ready(function(){
	$(document).bind('click', hide_div);
});
   
function hide_div(e){
	var biaoqian = "click";
	var classname= $(e.target)[0].className;
	if(classname.indexOf('click')>'-1' ||$(e.target)[0].id=='city_name')
	return ;

	if($('#city_name').val()=='')
	{
		$('#city_name').val('请输入城市中文或拼音 / 点击选择城市');
		$('#city_name').css('color','#B7B7B7');
	}
	$("#cityarea").hide();
} 
//直接输入地址框的onblur事件
function input_blur()
{
	var value = $('#city_name').val();
	var all_city_val = $(".ac_over").text();
	
 	 if($.trim(value)!="" && /[\u4e00-\u9fa5]/g.test(value)){
		var city_url=window.location.search;
		var str=city_url.substring(8);
		window.location.href=str+".html?txt="+escape(value);//发送txt里面的内容
			
		}	
	
	if(all_city_val && all_city_val!="")
	{
		var str = all_city_val.substr(0,(all_city_val.length-1));
		strs=str.split("（");
		$("#hid_city_name").val(strs[1]);
		$("#hid_real_city_name").val(strs[0]);
		$("#city_name").val(strs[0]);
		$(".search-text").hide();
	}else if($.trim(value)==''&& $('#cityarea').css('display')=='none')
	{
		$('#city_name').val('请输入城市中文或拼音 / 点击选择城市');
		$('#city_name').css("color","#B7B7B7");
	}
}
    
//直接输入地址框的onkeyup事件
function input_keyup()
{
	var value = $('#city_name').val();
	if($('#hid_real_city_name').val()!=value || $('#hid_real_city_name').val()=='')
	{
		$('#cityarea').hide();
	}else if(value==$('#hid_real_city_name').val())
	{
		$('#cityarea').hide();
	}	
}
function check_input(){
	var value = $('#city_name').val();
	if(value==$('#hid_real_city_name').val() && $("#hid_city_name").val()!=""){
		return true;
	}
	return false;
}
/**
 * 字母页面内链
 *
 */
function letter_scroll(letter)
{
	 var obj = $("#c_"+letter);
	 $('html,body').animate({scrollTop: obj.offset().top}, 500);
}
/*
 * 用户点击城市后，城市名填入input框
*/
function change_city_val(city, pinyin_city)
{
	$('#city_name').css({ color: "#606060"});
	$('#city_name').val(city);
	$('#hid_city_name').val(pinyin_city);
	$("#hid_real_city_name").val(city);
	$('#cityarea').hide();
}
function tabCutover(c,d){$(c).parent().attr("class");$(c).parent().children().removeClass("current");$(c).addClass("current");$("."+d).parent().children().hide();$("."+d).show();}