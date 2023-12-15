function SWEP:PlayFireSound()
    if self.Primary.LoopSound then return end
    
    local ply = self:GetOwner()
    local dsp = 20

    local trace = {}
        trace.start = ply:EyePos()
        trace.endpos = trace.start + ply:GetUp() * 32765
        trace.filter = ply
    local tr = util.TraceLine(trace)
    local hitpos = tr.HitPos

    if isvector(hitpos) then
        local zdist = hitpos.z - trace.start.z
        if zdist < 200 then
            dsp = 1
        elseif zdist > 200 and zdist < 1200 then
            dsp = 10
        elseif zdist > 1200 then
            dsp = 20
        end

    end

    if CLIENT then
        self:EmitWeaponSound(self.Primary.Sound)
    else
        self:EmitSound(self.Primary.Sound, nil, nil, nil, nil, nil, dsp)
    end

    if self.Primary.SoundLayers then
        for _, snd in pairs(self.Primary.SoundLayers) do
            self:EmitWeaponSound(snd)
        end
    end
end