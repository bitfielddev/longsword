local originalCol = Color(201, 165, 112)
local flashes = {
    "muzzleflash_1",
    "muzzleflash_3",
    "muzzleflash_4",
    "muzzleflash_5",
    "muzzleflash_6"
}
function EFFECT:Init( data )
	self.offset = data:GetOrigin() + Vector( 0, 0, 0.2 )
	self.angles = data:GetAngles()
    
    local ent = data:GetEntity()

    local ply = ent:GetOwner()
    local wep = ply:GetActiveWeapon()

    if not IsValid(wep) then return end

    if (game.SinglePlayer() or IsFirstTimePredicted()) then
        ParticleEffectAttach(
            wep.MuzzleFlashName or flashes[math.random(#flashes)],
            PATTACH_POINT_FOLLOW,
            data:GetEntity(),
            data:GetAttachment()
        )    

    end

    -- if not wep.NoFlashShock then
    --     local size = wep.MuzzleFlashShock or "small"
    --     local name = "muzzle_smoke_shock_" .. size

    --     ParticleEffectAttach(
    --         name,
    --         PATTACH_POINT_FOLLOW,
    --         data:GetEntity(),
    --         data:GetAttachment()
    --     )
    -- end

    if CLIENT then
        local light = DynamicLight(ent:EntIndex())
        if not light then return longsword.debugPrint("Couldn't create dynamic light.") end

        local col = wep.LightColor or originalCol
    
        light.pos = LocalPlayer():GetShootPos()
        light.r = col.r
        light.g = col.g
        light.b = col.b
        light.brightness = 2
        light.decay = 5000
        light.dietime = 0.2
        light.size = 256
    end
end
