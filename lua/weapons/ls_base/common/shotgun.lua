function SWEP:ReloadShotgun()
	if self.CanChamberShotgun and self:Clip1() == 0 then
		self:PlayAnim( ACT_VM_RELOAD_EMPTY )
		self:SetClip1( self:Clip1() + 1 )
		self:GetOwner():RemoveAmmo( 1, self:GetPrimaryAmmoType() )
	else
		self:PlayAnim( ACT_SHOTGUN_RELOAD_START )
	end

	self:GetOwner():DoReloadEvent()
	self:QueueIdle()

	self:SetReloading( true )
	self:SetReloadTime( CurTime() + self:GetOwner():GetViewModel():SequenceDuration() )

	if self.ReloadSound then
		self:EmitSound(self.ReloadSound)
	end

	hook.Run("LongswordWeaponReload", self:GetOwner(), self)
end

function SWEP:InsertShell()
	self:SetClip1( self:Clip1() + 1 )
	self:GetOwner():RemoveAmmo( 1, self:GetPrimaryAmmoType() )

	self:PlayAnim(ACT_VM_RELOAD)
	self:QueueIdle()

	self:SetReloadTime(CurTime() + (self.ShellInsertDelay or self:GetOwner():GetViewModel():SequenceDuration()))

	if self.ReloadShellSound then
		self:EmitSound(self.ReloadShellSound)
	end
end

function SWEP:ShotgunReloadThink()
	if self:GetReloadTime() > CurTime() then return end

	local cs = self.Primary.ClipSize

	if self.CanChamberShotgun then
		cs = cs + 1
	end

	if self:Clip1() < cs and self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) > 0
		and not self:GetOwner():KeyDown( IN_ATTACK ) then
		self:InsertShell()
	else
		self:FinishShotgunReload()
	end
end

function SWEP:FinishShotgunReload()
	self:SetReloading( false )

	self:PlayAnim( ACT_SHOTGUN_RELOAD_FINISH )
	self:SetReloadTime( CurTime() + self:GetOwner():GetViewModel():SequenceDuration() )
	self:QueueIdle()

	if self.PumpSound then self:EmitSound( self.PumpSound ) end
end
