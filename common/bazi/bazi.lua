
local JDatetime = require "JDatetime"
local SolarTerms = require "SolarTerms"
local ast = require "ast"
local luatz = require "luatz"
local luabit = require("util.luabit")
--local luabit  = require "luabit"

local bazi = {}

local function round(x,n)
    local n = n or 0
    local y,z

    local y = (10^n) * x
    if y > 0 then
        z = math.modf((y + 0.5))/(10^n + 0.0)
    elseif y < 0 then
        z = math.modf(y - 0.5)/(10^n + 0.0)
    else
        z = 0
    end

    return z
end

local function ts2tt ( ts )
    return luatz.timetable.new_from_timestamp ( ts )
end

function bazi:new(bd,gender,AST,lon,lifa)
    local _instance = {}

    _instance.BaseYear = 1601
    _instance.LunarMonthTerms = {"*","正","二","三","四","五","六", "七","八","九","十","冬","腊"}
    _instance.LunarDayTerms   = {"*","初一","初二","初三","初四","初五",
                                 "初六","初七","初八","初九","初十",
                                 "十一","十二","十三","十四","十五",
                                 "十六","十七","十八","十九","二十",
                                 "廿一","廿二","廿三","廿四","廿五",
                                 "廿六","廿七","廿八","廿九","三十"}
    _instance.Jieqi = {"大雪","小寒","立春","惊蛰","清明","立夏","芒种","小暑","立秋","白露","寒露","立冬","大雪"}

    _instance.Tiangan = {"甲","乙","丙","丁","戊","己","庚","辛","壬","癸",""}
    _instance.Dizhi = {"子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"}
    --Lua下标从1开始，数组下标都要加1
    _instance.Canggan = {{9+1,10+1,10+1},{5+1,7+1,9+1},{0+1,2+1,4+1},{1+1,10+1,10+1},{1+1,4+1,9+1},{2+1,4+1,6+1},
                         {3+1,5+1,10+1},{1+1,3+1,5+1},{4+1,6+1,8+1},{7+1,10+1,10+1},{3+1,4+1,7+1},{0+1,8+1,10+1}}

    _instance.Shengxiao = {"鼠","牛","虎","兔","龙","蛇","马","羊","猴","鸡","狗","猪"}
    _instance.ShiShen = {"比肩","劫财","食神","伤官","偏财","正财","七杀","正官","偏印","正印",""}
    _instance.Gender = {"乾造","坤造"}
    _instance.ShizhuList = { --甲己   乙庚   丙辛   丁壬   戊癸
                            {"甲子","丙子","戊子","庚子","壬子"},
                            {"乙丑","丁丑","己丑","辛丑","癸丑"},
                            {"丙寅","戊寅","庚寅","壬寅","甲寅"},
                            {"丁卯","己卯","辛卯","癸卯","乙卯"},
                            {"戊辰","庚辰","壬辰","甲辰","丙辰"},
                            {"己巳","辛巳","癸巳","乙巳","丁巳"},
                            {"庚午","壬午","甲午","丙午","戊午"},
                            {"辛未","癸未","乙未","丁未","己未"},
                            {"壬申","甲申","丙申","戊申","庚申"},
                            {"癸酉","乙酉","丁酉","己酉","辛酉"},
                            {"甲戌","丙戌","戊戌","庚戌","壬戌"},
                            {"乙亥","丁亥","己亥","辛亥","癸亥"} }

    _instance.lifalst = {"太初历","四分历","大明历","戊寅元历","麟德历","正元历","应天历","崇天历","淳祐历","授时历","尤氏子平历-定夏至 ","尤氏子平历-定冬至 "}

    _instance.pqargs = {{1683430.515601,15.218750011},{1752157.640664,15.218749978},
                        {1907369.128100,15.218449176},{1947180.798300,15.218524844},
                        {1964362.041824,15.218533526},{2007445.469786,15.218535181},
                        {2073204.872850,15.218515221},{2111190.300888,15.218425000},
                        {2178485.706538,15.218425000},{2188621.191481,15.218437484}}

    _instance.bd = bd
    _instance.isFemale = gender
    _instance.AST = AST or 0
    _instance.L = lon or 120
    _instance.lifa = lifa or 0
    _instance.bazi = {-1,-1,-1,-1,-1,-1,-1,-1}
    _instance.shishen = {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}
    _instance.bjq = bd
    _instance.fjq = bd
    _instance.qyspan = {0,0,0,0}
    _instance.jydt = bd
    _instance.bazikey = ""

    setmetatable(_instance, {__index = self})
    return _instance

end

function bazi:isLeapYear(year)
    return (year%4 == 0) and (year%100 ~= 0) or (year%400 == 0)
end

function bazi:solarDaysFromBaseYear(date)
    local pd = {0,31,59,90,120,151,181,212,243,273,304,334}
    local delta = date.year - self.BaseYear

    --lua中/默认不是取整,需要注意取整处理
    local offset = 365*delta + math.modf(delta/4) - math.modf(delta/100) + math.modf(delta/400)
    offset = offset + pd[date.month -1 + 1] --lua中数组从1开始

    if date.month > 2 and self:isLeapYear(date.year) then
        offset = offset + 1
    end

    offset = offset + date.day
    return offset - 1
end

function bazi:solar2Lunar(bd)
    local Y = bd.year
    local M = bd.month
    local D = bd.day

    local jdate = JDatetime:new(bd)
    local t1 = 365.2422*(Y - 1999) - 50
    local zq = {}
    local hs = {}
    local dongzhi = SolarTerms.jiaoCal(t1,-90,0)

    jdate:setFromJD(dongzhi+jdate.J2000 + 8/(24-0.0),1)

    if jdate:cmp_date({Y,M,D}) == 0 then
        t1 =  365.2422*(Y - 2000) - 50
    end

    for i = 0,13 do
        table.insert(zq,SolarTerms.jiaoCal(t1 + i * 30.4, i * 30 - 90, 0))  --# 中气计算,冬至的太阳黄经是270度(或-90度)
    end

    local dongZhiJia1 = zq[0 + 1] + 1 - jdate:Dint_dec(zq[0 + 1], 8, 0) --# 冬至过后的第一天0点的儒略日数

    hs[1] = SolarTerms.jiaoCal(dongZhiJia1, 0, 1)  --# 首月结束的日月合朔时刻

    for i = 2,14 do
        table.insert(hs,SolarTerms.jiaoCal(hs[i-1] + 25, 0, 1))
    end

    table.insert(hs,SolarTerms.jiaoCal(hs[1] - 35, 0, 1))

    local A = {}
    local C = {}
    for i = 1,14 do
        table.insert(A,jdate:Dint_dec(zq[i],8,1))
        table.insert(C,jdate:Dint_dec(hs[i],8,1))
    end

    table.insert(C,jdate:Dint_dec(hs[15],8,1))

    local tot = 12
    local nun = -5
    local yn = {11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10}

    if (C[12 + 1] <= A[12 + 1]) then --# 闰月分析
        yn[12 + 1] = 10
        tot = 13
        local index
        for i = 2,13 do
            index = i
            if (C[i] <= A[i]) then
                break
            end
        end

        nun = index - 1

        for j = index,13 do
            yn[j-1 + 1] = yn[j-1 + 1] + 11
            yn[j-1 + 1] = yn[j-1 + 1] % 12
        end
    end

    local j = 0
    jdate:setFromJD(C[0 + 1] + jdate.J2000 + 8/(24 - 0.0), 1)
    while 1 == jdate:cmp_date({Y,M,D}) do
        j = j + 1
        jdate:setFromJD(C[j + 1] + jdate.J2000 + 8/(24 - 0.0), 1)
    end

    if j == (nun+1) then
        isLeapMonth = 1
    else
        isLeapMonth = 0
    end

    if j == 0 then
        jdate:setFromJD(C[14 + 1] + jdate.J2000 + 8/(24 - 0.0), 1)
    else
        jdate:setFromJD(C[j-1 + 1] + jdate.J2000 + 8/(24- 0.0), 1)
    end

    local BD = {year = Y,month = M,day = D}

    local tmpDay = jdate:GetDate()

    local x1 = luatz.timetable.timestamp(BD.year,BD.month,BD.day,0,0,0)
    local x2 = luatz.timetable.timestamp(tmpDay.year,tmpDay.month,tmpDay.day,0,0,0)

    local days = math.floor((x1 -x2)/(3600*24))

    local l_day = 1 + days

    j = (j+tot-1)%tot

    local l_month = yn[j + 1]+1

    if l_month >= 9 and M <= 3 then
        l_year = Y - 1
    else
        l_year = Y
    end

    return l_year,l_month,l_day,isLeapMonth

end

function bazi:lunar2Solar(bd,isLeapMonth)
    return SolarTerms.Lunar2Solar(bd,isLeapMonth)
end

function bazi:Get_PQ_SolarTerm()
    local lfindx
    if self.lifa > 0 then
        lfindx = self.lifa - 1 + 1 --lua下标要加1
    else
        lfindx = 9 + 1 --默认授时历(lua下标要加1)
    end

    local mindx = self.bd.month
    local bd = JDatetime:new(self.bd)
    local bjq = JDatetime:new(self.bjq)
    local fjq = JDatetime:new(self.fjq)

    local b,k
    if lfindx > (9 + 1) then
        b,k = SolarTerms.bk_calc(self.bd,self.lifa)
    else
        b = self.pqargs[lfindx][0 + 1] + self.pqargs[lfindx][1+1]
        k = 2*(self.pqargs[lfindx][1 + 1])
    end

    local BD,JD,n,tmp,TD,D,Q
    if self.AST ~= 0 then
        BD = bd:toJD(0)
        JD = ast.mst_ast((bd:toJD(1) - 8/24.0 - bd.J2000)/36525) + BD + (self.L - 120.0)/360.0
        n = round((BD - self.bd.day + 6 - b)/k)
        tmp = k*n + b - 8/24.0 - bd.J2000
        TD = tmp + SolarTerms.dt_T2(tmp)
        D = tmp + ast.mst_ast(TD/36525) + self.L/360.0 + bd.J2000

        if JD < D then
            mindx = mindx - 2
            tmp = tmp - k
            TD = tmp + SolarTerms.dt_T2(tmp)
            Q = tmp + ast.mst_ast(TD/36525) + self.L/360.0 + bd.J2000
            bjq:setFromJD(Q,0)
            fjq:setFromJD(D,0)
        else
            mindx = mindx - 1
            tmp = tmp + k
            TD = tmp + SolarTerms.dt_T2(tmp)
            Q = tmp + ast.mst_ast(TD/36525) + self.L/360.0 + bd.J2000
            bjq:setFromJD(D,0)
            fjq:setFromJD(Q,0)
        end
    else
        JD = bd:toJD(0)
        n = round((JD - self.bd.day + 6 - b)/k)
        D = k*n + b

        if JD < D then
            mindx = mindx - 2
            bjq:setFromJD(D-k,0)
            fjq:setFromJD(D,0)
        else
            mindx = mindx - 1
            bjq:setFromJD(D,0)
            fjq:setFromJD(D+k,0)
        end
    end

    return mindx,bjq:GetDatetime(),fjq:GetDatetime()
end

function bazi:Get_DQ_SolarTerm()
    local mindx = self.bd.month
    local bd = JDatetime:new(self.bd)
    local bjq = JDatetime:new(self.bjq)
    local fjq = JDatetime:new(self.fjq)

    local BD,JD,tmp,D,Q
    if self.AST ~= 0 then
        BD = bd:toJD(0)
        JD = ast.mst_ast((bd:toJD(1) - 8/24.0 - bd.J2000)/36525) + BD + (self.L - 120.0)/360.0
        tmp = BD - self.bd.day + 5 - bd.J2000
        D = SolarTerms.qi_accurate2(tmp,1,self.L) + bd.J2000

        if JD < D then
            mindx = mindx - 2
            tmp = tmp - 30
            Q = SolarTerms.qi_accurate2(tmp,1,self.L) + bd.J2000

            bjq:setFromJD(Q,0)
            fjq:setFromJD(D,0)
        else
            mindx = mindx - 1
            tmp = tmp + 30
            Q = SolarTerms.qi_accurate2(tmp,1,self.L) + bd.J2000

            bjq:setFromJD(D,0)
            fjq:setFromJD(Q,0)
        end

    else
        JD = bd:toJD(0)
        tmp = JD - self.bd.day + 5 - bd.J2000
        D = SolarTerms.qi_accurate2(tmp,0,120) + bd.J2000

        if JD < D then
            mindx = mindx - 2
            tmp = tmp - 30
            Q = SolarTerms.qi_accurate2(tmp,0,120) + bd.J2000
            bjq:setFromJD(Q,0)
            fjq:setFromJD(D,0)
        else
            mindx = mindx - 1
            tmp = mindx + 30
            Q = SolarTerms.qi_accurate2(tmp,0,120) + bd.J2000
            bjq:setFromJD(D,0)
            fjq:setFromJD(Q,0)
        end
    end

    return mindx,bjq:GetDatetime(),fjq:GetDatetime()
end


function bazi:GetSpanDays(tflag)
    local bd
    if self.AST ~= 0 then
        bd = ast.calc_AST(self.bd,self.L)
    else
        bd = self.bd
    end

    local dt1,dt2
    if 1 == tflag then
        dt1 = self.bjq
        dt2 = bd
    else
        dt1 = bd
        dt2 = self.fjq
    end

    local x1 = luatz.timetable.timestamp(dt1.year,dt1.month,dt1.day,dt1.hour,dt1.min,dt1.sec)
    local x2 = luatz.timetable.timestamp(dt2.year,dt2.month,dt2.day,dt2.hour,dt2.min,dt2.sec)

    local days = math.floor((x2 -x1)/(3600*24))
    local seconds = (x2-x1)%(3600*24)
    local minutes = math.floor(seconds/60)

    local deltaH,deltaD,deltaM,deltaY
    deltaH = ((minutes%60)*2)%24
    deltaD = (math.floor(minutes/60))*5 + math.floor(((minutes%60)*2)/24)
    deltaM = (days%3)*4 + math.floor(deltaD/30)
    deltaD = deltaD %30
    deltaY = math.floor((days/3)) + math.floor(deltaM/12)
    deltaM = deltaM %12

    return {deltaY,deltaM,deltaD,deltaH}
end

function bazi:GetJiaoYunDate()
    local days = self.qyspan[0 + 1]*365.2422 + self.qyspan[1 + 1]*30.44 + self.qyspan[2 + 1]
    local hours = self.qyspan[3+1]

    local x = luatz.timetable.new(self.bd.year,self.bd.month,self.bd.day,self.bd.hour,self.bd.min,self.bd.sec)
    local dt = x:clone()
    dt.day  = dt.day + days
    dt.hour = dt.hour + hours
    dt:normalise()
    return dt
end

function bazi:Paipan()
    local bd
    if self.AST ~= 0 then
        bd = ast.calc_AST(self.bd,self.L)
    else
        bd = self.bd
    end
    local Y,M,D,h,m
    Y = bd.year
    M = bd.month
    D = bd.day
    h = bd.hour
    m = bd.min

    local Nianzhu = ((Y - self.BaseYear) + 37)%60
    local mindx

    if self.lifa ~= 0 then
        mindx,self.bjq,self.fjq = self:Get_PQ_SolarTerm()
    else
        mindx,self.bjq,self.fjq = self:Get_DQ_SolarTerm()
    end

    local YFlag = 0
    if mindx <= 0 then
        YFlag = 1
        mindx = mindx + 12
    end

    if YFlag == 1 then
        Nianzhu = Nianzhu + 59
        Nianzhu = Nianzhu%60
    end

    local Yuezhu = (((Nianzhu%5)*12)+(mindx-1)+2)%60

    self.bazi[0 + 1] = Nianzhu%10
    self.bazi[1 + 1] = Nianzhu%12
    self.bazi[2 + 1] = Yuezhu%10
    self.bazi[3 + 1] = Yuezhu%12

    local offset = self:solarDaysFromBaseYear(bd)
    local Rizhu = (offset+3)%60
    local time = math.floor(h/2)

    local Dflag = 0
    if h%2 == 1 then
        time = time + 1
    end

    if time == 12 then
        Dflag = 1
        time = 0
    end

    if Dflag == 1 then
        Rizhu = Rizhu + 1
        Rizhu = Rizhu % 60
    end

    local Shizhu = (Rizhu%5)*12+time

    self.bazi[4 + 1] = Rizhu%10
    self.bazi[5 + 1] = Rizhu%12
    self.bazi[6 + 1] = Shizhu%10
    self.bazi[7 + 1] = Shizhu%12

    local j = self.bazi[4 + 1]
    if j%2 == 0 then
        for i = 0,9 do
            self.shishen[j+1] = i
            j = j + 1
            j = j % 10
        end
    else
        for k = 0,9,2 do
            self.shishen[j+1] = k
            self.shishen[j-1 + 1] = k+1
            j = j + 2
            j = j % 10
        end
    end
    table.insert(self.shishen,10)

    local tflag = luabit.xorOp((self.bazi[0+1]%2),self.isFemale)
    self.qyspan = self:GetSpanDays(tflag)

    self.jydt = self:GetJiaoYunDate()
    self.bazikey = string.format("bazi:%s%s%s%s_%s%s_%s%s_%s%s_%s_%s:%s",Y,self.isFemale,self.bazi[0+1],self.bazi[1+1],
                            self.bazi[2+1],self.bazi[3+1],self.bazi[4+1],self.bazi[5+1],self.bazi[6+1],self.bazi[7+1],self.lifa,h,m)
end

function bazi:queryBaZi()
    local opt = string.format("%s%s %s%s %s%s %s%s",self.Tiangan[self.bazi[0+1]+1],
                             self.Dizhi[self.bazi[1+1]+1],self.Tiangan[self.bazi[2+1]+1],
                             self.Dizhi[self.bazi[3+1]+1],self.Tiangan[self.bazi[4+1]+1],
                             self.Dizhi[self.bazi[5+1]+1],self.Tiangan[self.bazi[6+1]+1],
                             self.Dizhi[self.bazi[7+1]+1])
    return opt
end

function bazi:getBaZi()
    local tmpGender
    local output = {}
    if 1 == self.isFemale then
        tmpGender = "坤"
    else
        tmpGender = "乾"
    end
    local opt = string.format("%s:%s%s %s%s %s%s %s%s",tmpGender,self.Tiangan[self.bazi[0+1]+1],
                                         self.Dizhi[self.bazi[1+1]+1],self.Tiangan[self.bazi[2+1]+1],
                                         self.Dizhi[self.bazi[3+1]+1],self.Tiangan[self.bazi[4+1]+1],
                                         self.Dizhi[self.bazi[5+1]+1],self.Tiangan[self.bazi[6+1]+1],
                                         self.Dizhi[self.bazi[7+1]+1])
    table.insert(output,opt)
    local flag = luabit.xorOp((self.bazi[0+1]%2),self.isFemale)
    local offsets
    if 1 == flag then
        offsets = {9,11}
    else
        offsets = {1,1}
    end

    local opt = "大运:"
    local j = self.bazi[2+1]
    local k = self.bazi[3+1]
    local jydt
    for i = 1,8 do
        j = j + offsets[0+1]
        j = j % 10
        k = k + offsets[1+1]
        k = k %12
        opt = opt..string.format("%s%s ",self.Tiangan[j+1],self.Dizhi[k+1])
    end

    table.insert(output,opt)
    jydt = self.jydt
    local temp = string.format("  %s年%s月%s日交运",jydt.year,jydt.month,jydt.day)
    table.insert(output,temp)

    return output
end

function bazi:printBaZi()
    local output = {}
    local opt = string.format("            %s        %s        %s        %s",
                self.ShiShen[self.shishen[self.bazi[0+1]+1]+1],
                self.ShiShen[self.shishen[self.bazi[2+1]+1]+1],
                '日元',self.ShiShen[self.shishen[self.bazi[6+1]+1]+1])
    table.insert(output,opt)

    local opt = string.format("%s       %s           %s           %s           %s",
                              self.Gender[self.isFemale+1],self.Tiangan[self.bazi[0+1]+1],
                              self.Tiangan[self.bazi[2+1]+1],self.Tiangan[self.bazi[4+1]+1],
                              self.Tiangan[self.bazi[6+1]+1])
    table.insert(output,opt)

    local opt = string.format("              %s           %s           %s           %s",
                            self.Dizhi[self.bazi[1+1]+1],self.Dizhi[self.bazi[3+1]+1],
                            self.Dizhi[self.bazi[5+1]+1],self.Dizhi[self.bazi[7+1]+1])
    table.insert(output,opt)

    local opt
    for i = 1,3 do
        --print('i = ',i)
        local opt = "         "
        for j = 2,8,2 do
            --print('j = ',j)
            local k = self.Canggan[self.bazi[j]+1][i]
            --print('k = ',k)
            if k < 11 then
                opt = opt..string.format("%s %s    ",self.Tiangan[k],self.ShiShen[self.shishen[k]+1])
            else
                opt = opt.."                "
            end
        end
        table.insert(output,opt)
    end

    table.insert(output,"")
    local jydt = self.jydt
    --local jydtStamp = luatz.timetable.timestamp(jydt.year,jydt.month,jydt.day,jydt.hour,jydt.min,jydt.sec)

    table.insert(output,string.format('命主于公历%d年%d月交运',jydt.year,jydt.month))

    local tFlag = luabit.xorOp((self.bazi[0+1]%2),self.isFemale)
    if 1 == tFlag then
        offsets = {9,11}
    else
        offsets = {1,1}
    end

    local j = self.bazi[2+1]
    local k = self.bazi[3+1]
    local s = self.bazi[2+1]

    local now = os.time()
    --local tmp = jydt.year

    local opt = "大运"
    local tmp = jydt

    for i = 1,8 do
        j = j + offsets[0+1]
        j = j % 10
        k = k + offsets[1+1]
        k = k % 10
        local jydtTmp = tmp
        local jydtStamp = os.time{year=jydtTmp.year,month=jydtTmp.month,day=jydtTmp.day,
                                 hour=jydtTmp.hour,min=jydtTmp.min,sec=jydtTmp.sec}
        --print('jydtStamp =',jydtStamp)
        local jydtTime = luatz.timetable.new(jydtTmp.year,jydtTmp.month,jydtTmp.day,jydtTmp.hour,jydtTmp.min,jydtTmp.sec)
        local dt = jydtTime:clone()
        dt.year = dt.year + 10
        dt:normalise()
        tmp = dt
        local dtStamp = dt:timestamp()

        if (now >= dtStamp) or now < jydtStamp then
            opt = opt..string.format("  %s%s",self.Tiangan[j+1],self.Dizhi[k+1])
        else
            opt = opt..string.format(" @%s%s",self.Tiangan[j+1],self.Dizhi[k+1])
        end
    end
    table.insert(output,opt)

    return output

end

function bazi:getMeridiem(hour,minute)
    local hm = hour*100 + minute
    if (hm < 600) then
        return "凌晨"
    elseif (hm < 900) then
        return "早上"
    elseif (hm < 1130) then
        return "上午"
    elseif (hm < 1230) then
        return "中午"
    elseif (hm < 1800) then
        return "下午"
    else
        return "晚上"
    end
end

function bazi:printMst()
    local bd = self.bd
    local md = self:getMeridiem(bd.hour,bd.min)
    local tmp = bd.hour
    if bd.hour >= 13 then
        tmp = bd.hour-12
    end
    local timeVal = os.time{year=bd.year,month=bd.month,day=bd.day,hour=bd.hour,min=bd.min}
    local st = os.date('%M',timeVal)
    return string.format("%s年%s月%s日 %s%s点%s",bd.year,bd.month,bd.day,md,tmp,st)
end

function bazi:printLunar()
    local bd = self.bd
    local h = bd.hour
    local time = math.modf(h/2)
    local DFlag = 0

    if h%2 == 1 then
        time = time + 1
    end

    if time == 12 then
        DFlag = 1
        time = 0
    end

    if DFlag == 1 then
        local xTime = luatz.timetable.new(bd.year,bd.month,bd.day,bd.hour,bd.min,bd.sec)
        local dt = xTime:clone()
        dt.day = dt.day + 1
        dt:normalise()
        bd = dt
    end

    local l_y,l_m,l_d,isLeap = self:solar2Lunar(bd)

    local ytmp = ((l_y - self.BaseYear) + 37)%60
    local x = ytmp%12
    local y = math.modf(ytmp/12)

    local leapstr = ""
    if 1== isLeap then
        leapstr = "闰"
    end

    local output = string.format("%s%s年%s%s月%s %s时",self.ShizhuList[x+1][y+1],
                                self.Shengxiao[x+1],leapstr,self.LunarMonthTerms[l_m+1],
                                self.LunarDayTerms[l_d+1],self.Dizhi[time+1])
    return output
end

function bazi:printAge()
    local nowTime = os.date('*t',os.time())
    local output = string.format('今年虚岁%d',(nowTime.year - self.bd.year + 1))
    return output
end

function bazi:printLifa()
    local res
    if self.lifa >= 1 and self.lifa <=10 then
        res = string.format('依据 %s 数据拟合 ',self.lifalst[self.lifa-1+1])

    elseif self.lifa > 10 and self.lifa < 13 then
        res = string.format('依据 %s 计算节气交合日期',self.lifalst[self.lifa-1+1])

    else
        res = "现代农历定气"
    end

    return res
end

function bazi:renderAST()
    local output = {}
    local opt = string.format("<p>出生地经度 %s&deg; </p>",self.L)
    table.insert(output,opt)

    local dt = ast.calc_AST(self.bd,self.L)
    opt = string.format("<p>生日&#91;出生地真太阳时&#93;  %s年%s月%s日 %s时%s分  </p>",
                       dt.year,dt.month,dt.day,dt.hour,dt.min)
    table.insert(output,opt)

    return output
end

function bazi:renderSolarterms()
    local output = {}
    local aststr
    if 1== self.AST then
        aststr = "&#91;出生地真太阳时&#93;"
    else
        aststr = ""
    end

    local opt = string.format("<p>%s%s   ",self.Jieqi[self.bazi[3+1]+1], aststr)
    table.insert(output,opt)
    local dt = self.bjq
    local opt = string.format(" %s年%s月%s日 %s时%s分  </p>",dt.year,dt.month,dt.day,dt.hour,dt.min)
    table.insert(output,opt)
    local opt = string.format("<p>%s%s  ",self.Jieqi[self.bazi[3+1]+1+1],aststr)
    table.insert(output,opt)

    local dt = self.fjq
    local opt = string.format(" %s年%s月%s日 %s时%s分 </p>",dt.year,dt.month,dt.day,dt.hour,dt.min)
    table.insert(output,opt)

    return output
end

function bazi:renderBaZi()
    local row_rets = {"<br/>","<br/>","<br/><br/>","<br/>","<br/>",""}
    local htmsp1 = "&nbsp"
    local htmsp3 = "&nbsp;&nbsp;&nbsp"
    local htmsp4 = "&nbsp;&nbsp;&nbsp;&nbsp"
    local output = {'<td>'}

    local opt = string.format('%s %s %s',htmsp1,htmsp3,row_rets[0+1])
    table.insert(output,opt)

    local opt = string.format('%s %s %s',self.Gender[self.isFemale+1],htmsp3,row_rets[1+1])
    table.insert(output,opt)

    local opt = string.format('%s %s %s',htmsp1,htmsp1,row_rets[2+1])
    table.insert(output,opt)

    local opt = string.format('%s %s %s',"藏干",htmsp4,row_rets[3+1])
    table.insert(output,opt)

    local opt = string.format('%s %s %s',htmsp1,htmsp3,row_rets[4+1])
    table.insert(output,opt)

    local opt = string.format('%s %s %s',htmsp1,htmsp3,row_rets[5+1])
    table.insert(output,opt)
    table.insert(output,'</td>')

    local j,p
    for i = 0,3 do
        table.insert(output,'<td>')
        j = i + i
        p = j + 1
        if i == 2 then
            local opt = string.format('%s %s %s %s',htmsp1,"日元",htmsp4,row_rets[0+1])
            table.insert(output,opt)
        else
            local opt = string.format('%s %s %s %s',htmsp1,self.ShiShen[self.shishen[self.bazi[j+1]+1]+1],htmsp4,row_rets[0+1])
            table.insert(output,opt)
        end

        local opt = string.format('%s %s %s %s',htmsp3,self.Tiangan[self.bazi[j+1]+1],htmsp3,row_rets[1+1])
        table.insert(output,opt)
        local opt = string.format('%s %s %s %s',htmsp3,self.Dizhi[self.bazi[p+1]+1],htmsp3,row_rets[2+1])
        table.insert(output,opt)

        for q = 0,2 do
            local k = self.Canggan[self.bazi[p+1]+1][q+1]
            local opt = string.format("%s %s",self.Tiangan[k],self.ShiShen[self.shishen[k]+1])
            local tmp = string.format('%s %s %s %s',htmsp1,opt,htmsp4,row_rets[q+3+1])
            table.insert(output,tmp)
        end
        table.insert(output,'</td>')

    end

    return output
end

function bazi:renderDaYun()
    local row_rets = {"<br/>","<br/><br/>","<br/><br/>","<br/>","<br/>","<br/>","<br/>",
                    "<br/><br/>","<br/>","<br/>","<br/>","<br/>","<br/><br/>",""}
    local htmsp1 = "&nbsp"
    local htmsp3 = "&nbsp;&nbsp;&nbsp"
    local output = {}

    local tFlag = luabit.xorOp((self.bazi[0+1]%2),self.isFemale)

    local offsets
    if 1 == tFlag then
        offsets = {9,11}
    else
        offsets = {1,1}
    end

    local qyspan = self.qyspan
    local jydt = self.jydt
    local opt = string.format('<p>命主于出生后%d年%d个月%d天%d小时后起运</p>',qyspan[0+1],qyspan[1+1],qyspan[2+1],qyspan[3+1])
    table.insert(output,opt)
    local opt = string.format('<p>命主于公历%d年%d月%d日%d时交运</p><br/>',jydt.year,jydt.month,jydt.day,jydt.hour)
    table.insert(output,opt)

    local j = self.bazi[2+1]
    local k = self.bazi[3+1]
    local s = self.bazi[2+1]
    local now = os.time()
    local nowDate = os.date('*t',now)

    table.insert(output,'<td>')
    table.insert(output,string.format('%s %s',"大运",row_rets[1+1]))
    table.insert(output,string.format('%s %s',"起于",row_rets[2+1]))
    table.insert(output,string.format('%s %s',"流年",row_rets[3+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[4+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[5+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[6+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[7+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[8+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[9+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[10+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[11+1]))
    table.insert(output,string.format('%s %s',htmsp1,row_rets[12+1]))
    table.insert(output,string.format('%s %s',"止于",row_rets[13+1]))
    table.insert(output,'</td>')

    local tmp = jydt
    for i = 0,7 do
        table.insert(output,'<td>')
        j = j + offsets[0+1]
        j = j % 10
        k = k + offsets[1+1]
        k = k % 12

        local jydtTmp = tmp
        local jydtStamp = os.time{year=jydtTmp.year,month=jydtTmp.month,day=jydtTmp.day,
                                 hour=jydtTmp.hour,min=jydtTmp.min,sec=jydtTmp.sec}

        local jydtYear = tmp.year

        local jydtTime = luatz.timetable.new(jydtTmp.year,jydtTmp.month,jydtTmp.day,jydtTmp.hour,jydtTmp.min,jydtTmp.sec)
        local dt = jydtTime:clone()
        dt.year = dt.year + 10
        dt:normalise()
        tmp = dt

        local dtStamp = dt:timestamp()

        if (now >= dtStamp) or now < jydtStamp then
            local opt = string.format("%s%s",self.Tiangan[j+1],self.Dizhi[k+1])
            table.insert(output,string.format('%s %s %s',htmsp3,opt,row_rets[1+1]))
        else
            local opt = string.format("<i class=\"fa fa-play\"></i>&nbsp;%s%s",self.Tiangan[j+1],self.Dizhi[k+1])
            table.insert(output,string.format('%s %s',opt,row_rets[1+1]))
        end
        local opt = jydtYear
        table.insert(output,string.format('%s %s %s',htmsp3,opt,row_rets[2+1]))

        local p = (jydtYear + 6)%10
        local q = (jydtYear + 8)%12

        for n = 0,9 do
            if (nowDate.year - jydtYear) ~= n then
                local opt = string.format("%s%s",self.Tiangan[p+1],self.Dizhi[q+1])
                table.insert(output,string.format('%s %s %s',htmsp3,opt,row_rets[n+3+1]))
            else
                local opt = string.format("<i class=\"fa fa-play\"></i>&nbsp;%s%s",self.Tiangan[p+1],self.Dizhi[q+1])
                table.insert(output,string.format('%s %s',opt,row_rets[n+3+1]))
            end
            p = p + 1
            p = p % 10
            q = q + 1
            q = q % 12

        end
        local opt = jydtYear + 9
        table.insert(output,string.format('%s %s %s',htmsp3,opt,row_rets[13+1]))
        table.insert(output,'</td>')
    end

    return output
end

local function test()
    local dt = {year=1988,month=1,day=6,hour=3,min=50,sec=0}
    local bz = bazi:new(dt,1,0,120,12)
    bz:Paipan()
    local res = bz:queryBaZi()
    print(res)
    local res = bz:getBaZi()
    for k,v in pairs(res) do
        print(k.." = "..v)
    end

    --local res = bz:solarDaysFromBaseYear(dt)
    --print(res)

    --local res = bz:GetJiaoYunDate()
    --print(res.year,res.month,res.day,res.hour,res.min,res.sec)

    local res = bz:printBaZi()
    for k,v in pairs(res) do
        print(k.." = "..v)
    end

    print(bz:printMst())

    local res = bz:printLunar()
    print(res)

    local res = bz:printAge()
    print(res)

    local res = bz:printLifa()
    print(res)

    local res = bz:renderAST()
    print(res)

    local res = bz:renderSolarterms()
    for k, v in pairs(res) do
        print(v)
    end

    local res = bz:renderBaZi()
    for k, v in pairs(res) do
        print(v)
    end


    local res = bz:renderDaYun()
    for k, v in pairs(res) do
        print(v)
    end
end

--a = test()
return bazi