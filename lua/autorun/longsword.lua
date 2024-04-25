longsword = longsword or {}
longsword.config = longsword.config or {}
longsword.version = "2.3.0"

longsword.CLIENT = 1
longsword.SERVER = 2
longsword.SHARED = 3

function RPM(rpm)
	return 60 / rpm
end

function tern(condition, value, default)
    if not isbool(condition) then return longsword.util.tern(condition != nil, value, default) end

    if condition then return value else return default end
end

--- Includes a file by auto-detecting its realm.
-- @string filePath The file path
-- @realm shared
-- @internal
function longsword.include(filePath)
    local realm = string.find(filePath, "cl_") and longsword.CLIENT or (string.find(filePath, "sv_") and longsword.SERVER or longsword.SHARED)

    if realm == longsword.CLIENT then
        AddCSLuaFile(filePath)
        if CLIENT then
            include(filePath)
        end
    elseif realm == longsword.SERVER and SERVER then
        include(filePath)
    else
        AddCSLuaFile(filePath)
        include(filePath)
    end
end

--- Includes all file in a directory using longsword.include
-- @string dirPath The directory path
-- @realm shared
function longsword.includeDirectory(dirPath)
    for _, fileName in pairs(file.Find(dirPath .. "/*.lua", "LUA")) do
        longsword.include(dirPath .. "/" .. fileName)
    end
end

--- Prints only when `developer 1` is enabled
-- @string msg The message to print
-- @realm shared
function longsword.debugPrint(msg)
    local dev = GetConVar("developer")
    if dev:GetBool() then
        print("[longsword debug] " .. msg)
    end
end

local blue = Color(0, 0, 255)
local gray = Color(155, 155, 155)

function longsword.print(...)
    local text = table.concat({...}, "")
    MsgC("[", blue, "longsword", gray, "] ", color_white, text, "\n")
end

longsword.includeDirectory("longsword/lib")
longsword.includeDirectory("longsword")
longsword.includeDirectory("longsword/hooks")