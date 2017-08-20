_M = {}

local daysNormalMonth = {[1] = 31, [2] = nil, [3] = 31, [4] = 30, [5] = 31, [6] = 30,
              [7] = 31, [8] = 31, [9] = 30, [10] = 31, [11] = 30, [12] = 31}

function _M.isLeapYear(year)
    if (year%4 == 0 and year % 100 ~= 0) or (year % 100 == 0 and year % 400 == 0) then
        return true
    else
        return false
    end
end

function _M.getDaysWithMonth(month, year)
    if month == 2 then
        if _M.isLeapYear(year) then
            return 29
        else
            return 28
        end
    else
        return daysNormalMonth[month]
    end
end

function _M.getIntervalByTime(oldTime, newTime)
    -- local wantTime = os.time({year=2014,month=12,day=31,hour=1,min=1})
    -- print(wantTime)
    -- print("旧时间=", os.date("%Y-%m-%d %H:%M", oldTime))
    -- print("新时间=", os.date("%Y-%m-%d %H:%M", newTime))
    local temp = 0
    --参数位置错了
    if oldTime > newTime then
        temp = oldTime
        oldTime = newTime
        newTime = temp
    end
    local oldTimeTable = os.date("*t", oldTime)
    local newTimeTable = os.date("*t", newTime)

    local oldYear  = oldTimeTable.year
    local oldMonth = oldTimeTable.month
    local oldDay   = oldTimeTable.day
    local oldHour  = oldTimeTable.hour
    local oldMin   = oldTimeTable.min
    local oldSec   = oldTimeTable.sec

    local newYear = newTimeTable.year
    local newMonth = newTimeTable.month
    local newDay = newTimeTable.day
    local newHour = newTimeTable.hour
    local newMin = newTimeTable.min
    local newSec = newTimeTable.sec

    --求差值
    local subYear = newYear  - oldYear
    local subMonth = newMonth - oldMonth
    local subDay = newDay   - oldDay
    local subHour = newHour  - oldHour
    local subMin = newMin   - oldMin
    local subSec = newSec  - oldSec

    --取得实际月份是多少天 （考虑了润年）
    local oldMonthDays = _M.getDaysWithMonth(oldMonth, oldYear)
    local newMonthDays = _M.getDaysWithMonth(newMonth, newYear)


    local yearNum  = 0
    local monthNum = 0
    local dayNum   = 0
    local hourNum  = 0
    local minNum   = 0
    local secNum   = 0


    local yearSubNum = 0
    local monthSubNum = 0
    local daySubNum = 0
    local hourSubNum = 0
    local minSubNum  = 0

    --如果秒小于0
    if subSec < 0 then
        secNum = 60 - math.abs(subSec)  --用60减秒
        minSubNum = minSubNum - 1
    else
        secNum = subSec
    end

    --如果分钟数小于0
    if subMin < 0 or minSubNum < 0 then
        if (subMin + minSubNum) < 0 then
            minNum = 60 - math.abs(subMin) + minSubNum
            hourSubNum = hourSubNum - 1
        else
            minNum = subMin + minSubNum

        end
    else
        minNum = subMin
    end


    --如果小时数小于0
    if subHour < 0 or hourSubNum < 0 then
        if (subHour + hourSubNum) < 0 then
            hourNum = 24 - math.abs(subHour) + hourSubNum
            daySubNum = daySubNum - 1
        else
            hourNum = subHour + hourSubNum
        end
    else
        hourNum = subHour
    end


    --如果天数小于0 可能会月份不同天 以以前的月份天数进行计算
    if subDay < 0 or daySubNum < 0 then
        if (subDay + daySubNum) < 0 then
            dayNum = oldMonthDays - math.abs(subDay) + daySubNum
            monthSubNum = monthSubNum - 1
        else
            dayNum = subDay + daySubNum
        end
    else
        dayNum = subDay
    end


    --如果月数小于0
    if subMonth < 0 or monthSubNum < 0 then
        if (subMonth + monthSubNum) < 0 then
            monthNum = 12 - math.abs(subMonth) + monthSubNum
            yearSubNum = yearSubNum - 1
        else
            monthNum = subMonth + monthSubNum
        end
    else
        monthNum = subMonth
    end

    yearNum = subYear

    --如果年数小于0
    if yearSubNum < 0 then
        yearNum = yearNum + yearSubNum
    end

    --多余的检测 开始
    --检测是否符合规则
    --以下是为了避免太离奇的结果，新方法需要时间来检测效果(先注释掉)

    local isTrueValue = true
    if yearNum < 0 then
        yearNum = 0
        isTrueValue = false
    end

    if monthNum < 0 then
        monthNum = 0
        isTrueValue = false
    end

    if monthNum > 12 then
        monthNum = 12
        isTrueValue = false
    end

    if dayNum < 0 then
        dayNum = 0
        isTrueValue = false
    end

    if dayNum > 31 then
        dayNum = 31
        isTrueValue = false
    end

    if hourNum < 0 then
        hourNum = 0
        isTrueValue = false
    end

    if hourNum > 24 then
        hourNum = 24
        isTrueValue = false
    end


    if minNum < 0 then
        minNum = 0
        isTrueValue = false
    end


    if minNum > 60 then
        minNum = 60
        isTrueValue = false
    end


    if not isTrueValue then
        print("calc date error!")
    end

    --多余的检测 结束
    --得到最后时间
    local intervalTiemTable = {}
    intervalTiemTable.year = yearNum
    intervalTiemTable.month = monthNum
    intervalTiemTable.day = dayNum
    intervalTiemTable.hour = hourNum
    intervalTiemTable.min = minNum
    intervalTiemTable.sec = secNum

    return intervalTiemTable
end

local oldTime = os.date(os.time{year=2014,month=6,day=10,hour=16,min=59,sec=23})
local newTime = os.date(os.time{year=2016,month=5,day=11,hour=16,min=44,sec=25})


local t_time = _M.getIntervalByTime(oldTime,newTime)
local time_txt = string.format("%04d", t_time.year).."年"..string.format("%02d", t_time.month).."月"..string.format("%02d", t_time.day).."日   "..string.format("%02d", t_time.hour)..":"..string.format("%02d", t_time.min)..":"..string.format("%02d", t_time.sec)
print(time_txt)
return _M

