function SWEP:ToggleFireMode()
    if not self.FireModes or #self.FireModes == 1 then return end
    local index = self.FireMode or 1
    if index >= #self.FireModes then
        index = 1
    else
        index = index + 1
    end

    self.FireMode = index

    local data = self.FireModes[index]
    
end