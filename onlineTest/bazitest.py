# -*- coding:utf-8 -*-
import datetime, SolarTerms, JDatetime
import ast
import math
import Bazi


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

    #print SolarTerms.rad2str(30,1)
    #print SolarTerms.rad2str(40,0)
    '''

    '''
    #test for JDatetime.py
    dt = datetime.datetime.strptime("2017-08-21 20:12:03", "%Y-%m-%d %H:%M:%S")

    jdate = JDatetime.JDatetime(dt)
    print 'test function dt_ext....'

    res = jdate.dt_ext(2017,20)
    print 'the function dt_ext result is:%s' %res


    print 'test function dt_calc....'
    res = jdate.dt_calc(2017)
    print 'the function dt_calc result is:%s' %res

    print 'test function toJD....'
    result1 = jdate.toJD(1)
    print 'the function toJD test1 result is: %s' %result1
    result2 = jdate.toJD(0)
    print 'the function toJD test2 result is: %s' %result2

    print 'test function setFromJD....'
    res = jdate.setFromJD(result1,1)
    print 'the function setFromJD test1 result is: %s' %res
    res = jdate.setFromJD(result2,0)
    print 'the function setFromJD test2 result is: %s' %res

    print 'test function Dint_dec....'
    res = jdate.Dint_dec(result1,8,1)
    print 'the function Dint_dec test1 result is: %s'%res
    res = jdate.Dint_dec(result2,8,0)
    print 'the function Dint_dec test2 result is: %s' %res
    '''

    '''
    #test for ast.py
    print 'test function rad2mrad....'
    result = ast.rad2mrad(1.5*math.pi)
    print 'the function rad2mrad test1 result is:%s' %result

    result = ast.rad2mrad(-1.37*math.pi)
    print 'the function rad2mrad test2 result is:%s' %result

    print 'test function rad2rrad....'
    result = ast.rad2rrad(1.5*math.pi)
    print 'the function rad2rrad test1 result is:%s' %result
    result = ast.rad2rrad(-1.37*math.pi)
    print 'the function rad2rrad test2 result is:%s' %result

    dt = datetime.datetime.strptime("2017-08-22 18:04:56", "%Y-%m-%d %H:%M:%S")
    print 'test function calc_AST....'
    result = ast.calc_AST(dt,120)
    print 'the function calc_AST test1 result is:%s' %result
    '''
    '''
    bd = [2017,8,7,10,8,12]
    res, resStr = SolarTerms.Lunar2Solar(bd,1)
    print res,resStr
    '''

    dt = datetime.datetime(1988,1,6,3,50,0)
    bz = Bazi.bazi(dt,1,0,120,12)
    bz.Paipan()
    res = bz.print_8zi()
    print res
    res = bz.Get8zi()
    print res
    res = bz.print_8zi()
    print res

    res = bz.print_mst()
    print res

    res = bz.print_lunar()
    print res

    res = bz.print_age()
    print res

    res = bz.print_lifa()
    print res

    res = bz.render_bazi()
    print res

    res = bz.render_dayun()
    print res

    '''
    res = bz.SolarDaysFromBaseYear(dt)
    print res

    res = bz.GetJiaoYunDate()
    print res

    b,k = SolarTerms.bk_calc(dt,11)
    print b,k
    '''
