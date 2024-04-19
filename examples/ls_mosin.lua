-- This is copied from the GW: Survival project, some things may be inaccurate.
AddCSLuaFile()

SWEP.Base = "ls_base" 
SWEP.Shotgun = true -- The mosin is not a shotgun, but it inserts each bullet individually. This is a good example.

SWEP.PrintName = "Mosin-Nagant"
SWEP.Category = "Gateway: Firearms"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.HoldType = "ar2"

SWEP.WorldModel = Model("models/weapons/w_ins2_mosin_nagant.mdl")
SWEP.ViewModel = Model("models/weapons/c_ins2_mosin_nagant.mdl")
SWEP.ViewModelFOV = 70
SWEP.SwayMode = "drag"

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.CSMuzzleFlashes = false

SWEP.EmptySound = Sound("TFA_INS2.Mosin.Empty")

SWEP.Primary.Sound = Sound("LS_Mosin.Fire")
SWEP.Primary.Recoil = 8.2 -- base recoil value, SWEP.Spread mods can change this
SWEP.Primary.Damage = 60
SWEP.Primary.NumShots = 6
SWEP.Primary.Cone = 0.001
SWEP.Primary.Delay = 1.8

SWEP.Primary.Ammo = "7_62"
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5

SWEP.Spread = {}
SWEP.Spread.Min = 0
SWEP.Spread.Max = 0.005
SWEP.Spread.IronsightsMod = 1 -- multiply
SWEP.Spread.CrouchMod = 0.9 -- crouch effect (multiply)
SWEP.Spread.AirMod = 2 -- how does if the player is in the air effect spread (multiply)
SWEP.Spread.RecoilMod = 0.03 -- how does the recoil effect the spread (sustained fire) (additional)
SWEP.Spread.VelocityMod = 1.3 -- movement speed effect on spread (additonal)

SWEP.IronsightsPos = Vector(-3.09, -2, 1.59)
SWEP.IronsightsAng = Angle(0.035, 0.02, 0)
SWEP.IronsightsFOV = 1
SWEP.IronsightsSensitivity = 0.8
SWEP.IronsightsCrosshair = false
SWEP.UseIronsightsRecoil = true
SWEP.IronsightsSpeed = 0.7

SWEP.Recoil = {}
SWEP.Recoil.Enabled = true
SWEP.Recoil.RollMultiplier = 1.5
SWEP.Recoil.PitchMultiplier = 3

SWEP.LoweredPos = Vector(5, 0, 0)
SWEP.LoweredAng = Angle(-10, 35, 0)
SWEP.WMOffset = {
    Position = Vector(5, -1.7, -1.5),
    Angle = Angle(15, -6.05, 180)
}

SWEP.SwayMul = 2
SWEP.SwayPosMul = 0.25

SWEP.IronsightsRecoilUpMultiplier = 1.4
SWEP.IronsightsRecoilBackMultiplier = 1
SWEP.Attachments = {
    ["scope"] = {
        Cosmetic = {
			Model = "models/weapons/insurgency_sandstorm/upgrades/ismc_optic_nightforce.mdl",
			Bone = "A_Optic",
			Pos = Vector(0, -1, 0),
			Ang = Angle(0, 0, 90),
			Scale = 1,
			Skin = 0
			--World = {
			--	Pos = Vector(11, 1.5, -6),
			--	Ang = Angle(0, 180, 90),
			--	Scale = 0.85
			--}
		},
        Scope = {
            SubMaterial = 5,
            FOV = 3
        },
        Reticule = {
            Size = 2,
            Pos = Vector(1, 0, 1.5),
            Material = Material("models/weapons/insurgency_sandstorm/ins2_ismc/nightforce_reticule"),
            NoMask = false
        },
        Modifiers = {
            IronsightsPos = Vector(-3.09, -2, 0.59),
            IronsightsFOV = 0.8,
            IronsightsSensitivity = 0.2
        }
    }
}

SWEP.MuzzleFlashName = "muzzleflash_shotgun"

function SWEP:CustomShootEffects()
    timer.Simple(0.3, function()
        self:PlayAnim(self:GetIronsights() and ACT_VM_PULLBACK_HIGH or ACT_VM_PULLBACK_LOW)
        self:QueueIdle()
    end)
end


local pref = "TFA_INS2.Mosin"
local path = "weapons/mosin_nagant/"

sound.Add({
    name = "LS_Mosin.Fire",
    sound = path .. "mosin_fire.wav"
})

sound.Add({
    name = pref .. ".Boltback",
    sound = path .. "mosin_boltback.wav"
})

sound.Add({
    name = pref .. ".Boltforward",
    sound = path .. "mosin_boltforward.wav"
})

sound.Add({
    name = pref .. ".Boltrelease",
    sound = path .. "mosin_boltrelease.wav"
})

sound.Add({
    name = pref .. ".Boltlatch",
    sound = path .. "mosin_boltlatch.wav"
})

sound.Add({
    name = pref .. ".Roundin",
    sound = { path .. "mosin_bulletin_1.wav", path .. "mosin_bulletin_2.wav", path .. "mosin_bulletin_3.wav", path .. "mosin_bulletin_4.wav" }
})

sound.Add({
    name = pref .. ".Empty",
    sound = path .. "mosin_empty.wav"
})

sound.Add({
    name = pref .. ".Draw",
    sound = path .. "mosin_draw.wav"
})

sound.Add({
    name = pref .. ".Holster",
    sound = path .. "mosin_draw.wav"
})

SWEP.FollowAtt = "muzzle"