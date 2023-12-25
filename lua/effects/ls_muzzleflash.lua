local originalCol = Color(201, 165, 112)
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
                wep.MuzzleFlashName or "muzzleflash_1",
                PATTACH_POINT_FOLLOW,
                data:GetEntity(),
                data:GetAttachment()
            )    

            wep.NextFlash = CurTime() + 0.25
        end

    end

    if not wep.NoFlashShock then
        local size = wep.MuzzleFlashShock or "small"
        local name = "muzzle_smoke_shock_" .. size

        ParticleEffectAttach(
            name,
            PATTACH_POINT_FOLLOW,
            data:GetEntity(),
            data:GetAttachment()
        )
    end

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
