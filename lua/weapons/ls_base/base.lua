-- The main file, containing the base data for longsword. 
-- Created by vin and modified by bingu.

SWEP.IsLongsword = true
SWEP.PrintName = "Longsword"
SWEP.Category = "LS"
SWEP.DrawWeaponInfoBox = false

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 55
SWEP.UseHands = true

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.CSMuzzleFlashes = true

SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.Primary.Recoil = 0.8
SWEP.Primary.Damage = 5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.03
SWEP.Primary.Delay = 0.13

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

SWEP.EmptySound = Sound("Weapon_Pistol.Empty")

SWEP.Spread = {}
SWEP.Spread.Min = 0
SWEP.Spread.Max = 0.5
SWEP.Spread.IronsightsMod = 0.1
SWEP.Spread.CrouchMod = 0.6
SWEP.Spread.AirMod = 1.2
SWEP.Spread.RecoilMod = 0.025
SWEP.Spread.VelocityMod = 0.5

SWEP.IronsightsPos = Vector( -5.9613, -3.3101, 2.706 )
SWEP.IronsightsAng = Angle( 0, 0, 0 )
SWEP.IronsightsFOV = 0.8
SWEP.IronsightsSensitivity = 0.8
SWEP.IronsightsCrosshair = false
SWEP.scopedIn = SWEP.scopedIn or false


SWEP.BobScale = 0
SWEP.SwayScale = 0

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Ironsights")
	self:NetworkVar("Bool", 1, "Reloading")
	self:NetworkVar("Bool", 2, "Bursting")
	self:NetworkVar("Bool", 3, "Lowered")

	self:NetworkVar("String", 0, "CurAttachment")

	self:NetworkVar("Float", 1, "IronsightsRecoil")
	self:NetworkVar("Float", 2, "Recoil")
	self:NetworkVar("Float", 3, "ReloadTime")
	self:NetworkVar("Float", 4, "NextIdle")

	if self.ExtraDataTables then -- change these when adding network vars
		self:ExtraDataTables({
			["Bool"] = 3,
			["String"] = 1,
			["Float"] = 4
		})
	end
end

function SWEP:ResetValues()
	self:SetIronsights(false)

	self:SetReloading(false)
	self:SetLowered( false )

	self:SetReloadTime(0)

	self:SetRecoil(0)
	self:SetNextIdle(0)
end

function SWEP:Initialize()
	self:ResetValues()

	self:SetHoldType(self.HoldType)

	if SERVER and self.CustomMaterial then
		self.Weapon:SetMaterial(self.CustomMaterial)
	end

	if self.CustomInit then
		self:CustomInit()
	end
end

function SWEP:OnReloaded()
	if self.OnCodeReload then
		self:OnCodeReload()
	end

	self:ResetValues()

	self:SetLowered(false)
	self:SetHoldType(self.HoldType)

	if self.VMElements then
		for _, element in pairs(self.VMElements) do
			if IsValid(element._CSModel) then
				element._CSModel:Remove()
			end
		end
	end

	for attID, on in pairs(self.EquippedAttachments or {}) do
		if not on then continue end

		self:ProcessModifiersOn(attID)
	end
end

function SWEP:EmitWeaponSound(snd, lvl, pitch, vol)
	self:EmitSound(snd, lvl or 60, pitch or 100, vol or 1, CHAN_AUTO)
end

function SWEP:DrawWeaponSelection()
end

function SWEP:GetPassiveHoldType()
	if self.HoldType == "revolver" or self.HoldType == "pistol" then
		return "normal"
	end

	return "passive"
end

function SWEP:SetHTPassive()
	self:SetHoldType(self:GetPassiveHoldType())
end

function SWEP:GetDeploySound()
	local isPistol = self.HoldType == "revolver" or self.HoldType == "pistol"

	return "LS_Generic.Draw" .. (isPistol and "Pistol" or "")
end

function SWEP:GetHolsterSound()
	local isPistol = self.HoldType == "revolver" or self.HoldType == "pistol"

	return "LS_Generic.Holster" .. (isPistol and "Pistol" or "")
end


function SWEP:Deploy()
	if self.CustomMaterial then
		if CLIENT then
			self.Owner:GetViewModel():SetMaterial(self.CustomMaterial)
			self.CustomMatSetup = true
		end
	end

	local vm = self:GetOwner():GetViewModel()

	if self.CustomSubMats then
		for id, mat in pairs(self.CustomSubMats) do
			vm:SetSubMaterial(id, mat)
		end
	else
		for id, mat in pairs(vm:GetMaterials()) do
			vm:SetSubMaterial(id, "")
		end
	end

	if self.ExtraDeploy then
		self:ExtraDeploy()
	end

	self:EmitWeaponSound(self:GetDeploySound())

	local seq = vm:SelectWeightedSequence(self.DrawAnim or ACT_VM_DRAW)
	local dur = vm:SequenceDuration(dur)

	if dur != 0 and dur and not self.NoDrawAnim then
		self:SetNextPrimaryFire(CurTime() + self:PlayAnim(self.DrawAnim or ACT_VM_DRAW))
		self:QueueIdle()

	end

	if self.PlayerSpeedMultiplier then
		local ply = self:GetOwner()
		local oldSpeed = ply:GetWalkSpeed()
		ply.lsOldWalkSpeed = oldSpeed
		ply:SetWalkSpeed(oldSpeed * self.PlayerSpeedMultiplier)
	end

	self:SetLowered(false)
	self:SetHoldType(self.HoldType)

	return true
end

function SWEP:Holster(w)
	local vm = self:GetOwner():GetViewModel()

	self:ResetValues()

	if CLIENT then
		self.ViewModelPos = Vector( 0, 0, 0 )
		self.ViewModelAng = Angle( 0, 0, 0 )
		self.FOV = nil
	end

	if self.CustomMaterial then
		if CLIENT then
			if self.Owner == LocalPlayer() then
				self.Owner:GetViewModel():SetMaterial("")
			end
		end
	end

	if self.CustomSubMats then
		for id, mat in pairs(self.CustomSubMats) do
			vm:SetSubMaterial(id, "")
		end
	end

	if self.PlayerSpeedMultiplier then
		local oldSpeed = self:GetOwner().lsOldWalkSpeed
		if oldSpeed != self:GetOwner():GetWalkSpeed() then
			self:GetOwner():SetWalkSpeed(oldSpeed)
		end
	end

	if self.ExtraHolster then
		self:ExtraHolster()
	end
	
	return true
end

print("[longsword] Longsword weapon base loaded. Version " .. longsword.version .. ". Copyright 2019 vin")