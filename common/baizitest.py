# -*- coding:utf-8 -*-
import datetime, SolarTerms, JDatetime

if __name__ == '__main__':
    '''
    dt = datetime.datetime.strptime("2017-08-07 10:08:12", "%Y-%m-%d %H:%M:%S")
    Y = dt.year
    jdate = JDatetime.JDatetime(dt)
    t1 = 365.2422*(Y - 1999) - 50
    print 't1 = %s' %t1
    dongzhi = SolarTerms.jiaoCal(t1,-90,0)
    print 'dongzhi = %s'%dongzhi

    t = jdate.setFromJD(dongzhi+jdate.J2000 + 8/(24-0.0),1)

    print t
    '''
    print SolarTerms.rad2str(30,1)
    print SolarTerms.rad2str(40,0)

