--[[
八字信息获取接口
--]]

local base = require "resty.core.base"
local format = string.format
local decode = WEBSERVER_formatter.decode
local json = WEBSERVER_formatter.json
local empty =  WEBSERVER_table.empty
local split = WEBSERVER_str.split
local bazi = require "bazi"

local function strToTimetable(timeStr)
    local a = split(timeStr, " ")
    local b = split(a[1], "-")
    local c = split(a[2], ":")
    local dt = { year = tonumber(b[1]), month = tonumber(b[2]), day = tonumber(b[3]),
               hour = tonumber(c[1]), min = tonumber(c[2]), sec = tonumber(c[3]) }
    return dt
end

local function baziPaiPanProc(params)
    local birthday,sex,ast = params.birthday,params.sex,params.astFlag
    local lon,lifa   = params.longitude,params.calendar
    local data = {}

    --时间格式统一为 yyyy-MM-dd hh:mm:ss,输入时分秒在没有时默认为0
    local dt = strToTimetable(birthday)

    local bz = bazi:new(dt,sex,ast,lon,lifa)
    bz:Paipan()

    --定气方式
    local lifaInfo = bz:printLifa()

    --公历生日
    local mstBirthInfo = bz:printMst()

    --农历生日
    local lunarBirthInfo = bz:printLunar()

    --虚岁
    local nominalAge = bz:printAge()

    --真太阳时
    local astInfo = bz:renderAST()

    --节气
    local solarInfo = bz:renderSolarterms()

    --四柱信息
    local baziInfo = bz:renderBaZi()

    --大运信息
    local dayunInfo = bz:renderDaYun()

    data = {
            lifa = lifaInfo,
            mstBirth = mstBirthInfo,
            lunarBirth = lunarBirthInfo,
            nominalAge = nominalAge,
            ast = astInfo,
            solar = solarInfo,
            bazi = baziInfo,
            dayun = dayunInfo
        }

    return data

end


local function doBusiness(params)
    if empty(params) then
        return WEBSERVER_error.busi_error("request params is empty!")
    end

    local status,baziData = pcall(baziPaiPanProc,params)


    if empty(baziData) then
        return WEBSERVER_error.busi_error("can't get correct bazi information!")
    end

    return baziData
end

local function getParams()
    local req = WEBSERVER_request:new()

    if string.upper(req.method) ~= 'POST' then
        WEBSERVER_error.param_error('http method is not POST, params error')
    end

    local reqBody = req:get_request_body()
    local status, reqJson = pcall(decode, reqBody)
    if not status then
        WEBSERVER_error.param_error('decode request body params error')
    end

    local data = reqJson["data"]
    local params = {}
    if data then
        --birthday(生日),sex(性别),AST(太阳时 apparent solar time)
        --lon(出生地经度：longitude),lifa(历法 calendar )

        local birthday  =  data["birthday"]  --生日
        local sex       =  tonumber(data["sex"])       --性别
        local astFlag   =  tonumber(data["astFlag"])   --是否真太阳时
        local longitude =  tonumber(data["longitude"]) --出生地级度
        local calendar  =  tonumber(data["calendar"])

        if not birthday or type(birthday) ~= 'string' then
            WEBSERVER_error.param_error("birthday params error")
        end

        if not sex  or sex < 0 then
            WEBSERVER_error.param_error("sex params error")
        end

        if not astFlag then
            astFlag = 0
        else
            if astFlag ~= 0 and astFlag ~=1 then
                WEBSERVER_error.param_error("apparent solar time params error")
            end
        end

        --默认中央经度
        if not longitude then
            longitude = 120
        end

        --默认平气法定冬至
        if not calendar then
            calendar = 12
        end

        params['birthday']  = birthday
        params['sex']       = sex
        params['astFlag']   = astFlag
        params['longitude'] = longitude
        params['calendar']  = calendar
    end

    return params
end

local function output(format_result)
    local resp = WEBSERVER_response:new()
    resp:write(format_result)
    resp:finish()
end


------------------------------------------------------------
-- main script begin here :
local status, params  = pcall(getParams)
local result = {}

if status then
    local status, data = pcall(doBusiness,params)
    --ngx.log(ngx.DEBUG,"data type is "..(data))
    if status then
        if data == nil then
            result["code"] = 200
            result["msg"]  = 'biz_error'
            result["data"] = ''
        else
            result["code"] = 0
            result["msg"]  = ''
            result["data"] = data
        end

    else
        result["code"] = data.code or 200
        result["msg"]  = data.msg or  "biz_error"
        result["data"] = ''
    end
else
    result["code"] = params.code
    result["msg"]  = params.msg
    result["data"] = ''
end

local res = WEBSERVER_formatter.json(result)

output(res)