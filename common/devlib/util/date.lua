--[[
    日期相关函数
--]]
local _M = {}

local str_util = require("util.str")

function _M.get_ngx_time()
    return ngx.time()
end

function _M.get_ngx_today()
    return ngx.today()
end

function _M.get_timestamp()
    return os.date('%Y-%m-%d %H:%M:%S', ngx.time())
end

function _M.parse_time(r)
    local a = str_util.split(r, " ")
    local b = str_util.split(a[1], "-")
    local c = str_util.split(a[2], ":")
    return os.time({ year = b[1], month = b[2], day = b[3], hour = c[1], min = c[2], sec = c[3] })
end

return _M