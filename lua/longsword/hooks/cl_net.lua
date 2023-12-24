net.Receive("longswordEcho", function()
    local entID = net.ReadUInt(32)
    local ply = Entity(entID)

    if not IsValid(ply) or not ply:IsPlayer() then return end

    if ply == LocalPlayer()  then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.IsLongsword then return end

    longsword.echo(wep, ply)
end)

net.Receive("longswordAttachmentAdd", function()
    local entID = net.ReadUInt(32)
    local id = net.ReadString()

    if not entID or not id then return end

    local ply = Entity(entID)
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.IsLongsword then return end

    wep:GiveAttachment(id)

end)

net.Receive("longswordAttachmentRemove", function()
    local entID = net.ReadUInt(32)
    local id = net.ReadString()

    if not entID or not id then return end

    local ply = Entity(entID)
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.IsLongsword then return end

    wep:TakeAttachment(id)
end)

net.Receive("longswordNotify", function()
    local msg = net.ReadString()
    notification.AddLegacy(msg, NOTIFY_GENERIC, 3)
end)

net.Receive("longswordDynSound", function()
    local snd = net.ReadString()
    local pitch = net.ReadUInt(16)
    local level = net.ReadUInt(16)
    local eid = net.ReadUInt(32)
    local vol = net.ReadFloat()
    local noMuffle = net.ReadBool()

    local ent = Entity(eid)
    if not IsValid(ent) then return end

    ent:EmitDynSound(snd, pitch, level, vol, noMuffle)
end)