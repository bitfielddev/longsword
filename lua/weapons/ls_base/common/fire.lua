function SWEP:ShootBullet(damage, num_bullets, aimcone)
	local bullet = {}

	bullet.Num 	= num_bullets
	bullet.Src 	= self:GetOwner():GetShootPos() -- Source
	bullet.Dir 	= self:GetOwner():GetAimVector() -- Dir of bullet
	bullet.Spread 	= Vector(aimcone, aimcone, 0)	-- Aim Cone

	if self.Primary.Tracer then
		bullet.TracerName = self.Primary.Tracer
	end

	if self.Primary.Range then
		bullet.Distance = self.Primary.Range
	end

	bullet.Tracer	= 1 -- Show a tracer on every x bullets
	bullet.Force	= self.Primary.Force or 1 -- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = ""

	if CLIENT then
		bullet.Callback = function(attacker, tr)
			debugoverlay.Cross(tr.HitPos, 2, 3, Color(255, 0, 0), true)
		end
	end

	self:GetOwner():FireBullets(bullet)

	self:ShootEffects()
end

function SWEP:AddRecoil()
	self:SetRecoil( math.Clamp( self:GetRecoil() + self.Primary.Recoil * 0.4, 0, self.Primary.MaxRecoil or 1 ) )
end

function SWEP:CalculateSpread()
	local spread = self.Primary.Cone
	local maxSpeed = self.LoweredPos and self:GetOwner():GetWalkSpeed() or self:GetOwner():GetRunSpeed()

	spread = spread + self.Primary.Cone * math.Clamp( self:GetOwner():GetVelocity():Length2D() / maxSpeed, 0, self.Spread.VelocityMod )
	spread = spread + self:GetRecoil() * self.Spread.RecoilMod

	if not self:GetOwner():IsOnGround() then
		spread = spread * self.Spread.AirMod
	end

	if self:GetOwner():IsOnGround() and self:GetOwner():Crouching() then
		spread = spread * self.Spread.CrouchMod
	end

	if self:GetIronsights() then
		spread = spread * (self.Spread.IronsightsMod or 1)
	end

	spread = math.Clamp( spread, self.Spread.Min, self.Spread.Max )

	if CLIENT then
		self.LastSpread = spread
	end

	return spread
end

function SWEP:PrimaryAttack()
	if not self:CanShoot() then return end

	local clip = self:Clip1()

	if self.Primary.Burst and clip >= 3 then
		self:SetBursting(true)
		self.Burst = 3

		local delay = CurTime() + ((self.Primary.Delay * 3) + (self.Primary.BurstEndDelay or 0.3))
		self:SetNextPrimaryFire(delay)
		self:SetReloadTime(delay)
	elseif clip >= 1 then
		self:Shoot()
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	else
		if not self.NoDryFireAnim then
			if self.HammerDown == true then return end
			self:PlayAnim(ACT_VM_DRYFIRE)
			self:QueueIdle()
			self.HammerDown = true
		end

		self:SetNextPrimaryFire(CurTime() + 1)
	end
end

function SWEP:Shoot()
	self:TakePrimaryAmmo(1)

	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self:CalculateSpread())

	self:AddRecoil()
	self:ViewPunch()
	
	self:SetReloadTime(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack() 
end
