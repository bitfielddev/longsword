function SWEP:PreDrawViewModel(vm)
	if CLIENT and self.CustomMaterial and not self.CustomMatSetup then
		self.Owner:GetViewModel():SetMaterial(self.CustomMaterial)
		self.CustomMatSetup = true
	end

	self:OffsetThink()

	return self:ScopedIn()
end

function SWEP:GetOffset()
	if self:GetReloading() then return end

	if ( self.LoweredPos and self:IsSprinting() ) or self:GetLowered() then
		return self.LoweredPos or Vector(3.5, -2, -2), self.LoweredAng or Angle(-16, 32, -16)
	end
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

local math, sin, cos, approach = math, math.sin, math.cos, math.Approach

function SWEP:ViewBob(eyePos, eyeAng)
	local pos, ang
	local ct = CurTime()
	local ft = math.Clamp(RealFrameTime(), 0, 1)
	local ft8 = ft * 8

	local spr = self:IsSprinting()

	local ovel = self.Owner:GetVelocity()
	local move = Vector(ovel.x, ovel.y, 0)
	local movement = move:LengthSqr()
	local mvRaw = math.Clamp(movement / self.Owner:GetRunSpeed() ^ 2, 0, 1)

	local mv = Lerp(ft8, self.VMLastMV or mvRaw, mvRaw)
	self.VMLastMV = mv

	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)

	if self:GetIronsights() then
		mv = mv * 0.2
	end
	
	if spr then
		pos, ang = self:SprintBobOffset(mv, ct, ft)
	else
		pos, ang = self:WalkBobOffset(mv, ct, ft)
	end

	local rd = move:Dot(self:GetOwner():GetRight()) * 0.05 * (self:GetIronsights() and 0.4 or 1)
	local rdSmooth = Lerp(ft * 4, self.VMRoll or rd, rd)
	self.VMRoll = rdSmooth
	ang.r = ang.r - rdSmooth
	
	eyePos, eyeAng = longsword.math.translate(eyePos, eyeAng, pos, ang)

	return eyePos, eyeAng
end

function SWEP:WalkBobOffset(mv, ct, ft)
	local p0 = (cos(ct * 8.4) * 1.2 * mv) + (cos(ct * 2.2) * 1.2 * mv)
	local p1 = (sin(ct * 16.8) * 0.2 * mv) + (sin(ct * 18) * 0.3 * mv)

	local pos = Vector(
		0,
		0,
		0
	)

	local ang = Angle(
		p1 * 2.5,
		p0 * 2.5,
		0
	)

	return pos, ang
end

function SWEP:SprintBobOffset(mv, ct, ft)
	ct = ct * 1.4
	local p0 = (cos(ct * 8.4) * 1.2 * mv) + (cos(ct * 2.2) * 1.2 * mv)
	local p1 = (sin(ct * 16.8) * 0.2 * mv) + (sin(ct * 18) * 0.3 * mv)

	local pos = Vector(
		0,
		0,
		0
	)

	local ang = Angle(
		p1 * 2.5,
		p0 * 2.5,
		0
	)


	return pos, ang
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

	dist.p = -math.Clamp(dist.p, -5, 5)
    dist.y = math.Clamp(dist.y, -5, 5)
    dist.r = math.Clamp(dist.r, -5, 5)

	if self.SwayMode == "drag" then
		dist.p = -dist.p * 0.55
		dist.y = -dist.y * 0.55
		dist.r = -dist.r * 0.55
	end
	dist = dist * 2
	dist = dist * (self.SwayMul or 1)
    self.VMSwayAng = LerpAngle(ft * 32, self.VMSwayAng or dist, dist)
    self.VMSwayLastAng = eyeAng
end

function SWEP:ViewSwayOffset(eyePos, eyeAng)
	local ft = RealFrameTime()
    local swayRaw = self.VMSwayAng or Angle()
	local sway = 1.4 * (self:GetIronsights() and 0.2 or 1)

    swayRaw.r = (-(swayRaw.y * 0.4) + swayRaw.p) * 1.2 * sway

    self.VMSwayAngSmooth = LerpAngle(ft * 1.8, self.VMSwayAngSmooth or swayRaw, swayRaw)
    local smoothAng = self.VMSwayAngSmooth * 2

	local mul = (self.SwayPosMul or 1) + (self.SwayMul or 1)

    return longsword.math.translate(
        eyePos, 
        eyeAng, 
        Vector(smoothAng.y * 0.1 * mul, 0, -smoothAng.p * 0.1 * mul), 
        smoothAng, 
        sway
    )
end

function SWEP:JumpOffset(eyePos, eyeAng)
	local ft = RealFrameTime()
	local ply = self:GetOwner()

	local grounded = ply:IsOnGround()

	local curoffset = self.VMJump or 0
	local offset = Lerp(ft * (grounded and 4 or 0.4), curoffset, grounded and 0 or 1)

	local z = offset * 1.5

	local pos = Vector(0, 0, z)
	local ang = Angle(-z, 0, 0)

	self.VMJump = offset
	return longsword.math.translate(
		eyePos,
		eyeAng,
		pos,
		ang
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

function SWEP:GetViewModelPosition( pos, ang )
	local vm = self:GetOwner():GetViewModel()
	local muz = self:LookupAttachment(self.MuzzleAttachment or "muzzle")
	local att = (muz > 0) and self:GetAttachment(muz) or { Pos = vm:GetPos(), Ang = vm:GetAngles() }

	att.Pos = vm:WorldToLocal(att.Pos)
	att.Ang = vm:WorldToLocalAngles(att.Ang)

	self.MuzzleData = att

	ang:RotateAroundAxis( ang:Right(), self.ViewModelAngle.p )
	ang:RotateAroundAxis( ang:Up(), self.ViewModelAngle.y )
	ang:RotateAroundAxis( ang:Forward(), self.ViewModelAngle.r )

	pos = pos + self.ViewModelPos.x * ang:Right()
	pos = pos + self.ViewModelPos.y * ang:Forward()
	pos = pos + self.ViewModelPos.z * ang:Up()

	pos, ang = self:ViewBob(pos, ang)
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
	local vm = ply:GetViewModel()

	if self.PunchOffset then
		ang:RotateAroundAxis(ang:Right(), -self.PunchOffset.p)
		ang:RotateAroundAxis(ang:Up(), self.PunchOffset.y)
		ang:RotateAroundAxis(ang:Forward(), -self.PunchOffset.r)
	end
	return pos, ang
end


SWEP.FOVMultiplier = 1
SWEP.LastFOVUpdate = 0 -- gets called many times per frame... weird.
function SWEP:TranslateFOV(fov)
	if self.LastFOVUpdate < CurTime() then
		self.FOVMultiplier = Lerp(RealFrameTime() * 15, self.FOVMultiplier, self:GetIronsights() and self.IronsightsFOV or 1)
		self.LastFOVUpdate = CurTime()
	end

	if self:ScopedIn() then
		return fov * (self.FOVScoped or 1)
	end

	return fov * self.FOVMultiplier
end