--[[
    mysql操作库
--]]

local mysqlMod = require("resty.mysql")
local Mysql = {}

function Mysql:new(conf)
    local _instance = {
        _conf = {},
        _conn = nil
    }

    if conf ~= nil and type(conf) == 'table' then
        _instance._conf.host             = conf.host
        _instance._conf.port             = conf.port
        _instance._conf.user             = conf.user
        _instance._conf.password         = conf.password
        _instance._conf.database         = conf.dbname
        _instance._conf.timeout          = conf.timeout or 5000
        _instance._conf.charset          = conf.charset or 'UTF8'
        _instance._conf.max_idle_timeout = conf.max_idle_timeout or 12000
        _instance._conf.pool_size        = conf.pool_size or 1000
    else
        return nil, "arg conf must be table type"
    end

    setmetatable(_instance, {__index = self})
    return _instance
end

function Mysql:connect()
    if self._conn ~= nil then
        return self._conn
    end

    self._conn, err = mysqlMod:new()
    if not self._conn then
        ngx.log(ngx.ERR, "[Mysql:connect] failed to create mysql : ", err)
        return nil, "failed to instantiate mysql"
    end
    self._conn:set_timeout(self._conf.timeout)
    local ok, err, errno, sqlstate = self._conn:connect(self._conf)
    if not ok then
        ngx.log(ngx.ERR, "[Mysql:connect] failed to connect mysql : ", err)
        return ok, err, errno, sqlstate
    end
    -- set charset
    local res, err, errno, sqlstate = self._conn:query("SET NAMES " .. self._conf.charset)
    if not res then
        ngx.log(ngx.ERR, "[Mysql:connect] set charset fail : ", err)
    end
    return self._conn
end


--重写模块
function Mysql:query(sql)
    local conn = self:connect()
    if conn == nil then
        ngx.log(ngx.ERR, "[Mysql:query] fail to connect host : ".. self._conf.host ..
                         " port : " .. self._conf.port)
        return
    end

    -- exec sql
    local res, err, errno, sqlstate = conn:query(sql)

    if not res then
        ngx.log(ngx.ERR,"fail to execute sql, error : " .. err .. " errno : " .. (errno or -1)..
	                            " sqlstate : " .. (sqlstate or "unkown").. "  sql : " .. sql)
    end
    return res, err, errno, sqlstate
end



function Mysql:close()
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
        ngx.log(ngx.ERR, "[Mysql:close] set keepalive failed : ", err)
    else
        ngx.log(ngx.INFO, "[Mysql:close] set keepalive ok.")
    end

    return true
end

--增加事务处理
function Mysql:open_and_begin()
    local conn = self:connect()
    if conn == nil then
        ngx.log(ngx.ERR, "[Mysql:query] fail to connect host : ".. self._conf.host ..
                         " port : " .. self._conf.port)
        return
    end
    local res, err, errno, sqlstate = conn:query("begin;")
    if not res then
        ngx.log(ngx.ERR,"fail to execute sql, error : " .. err .. " errno : " .. (errno or -1)..
	                            " sqlstate : " .. (sqlstate or "unkown").. "  sql : " .. sql)
    end
    return res, err
end

function Mysql:qry(sql)
    -- exec sql
    local res, err, errno, sqlstate = self._conn:query(sql)

    if not res then
        ngx.log(ngx.ERR,"fail to execute sql, error : " .. err .. " errno : " .. (errno or -1)..
	                            " sqlstate : " .. (sqlstate or "unkown").. "  sql : " .. sql)
    end
    return res, err, errno, sqlstate
end

function Mysql:commit_and_close(status)
    local sql = "commit;"
    if not status then
        sql ="rollback;"
    end
    local res, err, errno, sqlstate = self._conn:query(sql)
    if not res then
        ngx.log(ngx.ERR,"fail to execute sql, error : " .. err .. " errno : " .. (errno or -1)..
	                            " sqlstate : " .. (sqlstate or "unkown").. "  sql : " .. sql)
    else
        self:close() end
end


return Mysql