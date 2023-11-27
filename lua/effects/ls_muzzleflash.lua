function EFFECT:Init( data )
	self.offset = data:GetOrigin() + Vector( 0, 0, 0.2 )
	self.angles = data:GetAngles()
    
    local ent = data:GetEntity()

    local ply = ent:GetOwner()
    local wep = ply:GetActiveWeapon()

    if not IsValid(wep) then return end

    if (game.SinglePlayer() or IsFirstTimePredicted()) then
        wep.NextFlash = wep.NextFlash or 0

        if wep.NextFlash < CurTime() then
            ParticleEffectAttach(
                wep.MuzzleFlashName or "muzzleflash_pistol",
                PATTACH_POINT_FOLLOW,
                data:GetEntity(),
                data:GetAttachment()
            )    

            wep.NextFlash = CurTime() + 0.25
        end

    end

    if not wep.NoFlashShock then
        local size = self.MuzzleFlashShock or "small"
        local name = "muzzle_smoke_shock_" .. size

        ParticleEffectAttach(
            name,
            PATTACH_POINT_FOLLOW,
            data:GetEntity(),
            data:GetAttachment()
        )
    end
end
