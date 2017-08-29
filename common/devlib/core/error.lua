--[[
    错误处理的相关函数
]]

local _M = {
     CODE_PRARM   = "100",
     CODE_BUSI    = "200",
     CODE_REDIS   = "300",
     CODE_DB      = "400",
     CODE_UNKNOWN = "900"
}

local function _filter_prefix(msg)
    local pos_begin, pos_end = string.find(msg, ".lua:%d+:")
    if pos_begin == nil then
        return msg
    else
        error_msg = string.sub(msg, pos_end + 1)
    end
    return error_msg
end

------------------------------ PUBLIC INTERFACE ------------------------------------
--the function given to the user

function _M.param_error(error_msg)
    if error_msg == nil then
        error_msg = 'param error'
    end
    error_msg = _filter_prefix(error_msg)
    error({code = _M.CODE_PRARM, msg = error_msg})
end

function _M.busi_error(error_msg)
    if error_msg == nil then
        error_msg = 'business error'
    end
    error_msg = _filter_prefix(error_msg)
    error({code = _M.CODE_BUSI, msg = error_msg})
end

function _M.redis_error(error_msg)
    if error_msg == nil then
        error_msg = 'redis error'
    end
    error_msg = _filter_prefix(error_msg)
    error({code = _M.CODE_REDIS, msg = error_msg})
end

function _M.db_error(error_msg)
    if error_msg == nil then
        error_msg = 'mysql error'
    end
    --error_msg = _filter_prefix(error_msg)
    error({code = _M.CODE_DB, msg = error_msg})
end

function _M.error(error_msg)
    if error_msg == nil then
        error_msg = 'unknow error'
    end
    error_msg = _filter_prefix(error_msg)
    error({code = _M.CODE_UNKNOWN, msg = error_msg})
end

return _M