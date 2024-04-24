longsword.util = longsword.util or {}

function longsword.util.runHook(hookName, default, ...)
    local res = hook.Run(hookName, ...)
    if res == nil then
        return default
    end
    
    return res
end

function longsword.util.tern(condition, value, default)
    if not isbool(condition) then return longsword.util.tern(condition != nil, value, default) end

    if condition then return value else return default end
end