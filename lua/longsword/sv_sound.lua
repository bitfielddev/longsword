longsword.sound = longsword.sound or {}
local meta = FindMetaTable("Entity")

function meta:EmitDynSound(path, pitch, level, volume, noMuffle)
    pitch = pitch or 100
    level = level or 100
    volume = volume or 1

    local rec = RecipientFilter()

    for _, ply in pairs(player.GetAll()) do
        if ply:GetPos():DistToSqr(self:GetPos()) < (5000 ^ 2) then
            rec:AddPlayer(ply)
        end
    end

    net.Start("longswordDynSound")
    net.WriteString(path)
    net.WriteUInt(pitch, 16)
    net.WriteUInt(level, 16)
    net.WriteUInt(self:EntIndex(), 32)
    net.WriteFloat(volume)
    net.WriteBool(noMuffle or false)
    net.Send(rec)
end