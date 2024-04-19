AddCSLuaFile()

SWEP.Base = "ls_base" // for non-magazine shotguns set SWEP.Shotgun to true

SWEP.PrintName = "MP7 Submachine Gun"
SWEP.Category = "Gateway: Firearms"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.HoldType = "smg"

SWEP.WorldModel = Model("models/weapons/w_inss_mp7a1.mdl")
SWEP.ViewModel = Model("models/weapons/v_inss_mp7a1.mdl")
SWEP.ViewModelFOV = 75
SWEP.ViewModelOffset = Vector(0, 0, 1)

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.CSMuzzleFlashes = false
SWEP.DoEmptyReloadAnim = true 

SWEP.EmptySound = Sound("Weapon_AKM.Empty")

SWEP.Primary.Sound = Sound("Weapon_MP7.Single")
SWEP.Primary.Recoil = 2.7 -- base recoil value, SWEP.Spread mods can change this
SWEP.Primary.Damage = 6
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = RPM(670)

SWEP.Primary.Ammo = "4_62"
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 40
SWEP.Primary.DefaultClip = 40

SWEP.Primary.BulletEffect = "ShellEject"
SWEP.Primary.BulletScale = 1
SWEP.Primary.BulletDirection = "right"
SWEP.Primary.EjectAttachment = "shell"

SWEP.Spread = {}
SWEP.Spread.Min = 0
SWEP.Spread.Max = 0.02
SWEP.Spread.IronsightsMod = 0.4 -- multiply
SWEP.Spread.CrouchMod = 0.9 -- crouch effect (multiply)
SWEP.Spread.AirMod = 2 -- how does if the player is in the air effect spread (multiply)
SWEP.Spread.RecoilMod = 0.2 -- how does the recoil effect the spread (sustained fire) (additional)
SWEP.Spread.VelocityMod = 1.3 -- movement speed effect on spread (additonal)

SWEP.IronsightsPos = Vector(-2.651, 0, 1.455)
SWEP.IronsightsAng = Angle(0.4, 0, 0)
SWEP.IronsightsFOV = 1
SWEP.IronsightsSensitivity = 0.8
SWEP.IronsightsCrosshair = false
SWEP.IronsightsAnimation = ACT_VM_PRIMARYATTACK_1

SWEP.UseIronsightsRecoil = true

SWEP.LoweredPos = Vector(0, 0, -2)
SWEP.LoweredAng = Angle(0, 25, 0)

SWEP.Recoil = {}
SWEP.Recoil.RollMultiplier = 0.5
SWEP.Recoil.PitchMultiplier = 0.1
SWEP.Recoil.BackMultiplier = 0.8
SWEP.Recoil.YawMultiplier = 0

SWEP.CenteredPos = Vector(-2.6, 0, -1.5)
SWEP.SwayMul = 0.5

SWEP.MuzzleFlashName = "muzzleflash_ak74"
SWEP.WMOffset = {
    Position = Vector(5, -0.4, -1.5),
    Angle = Angle(2, 0, 180)
}

SWEP.Attachments = {
    ["eotech"] = {
        Cosmetic = {
			Model = "models/weapons/insurgency_sandstorm/upgrades/sandstorm_optic_eotech.mdl",
			Bone = "A_Optic",
			Pos = Vector(0, -0.1, 0.5),
			Ang = Angle(0, 0, 90),
			Scale = 1,
			Skin = 0
			--World = {
			--	Pos = Vector(11, 1.5, -6),
			--	Ang = Angle(0, 180, 90),
			--	Scale = 0.85
			--}
		},
        Reticule = {
            Size = 6,
            Pos = Vector(-20, 0.001, 1.15),
            Material = Material("models/weapons/insurgency_sandstorm/ins2_sandstorm/4x_reticule_eotech")
        },
        Modifiers = {
            IronsightsPos = Vector(-2.651, 0, 0.875),
            IronsightsAng = Angle(0.2, 0, 0),
            IronsightsFOV = 0.8,
            ["Primary"] = {
                ["Cone"] = 0.015
            }
        }
    },
    ["aimpoint"] = {
        Cosmetic = {
			Model = "models/weapons/insurgency_sandstorm/upgrades/ismc_optic_micro_t1_l.mdl",
			Bone = "A_Optic",
			Pos = Vector(0, -0.3, 0.5),
			Ang = Angle(0, 0, 90),
			Scale = 1,
			Skin = 0
			--World = {
			--	Pos = Vector(11, 1.5, -6),
			--	Ang = Angle(0, 180, 90),
			--	Scale = 0.85
			--}
		},
        Reticule = {
            Size = 0.2,
            Pos = Vector(-20, 0.001, 1.25),
            Material = Material("models/weapons/insurgency_sandstorm/ins2_sandstorm/aimpoint_reticule_big")
        },
        Modifiers = {
            IronsightsPos = Vector(-2.651, 0, 0.775),
            IronsightsAng = Angle(0.2, 0, 0),
            IronsightsFOV = 0.8,
            ["Primary"] = {
                ["Cone"] = 0.015
            }
        }
    }
}

SWEP.CustomSubMats = {
    [1] = "models/debug/debugwhite",
    [2] = "models/debug/debugwhite"
}

local pref = "TFA_INSS.MP7"
local path = "weapons/ins_mp7/"

local function addSound(name, p)
    sound.Add({
        name = pref .. "." .. name,
        sound = type(p) == "table" and p or path .. p
    })
end

addSound("Magrelease", "mp7_magrelease.wav")
addSound("ROF", "mp7_fireselect.wav")
addSound("Magout", "mp7_magout.wav")
addSound("Magin", "mp7_magin.wav")
addSound("Boltback", "mp7_boltback.wav")
addSound("Boltrelease", "mp7_boltrelease.wav")

sound.Add({
    name = "Weapon_MP7.Single",
    sound = "weapons/mp7/mp7_fp.wav",
    pitch = { 98, 101 },
    channel = CHAN_STATIC
})