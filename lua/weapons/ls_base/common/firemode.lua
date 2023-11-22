function SWEP:ToggleFireMode()
    if not self.FireModes then return end
    local index = self.FireMode or 1

    if index >= #self.FireModes then
        index = 1
    else
        index = index + 1
    end

    local data = self.FireModes[index]
    
end