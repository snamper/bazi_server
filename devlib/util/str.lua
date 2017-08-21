--[[
      字符串相关函数
--]]

local _M = {}

function _M.split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end


function _M.start_with(str, substr)
    if str == nil or substr == nil then
        return false
    end
    if string.find(str, substr) ~= 1 then
        return false
    else
        return true
    end
end

function _M.end_with(str, substr)
    if str == nil or substr == nil then
        return false
    end
    local str_tmp, substr_tmp = string.reverse(str), string.reverse(substr)
    if string.find(str_tmp, substr_tmp) ~= 1 then
        return false
    else
        return true
    end
end

function _M.index_of(str, substr)
    return string.find(str, substr, 1, true)
end

function _M.last_index_of(str, substr)
    return string.match(str, '.*()' .. substr)
end

function _M.trim(str)
    return str:match '^()%s*$' and '' or str:match '^%s*(.*%S)'
end

function _M.encode_url(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])",
            --str = string.gsub (str, "([^%w %-%_%.%!%~%*%'%(%,%)])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

function _M.decode_url(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)",
        function(h) return string.char(tonumber(h, 16)) end)
    str = string.gsub(str, "\r\n", "\n")
    return str
end

-- encode base64
function _M.encode_base64(str)
    return ngx.encode_base64(str)
end

-- decode base64
function _M.decode_base64(str)
    return ngx.decode_base64(str)
end

-- md5
function _M.md5(str)
    return ngx.md5(str)
end

-- sha1
function _M.sha1(str)
    local resty_str = require("resty.string")
    return resty_str.to_hex(ngx.sha1_bin(str))
end

return _M