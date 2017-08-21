--[[
     获取指定配置
--]]

local _M = {}

local function _get_config(conf_file, k, default)
    local conf = require(conf_file)
    if conf[k] ~= nil then
        return conf[k]
    else
        return default
    end
end


function _M.get_db_conf(db_name)
    return _get_config("conf", db_name)
end

function _M.get_redis_conf(redis_name)
    return _get_config("conf", redis_name)
end

function _M.get_file_conf(file_type)
    return _get_config("conf", file_type)
end

return _M