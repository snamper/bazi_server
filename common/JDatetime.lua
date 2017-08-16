_M = {}
_M.J2000 = 2451545  --2000��ǰ��������(2000-1-1 12:00:00��������ƽʱ)
_M.dts   = {-4000, 108371.7, -13036.80, 392.000,  0.0000,
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


local J2000 = _M.J2000
local dts = _M.dts


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

function _M.int2(v)
    local value = math.floor(v)
    if(value < 0) then
        return value + 1
    else
        return value
    end
end

function _M.dt_ext(y,jsd)
    local dy = (y - 1820)/(100-0.0)
    return jsd*dy*dy - 20
end

function _M.dt_calc(y)
    --ȡdts���������Ԫ��ֵ,t0�����һ��Ԫ��,y0�ǵ����ڶ���Ԫ��
    local y0 = dts[#dts-1]
    local t0 = dts[#dts]
    if y >= y0 then
        local jsd = 31
        if y > (y0 + 100) then
            return dt_ext(y,jsd)
        end

        local v = dt_ext(y,jsd)
        local dv = dt_ext(y0,jsd) - t0
        return (v - dv*(y0 + 100 - y)/(100 - 0.0))
    end

    local i = 1  --�����±��1��ʼ
    while y >= dts[i+5] do
        i = i + 5
    end

    local t1 = (y - dts[i])/(dts[i+5] - dts[i] - 0.0) * 10
    local t2 = t1*t1
    local t3 = t2*t1

    return dts[i+1] + dts[i+2]*t1 + dts[i+3]*t2 + dts[i+4]*t3

end

--��������ʱ��ԭ��ʱ֮��,������
function _M.deltatT(y)
    local d = dts
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

function _M.dt_T2(jd)
    return _M.deltatT(jd / 365.2425 + 2000) / 86400.0
end

function _M.deltatT2(jd)
    --����������(J2000����),����UTC��ԭ��ʱ�Ĳ�(��λ:��)
    return _M.deltatT(jd / 365.2425 + 2000) / 86400.0
end

function _M.toJD(dt,UTC)
    local y = dt.year
    local m = dt.month
    local n = 0
    if (m <= 2) then
        m = m + 12
        y = y - 1
    end

    --�ж��Ƿ�Ϊ�����������1582*372+10*31+15
    if (dt.year * 372 + dt.month * 31 + dt.day >= 588829) then
        n = _M.int2(y / 100)
        n = 2 - n + _M.int2(n / 4)  --�Ӱ�����
    end

    n = n + _M.int2(365.2500001 * (y + 4716))  --�����������ƫ������
    n = n + _M.int2(30.6 * (m + 1)) + dt.day   --�����������ƫ����������ƫ����
    n = n + ((dt.second / (60-0.0) + dt.minute) / (60-0.0) + dt.hour) / (24-0.0) - 1524.5

    if (1 == UTC) then
        return n + _M.dt_T2(n - J2000)
    end

    return n

end

function _M.setFromJD(jd, UTC)
    local dt = {}

    if (1 == UTC) then
        jd = jd - _M.dt_T2(jd - J2000)
    end
    jd = jd + 0.5
    local A  = _M.int2(jd)
    local F = jd - A
    local D

    --Dȡ����������������A��С������F
    if (A > 2299161) then
        D = _M.int2((A - 1867216.25) / 36524.25)
        A = A + 1 + D - _M.int2(D / 4)
    end

    A = A + 1524  --��ǰ��4����2����
    dt.year = getIntPart(_M.int2((A - 122.1) / 365.25))
    D = A - _M.int2(365.25 * dt.year)  --ȥ��������������������
    dt.month = getIntPart(_M.int2(D / 30.6001))  --����
    dt.day = getIntPart(D - _M.int2(dt.month * 30.6001))  --ȥ��������������������
    dt.year = dt.year - 4716
    dt.month = dt.month - 1

    if (dt.month > 12) then
        dt.month = dt.month - 12
    end

    if (dt.month <= 2) then
        dt.year = dt.year + 1
    end

    --�յ�С��תΪʱ����
    F = F * 24
    dt.hour = getIntPart(_M.int2(F))
    F = F - dt.hour
    F = F * 60
    dt.minute = getIntPart(_M.int2(F))
    F = F - dt.minute
    F = F * 60
    dt.second = F
    local timeVal = os.time{year = dt.year,month = dt.month,day = dt.day,hour = dt.hour,min = dt.minute,sec = dt.second}

    local timeStr = os.date('%Y-%m-%d %H:%M:%S',timeVal)
    return timeStr,dt
end

function _M.Dint_dec(jd, shiqu, int_dec)
    --[[  ���:jdת������UTC��,UTC�������������ֻ�С������
          ����J2000��ѧʱjd���������12:00:00ʱ,��������ʱ�̷�����12:00:00,�����������㷢��ì��
          ��jd����Ϊ00:00:00����,���������յ����ն����������ڵ�����ͬ��
          ��������Ϊjd=jd+0.5-deltatT+shiqu/24
          �������յ�����ƶ�-0.5(��ǰ��12Сʱ)
          ʽ��shiqu��ʱ��,�������������-8Сʱ,shiquȡ8]]--

    local u = jd + 0.5 - _M.dt_T2(jd) + shiqu / (24 - 0.0)
    if (1 == int_dec) then
        return getIntPart(math.floor(u))  --������������
    else
        return u - math.floor(u)          --����С������
    end

end

function _M.cmp_date(dt,t)
    if t[1] < dt.year then
        return 0
    elseif t[1] > dt.year then
        return 1
    else
        if t[2] < dt.month then
            return 0
        elseif t[2] > dt.month then
            return 1
        else
            if t[3] < dt.day then
                return 0
            else
                return 1
            end
        end
    end

end

function _M.GetDatetime(dt)
    local timeVal = os.time{year = dt.year,month = dt.month,day = dt.day,hour = dt.hour,min = dt.minute,sec = dt.second}

    local timeStr = os.date('%Y-%m-%d %H:%M:%S',timeVal)
    return timeStr

end

function _M.GetDate(dt)
    local timeVal = os.time{year = dt.year,month = dt.month,day = dt.day,hour = dt.hour,min = dt.minute,sec = dt.second}

    local timeStr = os.date('%Y-%m-%d',timeVal)
    return timeStr
end


return _M


