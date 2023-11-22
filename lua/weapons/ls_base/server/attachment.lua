function SWEP:GiveAttachment(id)
    self.EquippedAttachments = self.EquippedAttachments or {}
    self.EquippedAttachments[id] = true
    
    self:ProcessAttachmentAdd(id)

    net.Start("longswordAttachmentAdd")
    net.WriteUInt(self:GetOwner():EntIndex(), 32)
    net.WriteString(id)
    net.Broadcast()
end

function SWEP:TakeAttachment(id)
    self.EquippedAttachments = self.EquippedAttachments or {}
    self.EquippedAttachments[id] = nil

    self:ProcessAttachmentRemove(id)
    net.Start("longswordAttachmentRemove")
    net.WriteUInt(self:GetOwner():EntIndex(), 32)
    net.WriteString(id)
    net.Broadcast()
end
