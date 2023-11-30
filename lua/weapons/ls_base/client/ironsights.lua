function SWEP:AdjustMouseSensitivity()
	if self:GetIronsights() then return self.IronsightsSensitivity end
end

local appr = math.Approach

local zero = Vector()
local zeroAng = Angle()

SWEP.IronsightsMidAng = Angle(7, 0, 15)
SWEP.IronsightsMid = Vector(-0.8, 0, -3.5)

function SWEP:GetRecoilMultiplier()
	return (self.Recoil and self.Recoil.VisualMultiplier or self.IronsightsRecoilVisualMultiplier) or 1
end

function SWEP:DoIronsightsRecoil()
	self._CustomRecoil = self._CustomRecoil or {}

	local recoilData = self._CustomRecoil
	local recoilInfo = self.Recoil or {}

	local ft = RealFrameTime()
	local ct = RealTime()

	local re = (recoilData.Value or 0) * self:GetRecoilMultiplier()
	local rollVal = (recoilData.RollValue or 0) * (recoilInfo.RollMultiplier or 1) * self:GetRecoilMultiplier()
	local roll = math.cos(ct * (recoilData.RollRandom or 1)) * 1.2 * rollVal

	local pitch = (recoilData.PitchValue or 0) * (recoilInfo.PitchMultiplier or 1) * self:GetRecoilMultiplier()

	local recoilPos = Vector(
		re * 0.5 * (recoilData.YawValue or 1),
		-re * 12 * (recoilInfo.BackMultiplier or 1),
		(-pitch * 0.8) * (recoilInfo.PitchCompMultiplier or 1)
	)

	local recoilAng = Angle(
		pitch * 4,
		0,
		(recoilData.YawValue or 1) * re * 4.4
	)


	self.RecoilRoll = Lerp(ft * 2, self.RecoilRoll or 0, roll)
	recoilAng.y = recoilAng.y + roll

	local rpSmooth = LerpVector(ft * 32, self.VMRPos or recoilPos, recoilPos)
	self.VMRPos = rpSmooth

	local rpAngSmooth = LerpAngle(ft * 32, self.VMRAng or recoilAng, recoilAng)
	self.VMRAng = rpAngSmooth

	return rpSmooth, rpAngSmooth
end

function SWEP:IronsightsOffset(oPos, oAng)
	local ct = CurTime()
	local ft = RealFrameTime()
	local is = self:GetIronsights()

	local dir = is and 1 or 0
	self.IronsightsFrac = Lerp(ft * (is and 3.1 or 2.1) * (self.IronsightsSpeed or 1), self.IronsightsFrac or 0, dir)

	local frac = self.IronsightsFrac
	local vec = longsword.math.vecQuadBezier(zero, self.IronsightsMid or zero, self.IronsightsPos, frac)
	local ang = longsword.math.angQuadBezier(zeroAng, self.IronsightsMidAng or zeroAng, self.IronsightsAng, frac )

	local rPos, rAng = self:DoIronsightsRecoil()
		
	vec:Add(rPos)
	ang:Add(rAng)

	return vec, ang
end