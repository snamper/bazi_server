local luatz = require "luatz"

local function ts2tt ( ts )
    print(ts)
    local tt = luatz.timetable.new_from_timestamp ( ts )
    return tt
end

local dt1 = {year = 2017,month = 8,day = 22,hour = 18,min = 4, sec= 56}
local dt2 = {year = 2016,month = 3,day = 2,hour = 10,min = 2, sec= 33}


local x1 = luatz.timetable.timestamp(dt1.year,dt1.month,dt1.day,dt1.hour,dt1.min,dt1.sec)
local x2 = luatz.timetable.timestamp(dt2.year,dt2.month,dt2.day,dt2.hour,dt2.min,dt2.sec)

local delta = x1 -x2

local days = math.floor(delta/(3600*24))
local seconds = delta%(3600*24)
local minutes = math.floor(seconds/60)

local deltaH,deltaD,deltaM,deltaD,deltaY
deltaH = ((minutes%60)*2)%24
deltaD = (math.floor(minutes/60))*5 + math.floor(((minutes%60)*2)/24)
deltaM = (days%3)*4 + math.floor(deltaD/30)
deltaD = deltaD %30
deltaY = math.floor((days/3)) + math.floor(deltaM/12)
deltaM = deltaM %12

print(deltaH)
print(deltaD)
print(deltaM)
print(deltaY)

