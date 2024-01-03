function SWEP:ViewPunch()
	if SERVER or (not game.SinglePlayer() and not IsFirstTimePredicted()) then return end
	local punch = Angle()
	local i = 3 * self.Primary.Recoil

	local offset = Angle(math.random(0, -i * 0.9), math.random(-i * 0.25, i * 0.25))

	self:GetOwner():ViewPunch(offset)
	if IsFirstTimePredicted() and ( CLIENT or game.SinglePlayer() ) then
		self:GetOwner():SetEyeAngles( self:GetOwner():EyeAngles() + offset * 0.2)
	end
end

function SWEP:ShouldResetCustomRecoil()
	if self.UseIronsightsRecoil == false then
		return false
	end

	if self.Recoil then
		if (self.Recoil.IronsightsOnly == true or self.Recoil.IronsightsOnly == nil) and not self:GetIronsights() then
			return false
		end

		if self.Recoil.Enabled == false then
			return false
		end
	elseif not self.Recoil and not self:GetIronsights() then
		return false
	end

	return true
end

function SWEP:ResetCustomRecoil()
	self.RecoilTarget = 1
	self.RecoilSpeed = 64
	self.RecoilRollRandom = math.Rand(-1, 1)
end

function SWEP:ShouldAnimateFire()
	if self.Recoil then
		if self.Recoil.DoFireAnim then
			return true
		end
	end

	if self.UseIronsightsRecoil then
		return false
	end

	return true
end

function SWEP:GetFireAnimation()
	if self:GetIronsights() then
		return self.IronsightsAnimation or ACT_VM_PRIMARYATTACK_1
	end

	if self:Clip1() == 0 and self.DoLastFireAnim then
		return self.LastFireAnim or ACT_VM_PRIMARYATTACK_EMPTY
	end

	if self.FireAnims then
		return self.FireAnims[math.random(1, #self.FireAnims)]
	end

	return self.FireAnim or ACT_VM_PRIMARYATTACK
end

local smoke = Material("sprites/smoke")
local trail
function SWEP:ShootEffects()
	local ply = self:GetOwner()
	local vm = ply:GetViewModel()
	if not self:GetIronsights() or self:ShouldAnimateFire() then
		local anim = self:GetFireAnimation()
		self:PlayAnim(anim)
		self:QueueIdle()
	end

	self:PlayFireSound()
	local muz = vm:LookupAttachment(self.MuzzleAttachment or "muzzle")

	if CLIENT then
		self.BlurFraction = 1
		if self:ShouldResetCustomRecoil() and (game.SinglePlayer() or IsFirstTimePredicted()) then
			self:ResetCustomRecoil()
		end

		self.RecoilCameraRoll = 1
		self.RecoilCameraFreq = math.random(15, 23)
		self.RecoilCameraLastShoot = CurTime()

		local isThirdperson = ply:ShouldDrawLocalPlayer()

		if not isThirdperson then
			local posang = vm:GetAttachment(muz)

			if posang then
				local ef = EffectData()
				ef:SetOrigin(self:GetOwner():GetShootPos())
				ef:SetStart(self:GetOwner():GetShootPos())
				ef:SetNormal(self:GetOwner():EyeAngles():Forward())
				ef:SetEntity(self:GetOwner():GetViewModel())
				ef:SetAttachment(muz)
				ef:SetScale(self.IronsightsMuzzleFlashScale or 1)

				util.Effect(self.IronsightsMuzzleFlash or "ls_muzzleflash", ef)
			end
		end

		if (self.Primary.BulletModel or self.Primary.BulletEffect) and self.Primary.EjectAttachment then
			if self.Primary.BulletEjectDelay then
				timer.Simple(self.Primary.BulletEjectDelay, function()
					if not IsValid(self) then return end
					self:DoBulletEjection()
				end)
			else
				self:DoBulletEjection()
			end
		end
	end

	self:GetOwner():MuzzleFlash()
	self:PlayAnimWorld(ACT_VM_PRIMARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	self:QueueIdle()
	if self.CustomShootEffects then
		self:CustomShootEffects()
	end

	if self.PumpDelay then
		timer.Simple(self.PumpDelay, function()
			local anim = self.PumpAnimation or ACT_VM_PULLBACK
			if self.GetPumpAnimation then
				anim = self:GetPumpAnimation()
			end

			self:PlayAnim(anim)
			self:QueueIdle()
		end)
	end
end

function SWEP:DoBulletEjection()
	if (self.NextBulletEject or 0) > CurTime() then return end
	self.NextBulletEject = CurTime() + (self.Primary.Delay or 0)
	local ply = self:GetOwner()
	local vm = ply:GetViewModel()
	if not IsValid(vm) then return end

	local att = self.Primary.EjectAttachment
	local attID = vm:LookupAttachment(att)
	local data = vm:GetAttachment(attID)
	if not data then 
		return longsword.debugPrint(self:GetClass() .. ".Primary.EjectAttachment is invalid!")
	end

	if self.Primary.BulletModel then
		local cs = ClientsideModel(self.Primary.BulletModel)
		cs:SetPos(data.Pos)
		cs:SetAngles(data.Ang)
		cs:Spawn()

		local phy = cs:GetPhysicsObject()
		if IsValid(phy) then
			local dir = self.Primary.BulletDirection or "right"
			local vel
			if dir == "right" then
				vel = vm:GetRight()
			elseif dir == "left" then
				vel = -vm:GetRight()
			elseif dir == "up" then
				vel = vm:GetUp()
			elseif dir == "down" then -- what kind of fucking gun
				vel = -vm:GetUp()
			else
				longsword.debugPrint(self:GetClass() .. ".Primary.BulletDirection is invalid! Defaulting to \"right\".")
				vel = vm:GetRight()
			end

			vel = vel * (self.Primary.BulletEjectForce or 10)
	
			phy:SetVelocity(vel)
		end

		timer.Simple(3, function()
			if not IsValid(cs) then return end

			cs:Remove()
		end)
	elseif self.Primary.BulletEffect then
		local ef = EffectData()
		ef:SetEntity(vm)
		ef:SetAttachment(attID)
		ef:SetOrigin(data.Pos)
		ef:SetAngles(data.Ang)
		ef:SetScale(self.Primary.BulletScale or 1)
		util.Effect(self.Primary.BulletEffect, ef)
	else
		return longsword.debugPrint("DoBulletEjection called on weapon with no bullet properties!")
	end
end