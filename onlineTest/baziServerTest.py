# -*- coding:utf-8 -*-
import urllib
import urllib2
import cjson

def http_post():
    url='http://10.9.19.204:16888/app/v1/paiPan'

    data = {}
    data["birthday"]  = '1988-01-06 03:50:00'  #生日
    data["sex"]       = 1                      #性别
    data["astFlag"]   = 0                      #是否真太阳时
    data["longitude"] = 120                    #出生地级度
    data["calendar"]  = 12
    reqInfo = {}
    reqInfo['data'] = data

    jdata = cjson.encode(reqInfo)             # 对数据进行JSON格式化编码
    print jdata
    req = urllib2.Request(url, jdata)      # 生成页面请求的完整数据
    response = urllib2.urlopen(req)       # 发送页面请求
    return response.read()                # 获取服务器返回的页面信息

if __name__ == '__main__':
    resp = http_post()
    print resp
