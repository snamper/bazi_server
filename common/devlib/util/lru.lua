--[[
      lrucache
--]]

local lrucache = require "resty.lrucache"

local _M = {}
local c = lrucache.new(1800)
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

function _M.set(key, value, exp)
    if exp then
        c:set(key, value, exp)
    else
        c:set(key, value)
    end
end

function _M.get(key)
   return c:get(key)
end

return _M