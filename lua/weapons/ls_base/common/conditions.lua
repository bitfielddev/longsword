function SWEP:IsSprinting()
	return ( self:GetOwner():GetVelocity():Length2D() > self:GetOwner():GetRunSpeed() - 50 )
		and self:GetOwner():IsOnGround()
end

function SWEP:CanShoot()
	if self.ExtraCanShoot and not self:ExtraCanShoot() then return false end

	return not self:GetBursting() and not (self.LoweredPos and self:IsSprinting()) and self:GetReloadTime() < CurTime() and not self:GetLowered()
end

function SWEP:CanIronsight()
	if self.NoIronsights then
		return false
	end

	return not self:IsSprinting() and not self:GetReloading() and self:GetOwner():IsOnGround() and not self:GetLowered()
end

function SWEP:CanReload()
	return self:Ammo1() > 0 and self:Clip1() < self.Primary.ClipSize
		and not self:GetReloading() and self:GetNextPrimaryFire() < CurTime() and (self.NextFMToggle or 0) < CurTime()
end

