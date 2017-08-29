--[[
    redis操作库
--]]

local redisMod = require("resty.redis")
local Redis = {}


function Redis:new(conf)
    local _instance = {
        _conf = {},
        _conn = nil
    }

    if conf ~= nil and type(conf) == 'table' then
        _instance._conf.host             = conf.host
        _instance._conf.port             = conf.port
        _instance._conf.timeout          = conf.timeout or 4000
        _instance._conf.max_idle_timeout = conf.max_idle_timeout or 12000
        _instance._conf.pool_size        = conf.pool_size or 200
    else
        error("arg conf must be table type")
    end
    -- ngx.log(ngx.ERR, "new redis")

    setmetatable(_instance, {__index = self})
    return _instance
end

function Redis:connect()
    if self._conn ~= nil then
        return self._conn
    end

    self._conn, err = redisMod:new()
    if not self._conn then
        ngx.log(ngx.ERR, "[Redis:connect] failed to create redis : ", err)
        return nil
    end
    self._conn:set_timeout(self._conf.timeout)
    local ok, err = self._conn:connect(self._conf.host, self._conf.port)
    if not ok then
        ngx.log(ngx.ERR, "[Redis:connect] failed to connect redis : ", err)
        return nil
    end

    return self._conn
end



function  Redis:keys(key)
    local conn = self:connect()
    if conn == nil then
        error("[Redis:get] fail to connect host : ".. self._conf.host ..
	                                 " port : " .. self._conf.port)
    end
    local res, err = self._conn:keys(key)
    if not res then
        self._conn = nil
	conn = self:connect()
	res, err = self._conn:keys(key)
       if not res then
	        error("fail to get keys, error : " .. err)
        end
    end
    return res, err
end

function Redis:get(key)
    local conn = self:connect()
    if conn == nil then
        error("[Redis:get] fail to connect host : ".. self._conf.host ..
	                                 " port : " .. self._conf.port)
    end

    local res, err = self._conn:get(key)
    if not res then
        self._conn = nil
        conn = self:connect()
        res, err = self._conn:get(key)
        if not res then
            error("fail to get key, error : " .. err)
        end
    end
    return res, err
end


function  Redis:lrange(key,r_start,r_end)
    local conn = self:connect()
    if conn == nil then
        error("[Redis:get] fail to connect host : ".. self._conf.host ..
	                                 " port : " .. self._conf.port)
    end
    local res, err = self._conn:lrange(key,r_start,r_end)
    if not res then
        self._conn = nil
        conn = self:connect()
        res, err = self._conn:lrange(key,r_start,r_end)
            if not res then
            error("fail to get keys, error : " .. err)
        end
    end
    return res, err
end

function  Redis:zrange(key,r_start,r_end)
    local conn = self:connect()
    if conn == nil then
        error("[Redis:get] fail to connect host : ".. self._conf.host ..
	                                 " port : " .. self._conf.port)
    end
    local res, err = self._conn:zrange(key,r_start,r_end)
    if not res then
        self._conn = nil
        conn = self:connect()
        res, err = self._conn:zrange(key,r_start,r_end)
        if not res then
            error("fail to get keys, error : " .. err)
        end
    end
    return res, err
end


function Redis:mget(keys)
    local conn = self:connect()
    if conn == nil then
        error("Redis:get] fail to connect host : ".. self._conf.host ..
	                                " port : " .. self._conf.port)
    end

    local res, err = self._conn:mget(unpack(keys))
    if not res then
        self._conn = nil
        conn = self:connect()
        res, err = self._conn:mget(unpack(keys))
        if not res then
            error("fail to get keys, error : " .. err)
        end
    end
    return res, err
end


function Redis:set(key,val)
    local conn = self:connect()
    if conn == nil then
        error("Redis:get] fail to connect host : ".. self._conf.host ..
	                                " port : " .. self._conf.port)
    end

    local res, err = self._conn:set(key,val)
    if not res then
        self._conn = nil
        conn = self:connect()
        res, err = self._conn:set(key,val)
        if not res then
            error("fail to get keys, error : " .. err)
        end
    end
    return res, err
end



function Redis:expire(key,val)
    local conn = self:connect()
    if conn == nil then
        error("Redis:get] fail to connect host : ".. self._conf.host ..
	                                " port : " .. self._conf.port)
    end

    local res, err = self._conn:expire(key,val)
    if not res then
        self._conn = nil
        conn = self:connect()
        res, err = self._conn:expire(key,val)
        if not res then
            error("fail to get keys, error : " .. err)
        end
    end
    return res, err
end



function Redis:close()
    if not self._conn then
        local error_msg = 'connection is nil, do not need to be closed'
        return false, error_msg
    end
    if self._conf.pool_size <= 0 then
        self._conn:close()
        return true
    end
    -- put it into the connection pool with * seconds max idle timeout
    local ok, err = self._conn:set_keepalive(self._conf.max_idle_timeout, self._conf.pool_size)
    if not ok then
        ngx.log(ngx.ERR, "[Redis:close] set keepalive failed : ", err)
    else
        ngx.log(ngx.DEBUG, "[Redis:close] set keepalive ok.")
    end

    return true
end

return Redis
