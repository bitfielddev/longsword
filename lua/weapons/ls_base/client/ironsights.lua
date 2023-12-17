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
	local ft = RealFrameTime()
	local ct = RealTime()

	self._CustomRecoil = self._CustomRecoil or {}
	self._CustomRecoil.Value = Lerp(ft * 2, self._CustomRecoil.Value or 0, 0)
	self._CustomRecoil.PitchValue = Lerp(ft * 8, self._CustomRecoil.PitchValue or 0, 0)
	self._CustomRecoil.RollValue = Lerp(ft * 1, self._CustomRecoil.RollValue or 0, 0)

	local mul = self:GetRecoilMultiplier()

	local recoilData = self._CustomRecoil
	local recoilInfo = self.Recoil or {}

	local re = (recoilData.Value or 0) * mul
	local rollVal = (recoilData.RollValue or 0) * (recoilInfo.RollMultiplier or 1) * mul
	local roll = math.sin(ct * 20) * 1.2 * rollVal

	local pitch = (recoilData.PitchValue or 0) * (recoilInfo.PitchMultiplier or 1) * mul

	local recoilPos = Vector(
		0,
		-re * 12 * (recoilInfo.BackMultiplier or 1),
		(-pitch * 0.8) * (recoilInfo.PitchCompMultiplier or 1)
	)

	local recoilAng = Angle(
		pitch * 4,
		0,
		0
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
	self.IronsightsFrac = Lerp(ft * (is and 3.7 or 3.1) * (self.IronsightsSpeed or 1), self.IronsightsFrac or 0, dir)

	local frac = self.IronsightsFrac
	local vec = longsword.math.vecQuadBezier(zero, self.IronsightsMid or zero, self.IronsightsPos, frac)
	local ang = longsword.math.angQuadBezier(zeroAng, self.IronsightsMidAng or zeroAng, self.IronsightsAng, frac )

	local rPos, rAng = self:DoIronsightsRecoil()
		
	vec:Add(rPos)
	ang:Add(rAng)

	return vec, ang
end