function SWEP:Think()
	self:IronsightsThink()
	self:RecoilThink()
	self:IdleThink()
	self:LoweredThink()
	self:FiremodeThink()
	self:SoundThink()
	if self:GetBursting() then self:BurstThink() end
	if self:GetReloading() then self:ReloadThink() end

	if self.CustomThink then
		self:CustomThink()
	end

	if self.DoSprintHoldType then 
		self:SetHoldType( ( self:IsSprinting() and self:GetPassiveHoldType() ) or self.HoldType )
	end
	
	if CLIENT then
		self:SwayThink()
	end

	if not CLIENT then
		return
	end

	self.LastCurTime = CurTime()


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
		if self.NoIdleAnim then
			return
		end
		
	        if self.EmptyIdleAnim and self:Clip1() == 0 then
	            	self:PlayAnim( self.EmptyIdleAnim )
	        else
			self:PlayAnim( self.IdleAnim or ACT_VM_IDLE )
	        end
		
	end
end

function SWEP:RecoilThink()
	self:SetRecoil( math.Clamp( self:GetRecoil() - FrameTime() * (self.Primary.RecoilRecoveryRate or 1.4), 0, self.Primary.MaxRecoil or 1 ) )

	if CLIENT then
		if (self.RecoilCameraLastShoot or 0) + 0.1 < CurTime() then
			self.RecoilCameraRoll = Lerp(RealFrameTime() * 2, self.RecoilCameraRoll or 0, 0)
		end
	end
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


	if self.Owner:KeyDown(IN_ATTACK2) and self:CanIronsight() and not self:GetIronsights() then
		if hook.Run("LSOnIronsights", self, true) then return end
		self:SetIronsights( true )
		if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then
			if self.IronsightsFrac < 0.01 then
				self.IronsightsEarly = true
			else
				self.IronsightsEarly = false
			end
			self:EmitWeaponSound(longsword.ironInSound or "LS_Generic.ADSIn")
		end
	elseif (not self.Owner:KeyDown(IN_ATTACK2) or not self:CanIronsight()) and self:GetIronsights() then
		if hook.Run("LSOnIronsights", self, false) then return end
		self:SetIronsights( false )

		if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then
			if self.IronsightsFrac < 0.93 then
				self.IronsightsEarly = true
			else
				self.IronsightsEarly = false
			end
	
			self:EmitWeaponSound(longsword.ironOutSound or "LS_Generic.ADSOut")
		end
	end
end

function SWEP:SoundThink()
	if not self.Primary.LoopSound then return end

	local cs = self:CanShoot()
	local ply = self:GetOwner()
	local kd = ply:KeyDown(IN_ATTACK)
	if kd and cs then
		if not self.LoopSnd then
			self.LoopSnd = CreateSound(self, self.Primary.LoopSound)
		end

		if not self.LoopSnd:IsPlaying() then
			self.LoopSnd:Play()
		end
	elseif (not kd or not cs) and self.LoopSnd and self.LoopSnd:IsPlaying() then
		self.LoopSnd:Stop()
	end
end

function SWEP:LoweredThink()
	if impulse or ix then
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
