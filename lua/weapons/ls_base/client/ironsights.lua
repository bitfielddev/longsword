function SWEP:AdjustMouseSensitivity()
	if self:GetIronsights() then return self.IronsightsSensitivity end
end

local appr = math.Approach

local zero = Vector()
local zeroAng = Angle()

SWEP.IronsightsInMidAng = Angle(0, -15, 0)
SWEP.IronsightsInMid = Vector(-1, 0, -1)

SWEP.IronsightsOutMidAng = Angle(0, 0, 0)
SWEP.IronsightsOutMid = Vector(-2, 0, -1)
function SWEP:GetRecoilMultiplier()
	return (self.Recoil and self.Recoil.VisualMultiplier or self.IronsightsRecoilVisualMultiplier) or 1
end

function SWEP:CustomRecoilOffset(eyePos, eyeAng)
	local ft = RealFrameTime()
	local ct = RealTime()

	self._CustomRecoil = self._CustomRecoil or {}
	self._CustomRecoil.Value = Lerp(ft * 2, self._CustomRecoil.Value or 0, 0)
	self._CustomRecoil.PitchValue = Lerp(ft * 3, self._CustomRecoil.PitchValue or 0, 0)
	self._CustomRecoil.RollValue = Lerp(ft * 1, self._CustomRecoil.RollValue or 0, 0)

	local mul = self:GetRecoilMultiplier()

	local recoilData = self._CustomRecoil
	local recoilInfo = self.Recoil or {}

	local re = (recoilData.Value or 0) * mul
	local rollVal = (recoilData.RollValue or 0) * (recoilInfo.RollMultiplier or 1) * mul
	local roll = math.cos(ct * 25) * 3.2 * rollVal

	local recoilPos = Vector(
		0,
		-re * 12 * (recoilInfo.BackMultiplier or 1),
		0
	)

	local recoilAng = Angle(
		0,
		0,
		roll
	)

	eyePos = eyePos + eyeAng:Right() * recoilPos.x
	eyePos = eyePos + eyeAng:Forward() * recoilPos.y
	eyePos = eyePos + eyeAng:Up() * recoilPos.z
	
	eyeAng:RotateAroundAxis(eyeAng:Right(), recoilAng.p * mul)
    eyeAng:RotateAroundAxis(eyeAng:Up(), recoilAng.y * mul)
    eyeAng:RotateAroundAxis(eyeAng:Forward(), recoilAng.r * mul)

	return eyePos, eyeAng
end

function SWEP:GetIronsightsMid()
	if self:GetIronsights() then
		return self.IronsightsInMid, self.IronsightsInMidAng
	else
		return self.IronsightsOutMid, self.IronsightsOutMidAng
	end

end


function SWEP:IronsightsOffset(oPos, oAng)
	local ct = CurTime()
	local ft = RealFrameTime()
	local is = self:GetIronsights()

	local mid, midang = self:GetIronsightsMid()
	local dir = is and 1 or 0
	self.IronsightsFrac = Lerp(ft * (is and 3.7 or 3.1) * (self.IronsightsSpeed or 1), self.IronsightsFrac or 0, dir)

	local frac = self.IronsightsFrac
	local vec = longsword.math.vecQuadBezier(zero, mid or zero, self.IronsightsPos, frac)
	local ang = longsword.math.angQuadBezier(zeroAng, midang or zeroAng, self.IronsightsAng, frac )

	return vec, ang
end