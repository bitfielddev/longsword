function SWEP:IsSprinting()
	return ( self.Owner:GetVelocity():Length2D() > self.Owner:GetRunSpeed() - 50 )
		and self.Owner:IsOnGround()
end

function SWEP:CanShoot()
	return not self:GetBursting() and not (self.LoweredPos and self:IsSprinting()) and self:GetReloadTime() < CurTime() and not self:GetLowered()
end

function SWEP:CanIronsight()
	if self.NoIronsights then
		return false
	end
	
	local att = self:GetCurAttachment()
	if att != "" and self.Attachments[att] and self.Attachments[att].Behaviour == "sniperscope" and hook.Run("ShouldDrawLocalPlayer", self.Owner) then
		return false
	end

	return not self:IsSprinting() and not self:GetReloading() and self.Owner:IsOnGround() and not self:GetLowered()
end

function SWEP:CanReload()
	return self:Ammo1() > 0 and self:Clip1() < self.Primary.ClipSize
		and not self:GetReloading() and self:GetNextPrimaryFire() < CurTime() and (self.NextFMToggle or 0) < CurTime()
end

