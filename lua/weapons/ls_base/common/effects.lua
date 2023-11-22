function SWEP:ViewPunch()
	if SERVER or (not game.SinglePlayer() and not IsFirstTimePredicted()) then return end
	local punch = Angle()
	local i = 3 * (self.Primary.Recoil)

	local offset = Angle(math.random(0, -i * 0.9), math.random(-i * 0.25, i * 0.25))

	self:GetOwner():ViewPunch(offset)
	if IsFirstTimePredicted() and ( CLIENT or game.SinglePlayer() ) then
		self.Owner:SetEyeAngles( self.Owner:EyeAngles() + offset * 0.2)
	end
end

function SWEP:ShouldResetCustomRecoil()
	if self.UseIronsightsRecoil == false then
		return false
	end

	if self.Recoil then
		if self.Recoil.IronsightsOnly and not self:GetIronsights() then
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
	self._CustomRecoil.RollRandom = math.Rand(12, 24)
end

function SWEP:ShootEffects()
	if not self:GetIronsights() or not self.UseIronsightsRecoil then
		self:PlayAnim(self:GetIronsights() and (self.IronsightsAnimation or ACT_VM_PRIMARYATTACK_1) or (self.FireAnim or ACT_VM_PRIMARYATTACK))
		self:QueueIdle()
	else
		self:SetIronsightsRecoil( math.Clamp( 7.5 * (self.IronsightsRecoilVisualMultiplier or 1) * self.Primary.Recoil, 0, 20 ) )
	end

	if CLIENT then
		if self:ShouldResetCustomRecoil() and (game.SinglePlayer() or IsFirstTimePredicted()) then
			self:ResetCustomRecoil()
		end

		local isThirdperson = hook.Run("ShouldDrawLocalPlayer", self.Owner)

		if not isThirdperson then
			local vm = self.Owner:GetViewModel()
			local attachment = vm:LookupAttachment(self.MuzzleAttachment or "muzzle")
			local posang = vm:GetAttachment(attachment)

			if posang then
				local ef = EffectData()
				ef:SetOrigin(self.Owner:GetShootPos())
				ef:SetStart(self.Owner:GetShootPos())
				ef:SetNormal(self.Owner:EyeAngles():Forward())
				ef:SetEntity(self.Owner:GetViewModel())
				ef:SetAttachment(attachment)
				ef:SetScale(self.IronsightsMuzzleFlashScale or 1)

				util.Effect(self.IronsightsMuzzleFlash or "ls_muzzleflash", ef)
			end
		end
	else
		for _, ply in pairs(player.GetAll()) do
			if (ply:GetPos() - self:GetOwner():GetPos()):LengthSqr() < (20000 ^ 2) then
				net.Start("longswordEcho")
				net.WriteUInt(ply:EntIndex(), 32)
				net.Send(ply)
			end
		end
	end

	self.Owner:MuzzleFlash()
	self:PlayAnimWorld(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self:QueueIdle()
	if self.CustomShootEffects then
		self:CustomShootEffects()
	end
end
