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
	self._CustomRecoil = self._CustomRecoil or {}
	self._CustomRecoil.Value = 1
	self._CustomRecoil.PitchValue = 1
	self._CustomRecoil.RollValue = 1
	self._CustomRecoil.RollRandom = math.Rand(4, 12)
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

function SWEP:ShootEffects()
	local ply = self:GetOwner()

	if not self:GetIronsights() or self:ShouldAnimateFire() then
		local anim = self:GetFireAnimation()
		self:PlayAnim(anim)
		self:QueueIdle()
	end

	self:PlayFireSound()

	if CLIENT then
		if self:ShouldResetCustomRecoil() and (game.SinglePlayer() or IsFirstTimePredicted()) then
			self:ResetCustomRecoil()
		end

		local isThirdperson = ply:ShouldDrawLocalPlayer()

		if not isThirdperson then
			local vm = self:GetOwner():GetViewModel()
			local attachment = vm:LookupAttachment(self.MuzzleAttachment or "muzzle")
			local posang = vm:GetAttachment(attachment)

			if posang then
				local ef = EffectData()
				ef:SetOrigin(self:GetOwner():GetShootPos())
				ef:SetStart(self:GetOwner():GetShootPos())
				ef:SetNormal(self:GetOwner():EyeAngles():Forward())
				ef:SetEntity(self:GetOwner():GetViewModel())
				ef:SetAttachment(attachment)
				ef:SetScale(self.IronsightsMuzzleFlashScale or 1)

				util.Effect(self.IronsightsMuzzleFlash or "ls_muzzleflash", ef)
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
end
