--local date = require("date")
local JDatetime = {}

function JDatetime:new(dt)
    local _instance = {}

    _instance.J2000 = 2451545  --2000年前儒略日数(2000-1-1 12:00:00格林威治平时)
    _instance.dts   = {-4000, 108371.7, -13036.80, 392.000,  0.0000,
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
                    2015,  69 }

    if dt ~= nil and type(dt) == 'table' then
        _instance.Y = dt.year
        _instance.M = dt.month
        _instance.D = dt.day
        _instance.h = dt.hour
        _instance.m = dt.min
        _instance.s = dt.sec or 0
    else
        error("arg must be table type")
    end

    setmetatable(_instance, {__index = self})
    return _instance

end

local function getIntPart(x)
    if x <= 0 then
        return math.ceil(x)
    end

    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x) - 1
    end
    return x
end

local function round(x,n)
    local y,z

    local y = (10^n) * x
    if y > 0 then
        z = getIntPart((y + 0.5))/(10^n + 0.0)
    elseif y < 0 then
        z = getIntPart(y - 0.5)/(10^n + 0.0)
    else
        z = 0
    end

    return z
end

function JDatetime:int2(v)
    local value = math.floor(v)
    if(value < 0) then
        return value + 1
    else
        return value
    end
end

function JDatetime:dt_ext(y,jsd)
    local dy = (y - 1820)/(100-0.0)
    return jsd*dy*dy - 20
end

function JDatetime:dt_calc(y)
    --取dts的最后两个元素值,t0是最后一个元素,y0是倒数第二个元素
    local y0 = self.dts[#(self.dts)-1]
    local t0 = self.dts[#(self.dts)]

    if y >= y0 then
        local jsd = 31
        if y > (y0 + 100) then
            return self:dt_ext(y,jsd)
        end

        local v = self:dt_ext(y,jsd)
        local dv = self:dt_ext(y0,jsd) - t0
        return (v - dv*(y0 + 100 - y)/(100 - 0.0))
    end

    local i = 1  --数组下标从1开始
    while y >= self.dts[i+5] do
        i = i + 5
    end

    local t1 = (y - self.dts[i])/(self.dts[i+5] - self.dts[i] - 0.0) * 10
    local t2 = t1*t1
    local t3 = t2*t1

    return self.dts[i+1] + self.dts[i+2]*t1 + self.dts[i+3]*t2 + self.dts[i+4]*t3

end

--计算世界时与原子时之差,传入年
function JDatetime:deltatT(y)
    local d = self.dts
    local i = 1
    while i < (100 + 1) do
        if (y < d[i + 5] or (i == (95 + 1))) then
            break
        end

        i = i + 5
    end

    local t1 = round((y - d[i]) / (d[i + 5] - d[i] - 0.0) * 10, 15)
    local t2 = round(t1 * t1, 15)
    local t3 = round(t2 * t1, 15)
    return round(d[i + 1] + d[i + 2] * t1 + d[i + 3] * t2 + d[i + 4] * t3, 15)
end

function JDatetime:dt_T2(jd)
    return self:deltatT(jd / 365.2425 + 2000) / 86400.0
end

function JDatetime:deltatT2(jd)
    --传入儒略日(J2000起算),计算UTC与原子时的差(单位:日)
    return self:deltatT(jd / 365.2425 + 2000) / 86400.0
end

function JDatetime:toJD(UTC)
    local y = self.Y
    local m = self.M
    local n = 0
    if (m <= 2) then
        m = m + 12
        y = y - 1
    end

    --判断是否为格里高利历日1582*372+10*31+15
    if (self.Y * 372 + self.M * 31 + self.D >= 588829) then
        n = self:int2(y / 100)
        n = 2 - n + self:int2(n / 4)  --加百年闰
    end

    n = n + self:int2(365.2500001 * (y + 4716))  --加上年引起的偏移日数
    n = n + self:int2(30.6 * (m + 1)) + self.D   --加上月引起的偏移日数及日偏移数
    n = n + ((self.s / (60-0.0) + self.m) / (60-0.0) + self.h) / (24-0.0) - 1524.5

    if (1 == UTC) then
        return n + self:dt_T2(n - self.J2000)
    end

    return n

end

function JDatetime:setFromJD(jd, UTC)
    if (1 == UTC) then
        jd = jd - self:dt_T2(jd - self.J2000)
    end
    jd = jd + 0.5
    local A  = self:int2(jd)
    local F = jd - A
    local D


    --D取得日数的整数部份A及小数部分F
    if (A > 2299161) then
        D = self:int2((A - 1867216.25) / 36524.25)
        A = A + 1 + D - self:int2(D / 4)
    end

    A = A + 1524  --向前移4年零2个月
    self.Y = getIntPart(self:int2((A - 122.1) / 365.25))
    D = A - self:int2(365.25 * self.Y)  --去除整年日数后余下日数
    self.M = getIntPart(self:int2(D / 30.6001))  --月数
    self.D = getIntPart(D - self:int2(self.M * 30.6001))  --去除整月日数后余下日数
    self.Y = self.Y - 4716
    self.M = self.M - 1


    if (self.M > 12) then
        self.M = self.M - 12
    end

    if (self.M <= 2) then
        self.Y = self.Y + 1
    end

    --日的小数转为时分秒
    F = F * 24
    self.h = getIntPart(self:int2(F))
    F = F - self.h
    F = F * 60
    self.m = getIntPart(self:int2(F))
    F = F - self.m
    F = F * 60
    self.s = getIntPart(F)


    local timeVal = os.time{year = self.Y,month = self.M,day = self.D,hour = self.h,min = self.m}
    local retTime = {year = self.Y,month = self.M,day = self.D,hour = self.h,min = self.m,sec = 0}
    local timeStr = os.date('%Y-%m-%d %H:%M:%S',timeVal)
    return retTime,timeStr
end

function JDatetime:Dint_dec(jd, shiqu, int_dec)
    --[[  算出:jd转到当地UTC后,UTC日数的整数部分或小数部分
          基于J2000力学时jd的起算点是12:00:00时,所以跳日时刻发生在12:00:00,这与日历计算发生矛盾
          把jd改正为00:00:00起算,这样儒略日的跳日动作就与日期的跳日同步
          改正方法为jd=jd+0.5-deltatT+shiqu/24
          把儒略日的起点移动-0.5(即前移12小时)
          式中shiqu是时区,北京的起算点是-8小时,shiqu取8]]--

    local u = jd + 0.5 - self:dt_T2(jd) + shiqu / (24 - 0.0)
    if (1 == int_dec) then
        return getIntPart(math.floor(u))  --返回整数部分
    else
        return u - math.floor(u)          --返回小数部分
    end

end

function JDatetime:cmp_date(t)
    if t[1] < self.Y then
        return 0
    elseif t[1] > self.Y then
        return 1
    else
        if t[2] < self.M then
            return 0
        elseif t[2] > self.M then
            return 1
        else
            if t[3] < self.D then
                return 0
            else
                return 1
            end
        end
    end

end

function JDatetime:GetDatetime()
    local timeVal = os.time{year = self.Y,month = self.M,day = self.D,hour = self.h,min = self.m}
    local retTime = {year = self.Y,month = self.M,day = self.D,hour = self.h,min = self.m,sec = 0}
    local timeStr = os.date('%Y-%m-%d %H:%M:%S',timeVal)
    return retTime,timeStr

end

function JDatetime:GetDate()
    local timeVal = os.time{year = self.Y,month = self.M,day = self.D}

    local timeStr = os.date('%Y-%m-%d',timeVal)
    local retDay = {year = self.Y,month = self.M,day = self.D}
    return retDay,timeStr
end

local function JDatetime_test1()
    local dt = {}
    dt.year = 2017
    dt.month = 8
    dt.day   = 21
    dt.hour = 20
    dt.min = 12
    dt.sec  = 3

    local jdate = JDatetime:new(dt)
    print('test function dt_ext....')
    local res
    res = jdate:dt_ext(2017,20)
    print('the function dt_ext result is:',res)


    print('test function dt_calc....')
    res = jdate:dt_calc(2017)
    print('the function dt_calc result is:',res)

    print('test function toJD....')
    local result1 = jdate:toJD(1)
    print('the function toJD test1 result is:',result1)
    local result2 = jdate:toJD(0)
    print('the function toJD test2 result is:',result2)

    print('test function setFromJD....')
    local res = jdate:setFromJD(result1,1)
    print('the function setFromJD test1 result is: %s',string.format(res))
    local res = jdate:setFromJD(result2,0)
    print('the function setFromJD test2 result is: %s',string.format(res))

    print('test function Dint_dec....')
    local res = jdate:Dint_dec(result1,8,1)
    print('the function Dint_dec test1 result is: %s',string.format(res))
    local res = jdate:Dint_dec(result2,8,0)
    print('the function Dint_dec test2 result is: %s',string.format(res))

    return 0
end

local function JDatetime_test2()
    --dt = datetime.datetime.strptime("2017-08-07 10:08:12", "%Y-%m-%d %H:%M:%S")
    local dt = {}
    dt.year = 2017
    dt.month = 8
    dt.day   = 7
    dt.hour = 10
    dt.min = 8
    dt.sec  = 12

    local Y = dt.year
    local jdate = JDatetime:new(dt)
    local t1 = 365.2422*(Y - 1999) - 50
    print('t1 =',t1)
    local dongzhi = 6564.18685031
    print('dongzhi =',dongzhi)

    local t = jdate:setFromJD(dongzhi+jdate.J2000 + 8/(24-0.0),1)
    print(t)
end


--local a = JDatetime_test1()
--local b = JDatetime_test2()
return JDatetime