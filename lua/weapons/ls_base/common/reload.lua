function SWEP:Inspect()
	if not self.InspectAnimation or not self.InspectAnimations then return end

	local anim = self.InspectAnimation or "inspect"
	if self.InspectAnimations then
		anim = self.InspectAnimations[math.random(1, #self.InspectAnimations)]
	end

	local dur = self:PlayAnim(anim)
	self:SetNextPrimaryFire(CurTime() + dur)
	self:QueueIdle()
end

function SWEP:Reload()
	self.HammerDown = false
	if self:Clip1() >= self:GetMaxClip1() then
		return self:Inspect()
	end

	if not self:CanReload() then return end

	-- self:EmitWeaponSound("LS_Generic.Reload")

	if self.Shotgun then
		return self:ReloadShotgun()
	end

	self:GetOwner():DoReloadEvent()

	if not self.DoEmptyReloadAnim or self:Clip1() != 0 then
		self:PlayAnim(self.ReloadAnimation or ACT_VM_RELOAD)
	else
		self:PlayAnim(ACT_VM_RELOAD_EMPTY)
	end
	self:QueueIdle()

	if self.ReloadSound then 
		self:EmitSound(self.ReloadSound) 
	elseif self.OnReload then
		self.OnReload(self)
	end

	self:SetReloading( true )
	self:SetReloadTime( CurTime() + self:GetOwner():GetViewModel():SequenceDuration() )

	hook.Run("LongswordWeaponReload", self:GetOwner(), self)
end

function SWEP:FinishReload()
	self:SetReloading( false )

	local amount = math.min( self:GetMaxClip1() - self:Clip1(), self:Ammo1() )

	self:SetClip1( self:Clip1() + amount )
	self:GetOwner():RemoveAmmo( amount, self:GetPrimaryAmmoType() )
end
