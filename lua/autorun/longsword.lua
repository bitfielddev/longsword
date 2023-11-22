longsword = longsword or {}

longsword.CLIENT = 1
longsword.SERVER = 2
longsword.SHARED = 3

WEAPON_SHOTGUN = 1
WEAPON_MELEE = 2
WEAPON_PROJECTILE = 3

function RPM(rpm)
	return 60 / rpm
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

longsword.includeDirectory("longsword/lib")
longsword.includeDirectory("longsword")
longsword.includeDirectory("longsword/hooks")