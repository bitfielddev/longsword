local wepMeta = FindMetaTable("Weapon")

function wepMeta:HasAttachment(name)
    if not self.IsLongsword then return end

	self.EquippedAttachments = self.EquippedAttachments or {}
	return self.EquippedAttachments[name]
end

function wepMeta:ProcessAttachmentAdd(attID)
    if not self.IsLongsword then return end

    local data = self.Attachments[attID]
    if not data then return end

	self:ProcessModifiersOn(attID)

    if data.ModSetup then
        data.ModSetup(self)
    end
end

function wepMeta:ProcessModifiersOn(attID)
    if not self.IsLongsword then return end

    local data = self.Attachments[attID]
    if not data then return end

	data._BaseValues = {}

	if data.Modifiers then
        for key, value in pairs(data.Modifiers) do
			data._BaseValues[key] = self[key]

            if type(value) == "table" then
                for k2, v2 in pairs(value) do
                    self[key][k2] = v2
                end
            else
                self[key] = value
            end
        end
    end
end

function wepMeta:ProcessAttachmentRemove(attID)
    if not self.IsLongsword then return end

	local data = self.Attachments[attID]
    if not data then return end

    self:ProcessModifiersOff(attID)

    if data.ModCleanup then
        data.ModCleanup(self)
    end
end

function wepMeta:ProcessModifiersOff(attID)
    if not self.IsLongsword then return end

    local data = self.Attachments[attID]
    if not data then return end

	if data._BaseValues then
        for key, value in pairs(data._BaseValues) do
            self[key] = value
        end

        data._BaseValues = {}
    end
end