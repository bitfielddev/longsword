function SWEP:Think()
	self:TriggerThink()
	self:IronsightsThink()
	self:RecoilThink()
	self:IdleThink()
	self:LoweredThink()
	self:FiremodeThink()
	if self:GetBursting() then self:BurstThink() end
	if self:GetReloading() then self:ReloadThink() end

	if self.CustomThink then
		self:CustomThink()
	end

	if CLIENT then
		self:SwayThink()
	end

	if not CLIENT then
		return
	end

	local attach = self:GetCurAttachment()
	self.KnownAttachment = self.KnownAttachment or ""
	
	if self.KnownAttachment != attach and attach != "" then
		self.KnownAttachment = attach
		self:SetupModifiers(attach)
	elseif self.KnownAttachment != attach then
		self:RollbackModifiers(self.KnownAttachment)
		self.KnownAttachment = attach
	end
end

function SWEP:IdleThink()
	if self:GetNextIdle() == 0 then return end

	if CurTime() > self:GetNextIdle() then
		self:SetNextIdle( 0 )
		self:PlayAnim( self.IdleAnim or ACT_VM_IDLE )
	end
end

function SWEP:RecoilThink()
	self:SetRecoil( math.Clamp( self:GetRecoil() - FrameTime() * (self.Primary.RecoilRecoveryRate or 1.4), 0, self.Primary.MaxRecoil or 1 ) )
end

function SWEP:BurstThink()
	if self.Burst and (self.nextBurst or 0) < CurTime() then
		self:Shoot()

		self.Burst = self.Burst - 1

		if self.Burst < 1 then
			self:SetBursting(false)
			self.Burst = nil
		else
			self.nextBurst = CurTime() + self.Primary.Delay
		end	
	end
end

function SWEP:OnRemove()
	if self.CustomMaterial then
		if CLIENT then
			if not self.Owner.GetViewModel then -- disconnect errors
				return
			end

			if not self.Owner == LocalPlayer() then
				return
			end

			if not IsValid(self.Owner) then
				return
			end

			if not IsValid(self.Owner:GetViewModel()) then
				return
			end

			self.Owner:GetViewModel():SetMaterial("")
		end
	end
end

function SWEP:ReloadThink()
	if self.Shotgun == true then
		self:ShotgunReloadThink()
	end
	if self:GetReloadTime() < CurTime() then 
		self:FinishReload()
	end
end

function SWEP:IronsightsThink()
	self._CustomRecoil = self._CustomRecoil or {}

	if CLIENT then
		self._CustomRecoil.Value = Lerp(RealFrameTime() * 4, self._CustomRecoil.Value or 0, 0)
		self._CustomRecoil.PitchValue = Lerp(RealFrameTime() * 8, self._CustomRecoil.PitchValue or 0, 0)
		self._CustomRecoil.RollValue = Lerp(RealFrameTime() * 2, self._CustomRecoil.RollValue or 0, 0)
		self._CustomRecoil.YawValue = Lerp(RealFrameTime() * 4, self._CustomRecoil.YawValue or 0, math.Rand(-1, 1))

	end
	if self.Owner:KeyDown(IN_ATTACK2) and self:CanIronsight() and not self:GetIronsights() then
		self:SetIronsights( true )
		if CLIENT then
			self:EmitWeaponSound("LS_Generic.ADSIn")
		end
	elseif (not self.Owner:KeyDown(IN_ATTACK2) or not self:CanIronsight()) and self:GetIronsights() then
		self:SetIronsights( false )
		if CLIENT then
			self:EmitWeaponSound("LS_Generic.ADSOut")
		end
	end
end

function SWEP:LoweredThink()
	if impulse then
		if self:GetLowered() then
			self:SetLowered(false)
		end

		return
	end

	self.RaiseTime = self.RaiseTime or 0
	if self.Owner:KeyDown(IN_RELOAD) then
		if self.RaiseTime != 0 and self.RaiseTime < CurTime() then
			self.RaiseTime = 0
			self:EmitWeaponSound("LS_Generic.Lower")
			self:SetLowered(not self:GetLowered())
			local lowered = self:GetLowered()
		
			if lowered then
				self:SetHTPassive()
			else
				self:SetHoldType(self.HoldType)
			end
		elseif self.RaiseTime == 0 then
			self.RaiseTime = CurTime() + (longsword.raiseTime or 1)
		end
	elseif not self.Owner:KeyDown(IN_RELOAD) and (self.RaiseTime or 0) != 0 then
		self.RaiseTime = 0
	end
end

function SWEP:FiremodeThink()
	local ply = self:GetOwner()

	if ply:KeyDown(IN_USE) and ply:KeyDown(IN_RELOAD) and self.FireModes then
		return self:ToggleFireMode()
	end
end

function SWEP:GetTriggerDelay()
	return self.TriggerDelay or 0.05
end

function SWEP:GetTriggerDownSound()
	return self.TriggerDownSound or self.EmptySound or ""
end

function SWEP:GetTriggerUpSound()
	return self.TriggerUpSound or self.EmptySound or ""
end

function SWEP:TriggerThink()
	if self:GetReloading() or self:IsSprinting() and self.LoweredPos then return end

	local ply = self:GetOwner()
	local held = ply:KeyDown(IN_ATTACK)
	local delay = self:GetTriggerDelay()
	local down = self:GetTriggerDown()

	if held and not down then
		self:SetTriggerDown(true)
		self:SetTriggerCanFire(true)
		local sndDown = self:GetTriggerDownSound()

		if sndDown then
			self:EmitSound(sndDown, nil, nil, 0.1)
		end

		self.TriggerFire = CurTime() + delay
	elseif not held and down then
		self:SetTriggerDown(false)
		self:SetTriggerCanFire(false)

		local sndUp = self:GetTriggerUpSound()
		if sndUp then
			self:EmitSound(sndUp, nil, 80)
		end

		self.TriggerFire = nil
	end
	
	--print(self.TriggerFire, CurTime())
	if self.TriggerFire and self.TriggerFire <= CurTime() and self:GetTriggerCanFire() and self:GetNextPrimaryFire() <= CurTime() then
		self:PrimaryAttack()
		if not self.Primary.Automatic then
			self:SetTriggerCanFire(false)
		end
	end
end