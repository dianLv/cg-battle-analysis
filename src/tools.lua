-- 
-- 工具类
-- 

local Tools = {}
-- debuf flag
Tools.DEBUG = false
-- Tools.VERSION = '0.0.5'

function Tools.assert(val, default_type, msg)
    assert(type(val) == default_type, msg .. ', but find ' .. type(val))
end

local function keys(val)
    -- assert(type(val) == 'table', 'request table, but find ' .. type(val))
    Tools.assert(val, 'table', 'request table')
    local ks = {}
    for k, _ in pairs(val) do
        table.insert(ks, k)
    end
    return ks
end

-- origin: cocos/scripting/lua-bindings/script/cocos2d/functions.lua
function Tools.clone(object)
  local lookup_table = {}
  local function copyObj(object)
    if type( object ) ~= "table" then
        return object
    elseif lookup_table[object] then
        return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for key, value in pairs(object) do
        new_table[copyObj(key)] = copyObj(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return copyObj(object)
end

function Tools.is_empty(value)
    -- return value == nil or #value == 0
    return value == nil or #keys(value) == 0
end

function Tools.is_true(bool)
    if bool then
        if type(bool) == 'boolean' then
            return bool
        end

        if type(bool) == 'string' then
            return string.lower(bool) == 'true'
        end
    end

    return false
end

------- Dump About, START -------
local padding_cache = {}
padding_cache[0] = ''
padding_cache[1] = '  '

local function padding(indent)
  local cache = padding_cache[indent]
  if cache then
    return cache
  end
  local _val = {}
  for i=1, indent do
    table.insert(_val, padding_cache[1])
  end
  local val = table.concat(_val, '')
  padding_cache[indent] = val
  return val
end

local function to_string(value, indent)
    local _type = type(value)
    local _indent = indent or 0
    if _type == 'table' then
        local str = {}
        table.insert(str, '{\n')
        for k,v in pairs(value) do
            table.insert(str, string.format('%s%s=%s,\n', padding(_indent+1), k, to_string(v, _indent+1)))
        end
        table.insert(str, padding(_indent) .. '}')
        return table.concat(str, '')
    elseif _type == 'nil' then
        return 'nil'
    elseif _type == 'boolean' or _type == 'number' then
        return value
    elseif _type == 'string' then
        return '\'' .. value .. '\''
    elseif _type == 'function' then
        return 'function'
    else 
        -- 不处理thread, userdata
        return 'unknown type: ' .. _type
    end
end

function Tools.dump(value, msg)
    if msg then
        print(msg .. ' Dump Information:')
    else
        print('Dump Information:')
    end

    print(to_string(value))
end

------- Dump About END -------

return Tools