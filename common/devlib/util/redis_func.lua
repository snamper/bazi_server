--[[
    出错的连接 不使用 keep alive
--]]
local _M = {}

function _M.get(redis_instance, key)
    local redis = WEBSERVER_redis:new(WEBSERVER_conf.get_redis_conf(redis_instance))
    local status, data = pcall(redis.get, redis, key)
    if not status then
        ngx.log(ngx.ERR, data)
        return
    end
    redis:close()
    return data
end


function _M.zrange(redis_instance,key, rs, re)
    local redis = WEBSERVER_redis:new(WEBSERVER_conf.get_redis_conf(redis_instance))
    local status, data = pcall(redis.zrange, redis, key,rs,re)
    if not status then
        ngx.log(ngx.ERR, data)
        return
    end
    redis:close()
    return data
end


function _M.lrange(redis_instance,key, rs, re)
    local redis = WEBSERVER_redis:new(WEBSERVER_conf.get_redis_conf(redis_instance))
    local status, data = pcall(redis.lrange, redis, key,rs,re)
    if not status then
        ngx.log(ngx.ERR, data)
        return
    end
   redis:close()
    return data
end

function _M.keys(redis_instance,key)
    local redis = WEBSERVER_redis:new(WEBSERVER_conf.get_redis_conf(redis_instance))
    local status, data = pcall(redis.keys, redis, key)
    if not status then
        ngx.log(ngx.ERR, data)
        return
    end
    redis:close()
    return data
end


function  _M.mget(redis_instance, key)
    local redis = WEBSERVER_redis:new(WEBSERVER_conf.get_redis_conf(redis_instance))
    local status, data = pcall(redis.mget, redis, key)
    if not status then
        ngx.log(ngx.ERR, data)
        return
    end
    redis:close()
    return data
end


function  _M.set(redis_instance, key ,val)
    local redis = WEBSERVER_redis:new(WEBSERVER_conf.get_redis_conf(redis_instance))
    local status, data = pcall(redis.set, redis, key,val)
    if not status then
        ngx.log(ngx.ERR, data)
        return
    end
    redis:close()
    return data
end

function  _M.expire(redis_instance, key, val)
    local redis = WEBSERVER_redis:new(WEBSERVER_conf.get_redis_conf(redis_instance))
    local status, data = pcall(redis.expire, redis, key,val)
    if not status then
        ngx.log(ngx.ERR, data)
        return
    end
    redis:close()
    return data
end

return _M
