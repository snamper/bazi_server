local _M = {}

function _M.qry(ins, sql)
    local mysql = WEBSERVER_mysql:new(WEBSERVER_conf.get_db_conf(ins))
    if mysql then
        local status, data = pcall(mysql.query, mysql,  sql)
        if not status then
            ngx.log(ngx.ERR, "mysql query err:", data)
            return
        end
        mysql:close()
        return data
    else
        return
    end
end

function _M.muti_qry(ins, nrow)
    local mysql = WEBSERVER_mysql:new(WEBSERVER_conf.get_db_conf(ins))
    if mysql then
        local status, data =  pcall(mysql.muti_qry, mysql,  nrow)
        if not status then
            ngx.log(ngx.ERR, "mysql muti_qry err:", data)
            return
        end
        mysql:close()
        return data
    else
        return
    end
end

function _M.null_string(field, default)
    if not field or field == ngx.null then
        return default or ""
    else
        return field
    end
end

function _M.null_int(field, default)
    if not  field or field == ngx.null then
        return  default or -1
    else
        return field
    end
end

return _M