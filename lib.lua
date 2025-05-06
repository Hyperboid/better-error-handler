local lib = {}

Registry.registerGlobal("BetterError", lib)
BetterError = lib

function lib:onRegisterObjects()
    -- Post-objects registration is the earliest time when the ErrorHandler class exists
    Utils.hook(Kristal, "errorHandler", function (orig, msg)
        if type(msg) == "table" then return orig(msg) end
        return ErrorHandler():run(msg)
    end)
end

function lib.isArray(tbl)
    for k,_ in pairs(tbl) do
        if type(k) ~= "number" then
            return false
        end
    end
    return true
end

function lib.dump(o, seen)
    seen = seen or {}
    ---@diagnostic disable-next-line: undefined-global
    if Kristal then
        local ok, res = pcall(Utils.dump, o)
        if ok then return res end
        return "<error! "..res..">"
    end
    if isClass(o) then
        return o.id or "<unknown>"
    end
    if type(o) == 'table' then
        if seen[o] then return "{...}" end
        seen[o] = true
        local s = '{'
        local cn = 1
        if lib.isArray(o) then
            for _,v in ipairs(o) do
                if cn > 1 then s = s .. ', ' end
                s = s .. lib.dump(v, seen)
                cn = cn + 1
            end
        else
            for k,v in pairs(o) do
                if cn > 1 then s = s .. ', ' end
                s = s .. lib.dumpKey(k) .. ' = ' .. lib.dump(v, seen)
                cn = cn + 1
            end
        end
        return s .. '}'
    elseif type(o) == 'string' then
        return '"' .. o .. '"'
    elseif type(o) == "function" then
        local name = debug.getinfo(o).name
        return (tostring(o)) .. (name and ("(" .. name .. ")") or "")
    else
        return tostring(o)
    end
end

function lib.dumpKey(key)
    if type(key) == 'table' then
        return '('..tostring(key)..')'
    elseif type(key) == 'string' and (not key:find("[^%w_]") and not tonumber(key:sub(1,1)) and key ~= "") then
        return key
    else
        return '['..lib.dump(key)..']'
    end
end

function lib.countkeys(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

return lib