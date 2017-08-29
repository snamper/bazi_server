--[[
      格式处理的相关函数
--]]

local _M = {}
local cjson = require("cjson")

function _M.json(data)
    if type(data) ~= 'table' then
        return nil
    end
    cjson.encode_empty_table_as_object(false)
    return cjson.encode(data)
end

function _M.decode(str_json)
    if type(str_json) ~= 'string' then
        return nil
    end
    return cjson.decode(str_json)
    --return instance:decode(str_json)
end

return _M