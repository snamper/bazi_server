# -*- coding:utf-8 -*-
import math
import datetime
import time

dts = (-4000, 108371.7, -13036.80, 392.000,  0.0000,
                    -500,  17201.0,  -627.82,   16.170,   0.3413,
                    -150,  12200.6,  -346.41,   5.403,   -0.1593,
                    150,   9113.8,   -328.13,  -1.647,   0.0377,
                    500,   5707.5,   -391.41,   0.915,    0.3145,
                    900,   2203.4,   -283.45,   13.034,  -0.1778,
                    1300,  490.1,    -57.35,    2.085,   -0.0072,
                    1600,  120.0,    -9.81,    -1.532,   0.1403,
                    1700,  10.2,     -0.91,     0.510,   -0.0370,
                    1800,  13.4,     -0.72,     0.202,   -0.0193,
                    1830,  7.8,      -1.81,     0.416,   -0.0247,
                    1860,  8.3,      -0.13,    -0.406,   0.0292,
                    1880,  -5.4,     0.32,     -0.183,   0.0173,
                    1900,  -2.3,     2.06,      0.169,   -0.0135,
                    1920,  21.2,     1.69,     -0.304,   0.0167,
                    1940,  24.2,     1.22,     -0.064,   0.0031,
                    1960,  33.2,     0.51,      0.231,   -0.0109,
                    1980,  51.0,     1.29,     -0.026,   0.0032,
                    2000,  63.87,    0.1,       0,        0,
                    2005,  64.7,     0.4,       0,        0,
                    2015,  69 )

J2000 = 2451545

def int2(v):  # 取整数部分,向零取整
    v = int(math.floor(v))
    if(v < 0):
        return v + 1
    else:
        return v


def dt_ext(y,jsd):
    dy = (y - 1820)/(100-0.0)
    return jsd*dy*dy - 20

def dt_calc(y):
    y0 = dts[len(dts)-2]
    t0 = dts[len(dts)-1]
    if y >= y0:
        jsd = 31
        if y > (y0 + 100):
            return dt_ext(y,jsd)
        v = dt_ext(y,jsd)
        dv = dt_ext(y0,jsd) - t0
        return v - dv*(y0 + 100 -y)/(100 - 0.0)

    i = 0
    while y >= dts[i+5]:
        i += 5
    t1 = (y - dts[i])/(dts[i+5] - dts[i] - 0.0) * 10
    t2 = t1*t1
    t3 = t2*t1
    print i
    return dts[i+1] + dts[i+2]*t1 + dts[i+3]*t2 + dts[i+4]*t3

def deltatT(y):  # 计算世界时与原子时之差,传入年
    d = dts
    i = 0
    while i < 100:
        if(y < d[i + 5] or i == 95):
            break
        i += 5
    t1 = round((y - d[i]) / (d[i + 5] - d[i] - 0.0) * 10, 15)
    t2 = round(t1 * t1, 15)
    t3 = round(t2 * t1, 15)
    return round(d[i + 1] + d[i + 2] * t1 + d[i + 3] * t2 + d[i + 4] * t3, 15)

def dt_T2(jd):
        #return self.dt_calc(jd / 365.2425 + 2000) / 86400.0
    return deltatT(jd / 365.2425 + 2000) / 86400.0

def toJD(dt, UTC):  # 公历转儒略日,UTC=1表示原日期是UTC
    y = dt.year
    m = dt.month
    n = 0  # 取出年月
    if (m <= 2):
        m += 12
        y -= 1
    if (dt.year * 372 + dt.month * 31 + dt.day >= 588829):  # 判断是否为格里高利历日1582*372+10*31+15
        n = int2(y / 100)
        n = 2 - n + int2(n / 4)  # 加百年闰
    n += int2(365.2500001 * (y + 4716))  # 加上年引起的偏移日数
    n += int2(30.6 * (m + 1)) + dt.day  # 加上月引起的偏移日数及日偏移数
    n += ((dt.second / (60-0.0) + dt.minute) / (60-0.0) + dt.hour) / (24-0.0) - 1524.5
    if (UTC):
        return n + dt_T2(n - J2000)
    return n



if __name__ == '__main__':
    '''
    a = dt_calc(10)
    b = dt_calc(20)
    print a
    print b
    '''

    '''
    print deltatT(2015)
    print deltatT(1700)
    print deltatT(2020)
    '''
    dt = datetime.datetime.strptime("2017-08-07 10:08:12", "%Y-%m-%d %H:%M:%S")
    print toJD(dt, 0)
    print toJD(dt, 1)



