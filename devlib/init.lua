--[[
    在“ngx_lua”模块的“init_by_lua_file”命令中执行;
    只在启动nginx时初始化一次。
    定义的全部是全局变量
--]]

--常用库
WEBSERVER_cjson     = require("cjson")
WEBSERVER_request   = require("core.request")
WEBSERVER_response  = require("core.response")
WEBSERVER_formatter = require("core.formatter")
WEBSERVER_error     = require("core.error")
WEBSERVER_conf      = require("core.config")

WEBSERVER_redis     = require("dao.redis")
WEBSERVER_mysql     = require("dao.mysql")

local log          = require("util.log")
WEBSERVER_log       = log:new(log.LEVEL.DEBUG)
WEBSERVER_param     = require("util.param")
WEBSERVER_table     = require("util.table")

WEBSERVER_str     = require("util.str")

WEBSERVER_redis_func    = require("util.redis_func")

WEBSERVER_mysql_func    = require("util.mysql_func")

WEBSERVER_LRU    = require("util.lru")
