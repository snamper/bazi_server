--与   同为1，则为1

--或   有一个为1，则为1

--非   true为 false，其余为true

--异或 相同为0，不同为1

local luabit = {}

function luabit.__andBit(left,right)    --与
    return (left == 1 and right == 1) and 1 or 0
end

function luabit.__orBit(left, right)    --或
    return (left == 1 or right == 1) and 1 or 0
end

function luabit.__xorBit(left, right)   --异或
    return (left + right) == 1 and 1 or 0
end

function luabit.__base(left, right, op) --对每一位进行op运算，然后将值返回
    if left < right then
        left, right = right, left
    end
    local res = 0
    local shift = 1
    while left ~= 0 do
        local ra = left % 2    --取得每一位(最右边)
        local rb = right % 2
        res = shift * op(ra,rb) + res
        shift = shift * 2
        left = math.modf( left / 2)  --右移
        right = math.modf( right / 2)
    end
    return res
end

function luabit.andOp(left, right)
    return luabit.__base(left, right, luabit.__andBit)
end

function luabit.xorOp(left, right)
    return luabit.__base(left, right, luabit.__xorBit)
end

function luabit.orOp(left, right)
    return luabit.__base(left, right, luabit.__orBit)
end

function luabit.notOp(left)
    return left > 0 and -(left + 1) or -left - 1
end

function luabit.lShiftOp(left, num)  --left左移num位
    return left * (2 ^ num)
end

function luabit.rShiftOp(left,num)  --right右移num位
    return math.floor(left / (2 ^ num))
end

function luabit.test()
    print( luabit.andOp(65,0x3f))  --65 1000001    63 111111
    print(65 % 64)
    print( luabit.orOp(5678,6789))
    print( luabit.xorOp(13579,2468))
    print( luabit.rShiftOp(16,3))
    print( luabit.notOp(-4))
    print(luabit.xorOp(1,1))
    print(luabit.xorOp(1,0))
    print(luabit.xorOp(0,1))
    print(luabit.xorOp(0,0))

    --print(string.byte("abc",1))
end
--luabit.test()

return luabit