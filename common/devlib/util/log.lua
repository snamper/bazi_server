--[[
    日志相关函数
--]]

local Log = {
    LEVEL = {
        DEBUG  = 1, 
        INFO   = 2,
        NOTICE = 3,
        WARN   = 4,
        ERROR  = 5
    }
}

function Log:new(level)

    local _instance = {
	      _level = Log.LEVEL.ERROR
    }
    
    if level ~= nil then
        if level ~= self.LEVEL.DEBUG and level ~= self.LEVEL.INFO
            and level ~= self.LEVEL.NOTICE and level ~= self.LEVEL.WARN
            and level ~= self.LEVEL.ERROR then 
            error('arg level must be log level value')
        else
            _instance._level = level
        end
    end

    setmetatable(_instance, {__index = self})
    return _instance
end

function Log:debug(msg)
    if self._level <= self.LEVEL.DEBUG then
        ngx.log(ngx.DEBUG, msg)
    end
end

function Log:info(msg)
    if self._level <= self.LEVEL.INFO then
        ngx.log(ngx.INFO, msg)
    end 
end

function Log:notice(msg)
    if self._level <= self.LEVEL.NOTICE then
        ngx.log(ngx.NOTICE, msg)
    end
end

function Log:warn(msg)
    if self._level <= self.LEVEL.WARN then
        ngx.log(ngx.WARN, msg)
    end
end

function Log:error(msg)
    if self._level <= self.LEVEL.ERROR then
        ngx.log(ngx.ERR, msg)
    end
end

return Log
