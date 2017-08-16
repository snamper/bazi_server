local JDatetime = require "JDatetime"
local SolarTerms = require "SolarTerms"

--[[
print(JDatetime.dt_calc(10))
print(JDatetime.dt_calc(20))
print(JDatetime.dt_calc(100))


print(JDatetime.deltatT(2015))
print(JDatetime.deltatT(1700))
print(JDatetime.deltatT(2020))
--2017-08-07 10:08:12

local dt = {year=2017, month=8, day=7, hour=10, second=12,minute=8}
print(JDatetime.toJD(dt, 0))
print(JDatetime.toJD(dt, 1))


local t1 = 6524.3596
local dongzhi = 6564.18685031
local t = JDatetime.setFromJD(dongzhi+JDatetime.J2000 + 8/(24-0.0),1)
print(t)
]]--

print(SolarTerms.rad2mrad(745))
print(SolarTerms.rad2rrad(7.23*2 * math.pi))
print(SolarTerms.rad2str(30,1))
print(SolarTerms.rad2str(40,0))

local function split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

local function parse_time(r)
    local a = split(r, " ")
    local b = split(a[1], "-")
    local c = split(a[2], ":")
    dt = { year = b[1], month = b[2], day = b[3], hour = c[1], min = c[2], sec = c[3] }
    --return os.time({ year = b[1], month = b[2], day = b[3], hour = c[1], min = c[2], sec = c[3] })
    print(dt.year,dt.month,dt.day,dt.hour,dt.min,dt.sec)
    return dt

end

local function strToTime(timeStr)
    local a = split(timeStr, " ")
    local b = split(a[1], "-")
    local c = split(a[2], ":")
    dt = { year = tonumber(b[1]), month = tonumber(b[2]), day = tonumber(b[3]), hour = tonumber(c[1]), min = tonumber(c[2]), sec = tonumber(c[3]) }
    print(dt.year,dt.month,dt.day,dt.hour,dt.min,dt.sec)
    return dt
end

curTime = os.date("%Y-%m-%d %H:%M:%S", os.time())
print(curTime)

curTimeTable = strToTime(curTime)




