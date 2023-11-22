function EFFECT:Init( data )
	self.offset = data:GetOrigin() + Vector( 0, 0, 0.2 )
	self.angles = data:GetAngles()
    
    local ent = data:GetEntity()

    local ply = ent:GetOwner()
    local wep = ply:GetActiveWeapon()

    if not IsValid(wep) then return end

    ParticleEffectAttach(
        wep.MuzzleFlashName or "muzzleflash_pistol",
        PATTACH_POINT_FOLLOW,
        data:GetEntity(),
        data:GetAttachment()
    )

    -- if not wep.NoFlashShock then
    --     local size = self.MuzzleFlashShock or "small"
    --     local name = "muzzle_smoke_shock_" .. size

    --     ParticleEffectAttach(
    --         name,
    --         PATTACH_POINT_FOLLOW,
    --         data:GetEntity(),
    --         data:GetAttachment()
    --     )
    -- end
end
