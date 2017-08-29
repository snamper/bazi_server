--[[
    参数校验的相关函数
--]]
local ipairs = ipairs
local _M = {}

-- 对输入参数逐个进行校验，只要有一个不是数字类型，则返回 false
function _M.is_number(...)
    local arg = {...}
    local num
    for _, v in ipairs(arg) do
        num = tonumber(v)
        if num == nil then
            return false
        end
    end

    return true
end

function _M.is_alpha(...)
    local arg = {...}
    local format = '%a+'
    local begin_pos, end_pos

    for _, v in ipairs(arg) do
        begin_pos, end_pos = string.find(v, format)
        if begin_pos == nil or end_pos - begin_pos ~= string.len(v) - 1 then
            return false
        end
    end

    return true
end

function _M.is_date(date_str)
    local format = '%d+[-][0-1]%d[-][0-3]%d'
    local begin_pos, end_pos = string.find(date_str, format)
    if begin_pos ~= nil then
        return true
    end

    format = '%d+[0-1]%d[0-3]%d'
    begin_pos, end_pos = string.find(date_str, format)
    if begin_pos ~= nil then
        return true
    end

    return false
end

return _M