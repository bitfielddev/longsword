longsword.net = longsword.net or {}

util.AddNetworkString("longswordEcho")
util.AddNetworkString("longswordNotify")
util.AddNetworkString("longswordAttachmentAdd")
util.AddNetworkString("longswordAttachmentRemove")
util.AddNetworkString("longswordDynSound")

local plyMeta = FindMetaTable("Player")

function plyMeta:LS_Notify(msg)
    if impulse then
        return self:Notify(msg)
    end

    net.Start("longswordNotify")
    net.WriteString(msg)
    net.Send(self)
end
