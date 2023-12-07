local wepMeta = FindMetaTable("Weapon")

function wepMeta:GiveAttachment(id)
    if not self.IsLongsword then return end
    self.EquippedAttachments = self.EquippedAttachments or {}
    self.EquippedAttachments[id] = true
    
    self:ProcessAttachmentAdd(id)

    net.Start("longswordAttachmentAdd")
    net.WriteUInt(self:GetOwner():EntIndex(), 32)
    net.WriteString(id)
    net.Broadcast()
end

function wepMeta:TakeAttachment(id)
    if not self.IsLongsword then return end
    self.EquippedAttachments = self.EquippedAttachments or {}
    self.EquippedAttachments[id] = nil

    self:ProcessAttachmentRemove(id)
    net.Start("longswordAttachmentRemove")
    net.WriteUInt(self:GetOwner():EntIndex(), 32)
    net.WriteString(id)
    net.Broadcast()
end
