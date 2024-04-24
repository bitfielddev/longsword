local CurTime = UnPredictedCurTime -- fix VM lag

function SWEP:PreDrawViewModel(vm)
	if CLIENT and self.CustomMaterial and not self.CustomMatSetup then
		self:GetOwner():GetViewModel():SetMaterial(self.CustomMaterial)
		self.CustomMatSetup = true
	end

	self:OffsetThink()

	return self:ScopedIn()
end

function SWEP:GetOffset()
	local pos, ang = Vector(), Angle()

	local centered = self:Centered()
	if centered and not self:GetIronsights() and (not self:IsSprinting() or not self.LoweredPos) then
		local cpos, cang = self:GetCenterPos()
		pos:Add(cpos)
		ang:Add(cang)
	end

	if ( self.LoweredPos and self:IsSprinting() ) or self:GetLowered() then
		pos:Add(self.LoweredPos or Vector(3.5, -2, -2))
		ang:Add(self.LoweredAng or Angle(-16, 32, -16))
	end

	return pos, ang
end

SWEP.ViewModelPos = Vector( 0, 0, 0 )
SWEP.ViewModelAngle = Angle( 0, 0, 0 )

function SWEP:OffsetThink()
	local offset_pos, offset_ang = self:GetOffset()

	if not offset_pos then offset_pos = vector_origin end
	if not offset_ang then offset_ang = angle_zero end

	if self.ViewModelOffset and not self:GetIronsights() then
		offset_pos = offset_pos + self.ViewModelOffset
	end

	if self.ViewModelOffsetAng and not self:GetIronsights() then
		offset_ang = offset_ang + self.ViewModelOffsetAng
	end

	self.ViewModelPos = LerpVector(RealFrameTime() * 7, self.ViewModelPos, offset_pos)
	self.ViewModelAngle = LerpAngle(RealFrameTime() * 7, self.ViewModelAngle, offset_ang)
end

local math, sin, cos, approach, abs = math, math.sin, math.cos, math.Approach, math.abs

function SWEP:CalcViewBob(eyePos, eyeAng)
	local pos, ang
	local ct = CurTime()
	local ft = math.Clamp(RealFrameTime(), 0, 1)
	local ft8 = ft * 8

	local ply = self:GetOwner()
	
	local ovel = ply:GetVelocity()
	local move = Vector(ovel.x, ovel.y, 0)
	local movement = move:LengthSqr()
	local mvRaw = math.Clamp(movement / ply:GetRunSpeed() ^ 2, 0, 1)

	local mv = Lerp(ft * 3.2, self.VMLastMV or mvRaw, mvRaw)
	self.VMLastMV = mv

	local vel = move:GetNormalized()

	if self:GetIronsights() then
		mv = mv * (self.IronsightsBobMultiplier or 0.1)
	end

	eyePos, eyeAng = self:ViewBob(eyePos, eyeAng, mv, ct, ft)

	local rd = move:Dot(self:GetOwner():GetRight()) * 0.05 * (self:GetIronsights() and 0.4 or 1)
	local rdSmooth = Lerp(ft * 4, self.VMRoll or rd, rd)
	self.VMRoll = rdSmooth
	eyeAng.r = eyeAng.r + rdSmooth
	

	return eyePos, eyeAng
end

function SWEP:ViewBob(eyePos, eyeAng, mv, ct, ft)
	local spr = self:IsSprinting()

	if spr then
		ct = ct * 1.5
	else
		ct = ct * 1.05
		mv = mv * 2.5
	end
	
	local muz = self.MuzzleData or {}

	local muzPos = muz.Pos or Vector()
	local muzAng = muz.Ang or Angle()

	-- First
	local v0 = cos(ct * 7.5) * 1.2 * mv
	local v1 = sin(ct * 16.5) * 0.5 * mv

	eyePos, eyeAng = longsword.math.rotateAround(
		eyePos,
		eyeAng,
		muzPos,
		Angle(
			(mv * 1.5) - v1,
			v0,
			0
		)
	)
	v0 = sin(ct * 7.5) * 3.5 * mv
	local r = sin(ct * 8) * 1.6 * mv

	-- Finalize
	eyePos, eyeAng = longsword.math.translate(
		eyePos,
		eyeAng,
		Vector(
			v0 * 0.25,
			0,
			0
		),
		Angle(
			0,
			v0,
			r
		)
	)

	return eyePos, eyeAng
end

function SWEP:ViewIdleOffset(eyePos, eyeAng)
	if self.NoIdle then return eyePos, eyeAng end
	local ct = CurTime()

	local amp = self:GetIronsights() and 0.03 or 1

	local p0 = sin(ct * 1.2) * 0.55

	local pos = Vector(p0 * 0.3, 0, 0) * amp
	local ang = Angle(p0, 0, 0) * amp

	return longsword.math.translate(eyePos, eyeAng, pos, ang)
end

function SWEP:SwayThink()
	local ft = FrameTime()

	local ply = self:GetOwner()
	local eyeAng = ply:EyeAngles()

	local lastAng = self.VMSwayLastAng or eyeAng
	local dist = eyeAng - lastAng

	local swayCV = GetConVar("longsword_invertsway")
	local leftCV = GetConVar("longsword_lefthand")

	local invertSway = self.SwayDrag
	if swayCV and swayCV:GetBool() or (leftCV and leftCV:GetBool()) then
		invertSway = true
	end


	if invertSway then
		dist.p = -dist.p
		dist.y = -dist.y
		dist.r = -dist.r
		dist = dist * 0.7
	end

	dist = dist * 5.5
	dist = dist * (self.SwayMul or 1)

	dist.p = -math.Clamp(dist.p, -5, 5)
    dist.y = math.Clamp(dist.y, -5, 5)
    dist.r = math.Clamp(dist.r, -5, 5)

	
    self.VMSwayAng = LerpAngle(ft * 32, self.VMSwayAng or dist, dist)
    self.VMSwayLastAng = eyeAng
	self.VMSwayBeforeAng = lastAng
end

function SWEP:ViewSwayOffset(eyePos, eyeAng)
	local ft = RealFrameTime()
    local swayRaw = self.VMSwayAng or Angle()
	local sway = 1.4 * (self:GetIronsights() and 0.2 or 1)

    swayRaw.r = -(swayRaw.y * 0.4) * 1.5 * sway

    self.VMSwayAngSmooth = LerpAngle(ft * 2, self.VMSwayAngSmooth or swayRaw, swayRaw)
    local ang = self.VMSwayAngSmooth * 2

	local mul = (self.SwayPosMul or 1) + (self.SwayMul or 1)
    return longsword.math.translate(
        eyePos, 
        eyeAng, 
        Vector(ang.y * 0.1 * mul, 0, -ang.p * 0.1 * mul), 
        ang, 
        sway
    )
end

function SWEP:JumpOffset(eyePos, eyeAng)
	if not self.MuzzleData then
		return eyePos, eyeAng
	end
	local ft = RealFrameTime()
	local ply = self:GetOwner()

	local grounded = ply:IsOnGround()

	local curoffset = self.VMJump or 0
	
	local offset = Lerp(ft * (grounded and 4 or 0.4), curoffset, grounded and 0 or 1)


	local p = offset * 3.5


	self.VMJump = offset
	return longsword.math.rotateAround(
		eyePos,
		eyeAng,
		self.MuzzleData.Pos,
		Angle(
			p,
			0,
			0
		)
	)
end

function SWEP:ViewCrouchOffset(eyePos, eyeAng)
	local ft = RealFrameTime()

	local crouch = self:GetOwner():KeyDown(IN_DUCK) and not self:GetIronsights()

	local crouchPos, crouchAng = self.CrouchPos or Vector(-0.2, -0.5, 0), self.CrouchAng or Angle(0, 0, -8)

	local frac = Lerp(ft * 4, self.VMCrouchLerp or 0, crouch and 1 or 0)
	self.VMCrouchLerp = frac

	local pos, ang = longsword.math.lerpVec(Vector(), crouchPos, frac), longsword.math.lerpAng(Angle(), crouchAng, frac)

	return longsword.math.translate(eyePos, eyeAng, pos, ang)
end

function SWEP:Centered()
	local cv = GetConVar("longsword_centered")
	if cv and cv:GetBool() then
		return true
	end

	return false
end


function SWEP:GetCenterPos()
	local ft = RealFrameTime()

	local pos, ang

	if not self.CenteredPos then
		pos = Vector(
			-5,
			0,
			-2
		)
	else
		pos = self.CenteredPos
	end

	if not self.CenteredAng then
		ang = Angle()
	else
		ang = self.CenteredAng
	end

	return pos, ang
end

function SWEP:GetViewModelPosition( pos, ang )
	local cvFlip = GetConVar("longsword_lefthand")
	if cvFlip and cvFlip:GetBool() then
		self.ViewModelFlip = true
	else
		self.ViewModelFlip = weapons.Get(self:GetClass()).ViewModelFlip -- original value
	end

	local vm = self:GetOwner():GetViewModel()
	if IsFirstTimePredicted() or game.SinglePlayer() then
		local muz = self:LookupAttachment(self.MuzzleAttachment or "muzzle")
		if muz > 0 then
			att = vm:GetAttachment(muz)
		else
			att = {
				Pos = vm:LocalToWorld(Vector(20, -2, 0)),
				Ang = vm:GetAngles()
			}
		end
	
		att.Pos = vm:WorldToLocal(att.Pos)
		att.Ang = vm:WorldToLocalAngles(att.Ang)
	
		self.MuzzleData = att
	end


	ang:RotateAroundAxis( ang:Right(), self.ViewModelAngle.p )
	ang:RotateAroundAxis( ang:Up(), self.ViewModelAngle.y )
	ang:RotateAroundAxis( ang:Forward(), self.ViewModelAngle.r )

	pos = pos + self.ViewModelPos.x * ang:Right()
	pos = pos + self.ViewModelPos.y * ang:Forward()
	pos = pos + self.ViewModelPos.z * ang:Up()

	pos, ang = self:CustomRecoilOffset(pos, ang)
	pos, ang = self:CalcViewBob(pos, ang)
	pos, ang = self:ViewSwayOffset(pos, ang)
	pos, ang = self:ViewIdleOffset(pos, ang)
	pos, ang = self:ViewCrouchOffset(pos, ang)
	pos, ang = self:JumpOffset(pos, ang)

	local ironPos, ironAng = self:IronsightsOffset()

	pos = pos + ironPos.x * ang:Right()
	pos = pos + ironPos.y * ang:Forward()
	pos = pos + ironPos.z * ang:Up()

	ang:RotateAroundAxis(ang:Right(), ironAng.p)
	ang:RotateAroundAxis(ang:Forward(), ironAng.y)
	ang:RotateAroundAxis(ang:Up(), ironAng.r)

	local ply = self:GetOwner()
	self.LastVMPos = pos
	self.LastVMAng = ang

	return pos, ang
end

function SWEP:GetViewFOV()
	if self:ScopedIn() then
		return self.FOVScoped or 1
	end

	if self:GetIronsights() and self.IronsightsFOV then
		return self.IronsightsFOV
	end

	if (not self.NoSprintFOV) and self:IsSprinting() then
		return self.SprintFOV or 1.08
	end
	
	return 1
end

SWEP.FOVMultiplier = 1
SWEP.LastFOVUpdate = 0 -- gets called many times per frame... weird.
function SWEP:TranslateFOV(fov)
	if self.LastFOVUpdate < CurTime() then
		self.FOVMultiplier = Lerp(RealFrameTime() * 4, self.FOVMultiplier or 0, self:GetViewFOV() or 1)
		self.LastFOVUpdate = CurTime()
	end

	return fov * self.FOVMultiplier
end

function SWEP:CalcView(ply, origin, angles, fov)
	local ct = CurTime()

	local roll = self.RecoilCameraRoll or 0
	local cv = GetConVar("longsword_shootfov")
	if not cv or not cv:GetBool() then
		roll = 0
	end


	return origin, angles, fov + (roll * 2)
end


function SWEP:ViewModelDrawn()
	local vm = self:GetOwner():GetViewModel()
	if not IsValid(vm) then
		return
	end

	if self.CustomDrawVM then
		self:CustomDrawVM(vm)
	end

	if self.VMElements then
		for _, element in pairs(self.VMElements) do
			self:DrawVMElement(element)
		end
	end

	if not self.Attachments then return end

	self.EquippedAttachments = self.EquippedAttachments or {}
	for attID, equipped in pairs(self.EquippedAttachments) do
		if not equipped then continue end

		self:DrawVMAttachment(attID)
	end
end
