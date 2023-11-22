function includeShared(path)
    AddCSLuaFile(path)
    include(path)
end

function includeClient(path)
    AddCSLuaFile(path)

    if CLIENT then
        include(path)
    end
end

function includeServer(path)
    if SERVER then
        include(path)
    end
end

includeShared("base.lua")

for _, fName in pairs(file.Find("weapons/ls_base/common/*.lua", "LUA")) do
    local fP = "common/" .. fName
    AddCSLuaFile(fP)
    include(fP)
end

if SERVER then
    for _, fName in pairs(file.Find("weapons/ls_base/server/*.lua", "LUA")) do
        local fP = "server/" .. fName
        include(fP)
    end
end

for _, fName in pairs(file.Find("weapons/ls_base/client/*.lua", "LUA")) do
    local fP = "client/" .. fName
    AddCSLuaFile(fP)
    if CLIENT then
        include(fP)
    end
end