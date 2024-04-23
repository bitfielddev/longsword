longsword.util = longsword.util or {}

function longsword.util.runHook(hookName, default, ...)
    local res = hook.Run(hookName, ...)
    if res == nil then
        return default
    end
    
    return res
end