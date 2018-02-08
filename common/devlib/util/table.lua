--[[
     table相关的处理函数
--]]

local _M = {}

function _M.print(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos,val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val, indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val) == "string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t).." {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

function _M.index(t, value)
    if type(t) ~= 'table' then
        return nil
    end

    for i, v in ipairs(t) do
        ngx.log(ngx.ERR, v.." "..value)
        if v == value then
            return i
        end
    end

    return nil
end

function _M.sub(t, start_pos, end_pos)
    local t_count = #t

    if start_pos < 0 then
        start_pos = t_count + start_pos + 1
    end

    if end_pos < 0 then
        end_pos = t_count + end_pos + 1
    end

    if start_pos <= 0 or start_pos > t_count or end_pos <= 0 then
        return nil
    end

    end_pos = math.min(t_count, end_pos)

    local new_t = {}
    for i = start_pos, end_pos, 1 do
        table.insert(new_t, t[i])
    end

    return new_t
end

function _M.get_by_num(t, num)
    local n  = #t
    if type(num) ~= "number" then
        return
    end
    if  num >= n or num <= 0 then
        return t
    else
        local tmp = {}
        for i= 1, num do
            tmp[i] = t[i]
        end
        return tmp
    end
end

function _M.extend(t, t1)
    for _, v in ipairs(t1) do
        table.insert(t, v)
    end
    return t
end

function _M.merge(t1, t2)
    local new_t = {}
    if type(t1) == 'table' then
        for _, v in ipairs(t1) do
            table.insert(new_t, v)
        end
    end
    if type(t2) == 'table' then
        for i,v in ipairs(t2) do
            table.insert(new_t, v)
        end
    end
    return new_t
end

function _M.update(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

function  _M.rm_value(t, value)
    local idx = table_index(t, value)
    if idx then
        table_remove(t, idx)
    end
    return idx
end

function _M.contains_value(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function _M.contains_key(t, element)
    return t[element] ~= nil
end

function _M.count(t, value)
    local count = 0
    for _, v in ipairs(t) do
        if v == value then
            count = count + 1
        end
    end
    return count
end

function _M.real_length(t)
    local count = 0
    for _, v in pairs(t) do
        count = count + 1
    end
    return count
end

function _M.empty(t)
    if not t then
        return true
    end
    if type(t) == 'table' and next(t) == nil then
        return true
    end
    return false
end

function _M.unique(t)
    local n_t1 = {}
    local n_t2 = {}
    for _, v in ipairs(t) do
        if n_t1[v] == nil then
            n_t1[v] = v
            table.insert(n_t2, v)
        end
    end
    return n_t2
end

function _M.excepted(t1, t2)
    local ret = {}
    for _, v1 in ipairs(t1) do
        local finded = false
        for _, v2 in ipairs(t2) do
            if type(v2) == type(v1) and v1 == v2 then
                finded = true
                break
            end
        end
        if not finded then
            table.insert(ret,v1)
        end
    end
    return ret
end

function _M.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

 function  _M.reverse(tab)
    if type(tab) ~= "table" then
        return nil
    end
    local tmp = {}
    for i = 1, #tab do
        local key = #tab
        tmp[i] = table.remove(tab)
    end
    return tmp
end

 function  _M.reverseNewArray(tab)
    if type(tab) ~= "table" then
        return nil
    end
    local tmp = {}
    local index = 1
    for i = #tab, 1 , -1 do
        tmp[index] = tab[i]
        index = index + 1
    end
    return tmp
end

return _M